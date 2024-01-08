//
//  AliyunpanDownloadTask.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/18.
//

import Foundation

protocol AliyunpanDownloadTaskDelegate: AnyObject {
    func getFileDownloadUrl(driveId: String, fileId: String) async throws -> AliyunpanScope.File.GetFileDownloadUrl.Response
    
    func getOperationQueue() -> OperationQueue

    func downloadTask(_ task: AliyunpanDownloadTask, didUpdateState state: AliyunpanDownloadTask.State)
    
    func downloadTask(task: AliyunpanDownloadTask, didWriteData bytesWritten: Int64)
}

/// 使用 actor 实现串行刷新 downloadURL
actor DownloadURLActor {
    private var url: URL?
    private var expiration: Date?
    private var refreshTask: Task<URL, any Error>?

    private func refreshDownloadURL(with file: AliyunpanFile, by delegate: AliyunpanDownloadTaskDelegate) async throws -> URL {
        let response = try await delegate.getFileDownloadUrl(
            driveId: file.drive_id,
            fileId: file.file_id)
        url = response.url
        expiration = response.expiration
        return response.url
    }
    
    func getDownloadURL(
        with file: AliyunpanFile,
        by delegate: AliyunpanDownloadTaskDelegate) async throws -> URL {
        if let url = self.url, let expiration = self.expiration, expiration > Date() {
            return url
        }
        if let refreshTask {
            return try await refreshTask.value
        }
        let task = Task {
            let url = try await refreshDownloadURL(with: file, by: delegate)
            refreshTask = nil
            return url
        }
        refreshTask = task
        return try await task.value
    }
}

public class AliyunpanDownloadTask: NSObject, Identifiable {
    public lazy var id: String = {
        "\(file.drive_id)_\(file.file_id)_\(Int.random(in: 0...1000))"
    }()

    /// 下载状态
    public enum State {
        /// 等待下载
        case waiting
        /// 下载中
        case downloading(progress: Float)
        /// 暂停中
        case pause(progress: Float)
        /// 已完成
        case finished(URL)
        /// 失败
        case failed(Error)
    }
    
    public let file: AliyunpanFile
    let destination: URL
    
    private let chunkSize: Int64
    private let downloadURLActor = DownloadURLActor()
    private let fileManager = FileManager.default
    
    private weak var delegate: AliyunpanDownloadTaskDelegate?
    
    public private(set) var state: State = .waiting {
        didSet {
            delegate?.downloadTask(self, didUpdateState: state)
        }
    }
    
    private(set) var urlSession: URLSession?
    
    private var writedSize: Int64 = 0
    
    @ThreadSafe
    var unfinishedChunks: [AliyunpanDownloadChunk] = []

    init(file: AliyunpanFile, destination: URL, delegate: AliyunpanDownloadTaskDelegate?) {
        self.file = file
        self.destination = destination
        self.delegate = delegate
        // 根据文件大小动态设置分片大小，来降低内存占用
        // 最小为4M
        self.chunkSize = max(4_000_000, (file.size ?? 0) / 1000)
        super.init()
        delegate?.downloadTask(self, didUpdateState: state)
    }
    
    func start() {
        state = .waiting
        
        writedSize = getWritedSize()
        unfinishedChunks = chunks.filter {
            !isFinishedChunk($0)
        }
        
        unfinishedChunks.map {
            getOperation(with: $0)
        }.forEach {
            delegate?.getOperationQueue().addOperation($0)
        }
    }
    
    func pause() {
        removeAllOperations()

        state = .pause(progress: progress)
    }
    
    func cancel() {
        removeAllOperations()

        clean()
        state = .failed(AliyunpanError.DownloadError.userCancelled)
    }
    
    private func removeAllOperations() {
        delegate?.getOperationQueue().operations.compactMap {
            $0 as? DownloadChunkOperation
        }.filter {
            $0.taskIdentifier == id
        }.forEach {
            $0.cancel()
        }
    }
    
    private func clean() {
        try? fileManager.removeItem(at: getChunkDirectory())
        try? fileManager.removeItem(at: destination)
    }
    
    private func retry(chunk: AliyunpanDownloadChunk) {
        let operation = getOperation(with: chunk)
        operation.queuePriority = .high
        delegate?.getOperationQueue().addOperation(operation)
    }
    
    private func merge() throws {
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }

        fileManager.createFile(atPath: destination.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: destination)
        try chunks.forEach { chunk in
            let chunkFileURL = getChunkFilePath(with: chunk)
            let data = try Data(contentsOf: chunkFileURL)
            fileHandle.write(data)
        }
        try fileManager.removeItem(at: getChunkDirectory())
        try fileHandle.close()
    }
}

extension AliyunpanDownloadTask {
    private var progress: Float {
        let totalSize = file.size ?? 0
        let writedSize = Float(writedSize)
        return writedSize / Float(totalSize)
    }

    private var totalSize: Int64 {
        file.size ?? 0
    }
    
    var chunks: [AliyunpanDownloadChunk] {
        stride(from: 0, to: totalSize, by: Int64.Stride(chunkSize)).map {
            AliyunpanDownloadChunk(start: $0, end: min($0 + Int64(chunkSize), totalSize))
        }
    }
        
    private func isFinishedChunk(_ chunk: AliyunpanDownloadChunk) -> Bool {
        let path = getChunkFilePath(with: chunk).path
        if !fileManager.fileExists(atPath: path) {
            return false
        }
        let attributes = try? fileManager.attributesOfItem(atPath: path)
        let size = attributes?[.size] as? Int64 ?? 0
        let targetSize = chunk.end - chunk.start
        
        return size >= targetSize
    }
    
    /// 获取已写入大小
    private func getWritedSize() -> Int64 {
        return chunks.compactMap { chunk in
            let path = getChunkFilePath(with: chunk).path
            guard fileManager.fileExists(atPath: path) else {
                return nil
            }
            let attributes = try? fileManager.attributesOfItem(atPath: path)
            return attributes?[.size] as? Int64
        }.reduce(0, +)
    }
    
    private func getOperation(with chunk: AliyunpanDownloadChunk) -> DownloadChunkOperation {
        let chunkDestination = getChunkFilePath(with: chunk)
        let operation = DownloadChunkOperation(
            chunk: chunk,
            destination: chunkDestination,
            taskIdentifier: id
        )
        operation.delegate = self
        operation.dataSource = self
        return operation
    }
    
    private func getChunkFilePath(with chunk: AliyunpanDownloadChunk) -> URL {
        var url = getChunkDirectory()
        url.appendPathComponent(
            "\(destination.lastPathComponent)_\(chunk.start)-\(chunk.end)")
        return url
    }
    
    private func getChunkDirectory() -> URL {
        var url = destination.deletingLastPathComponent()
        url.appendPathComponent("\(file.drive_id)_\(file.file_id)~aliyunpansdk/")
        return url
    }
}

extension AliyunpanDownloadTask: DownloadChunkOperationDelegate {
    func chunkOperation(_ operation: DownloadChunkOperation, didUpdatedState state: AsyncOperation.State) {
        let chunkIndex = chunks.firstIndex(where: { $0.start == operation.chunk.start }) ?? -1
        
        do {
            guard try operation.result?.get() != nil else {
                // cancelled
                return
            }

            switch (state, self.state) {
            case (.ready, _):
                Logger.log(.info, msg: "[Downloader][\(file.name)], \(chunkIndex)/\(chunks.count) ready")

            case (.executing, .waiting):
                // 分片开始执行
                Logger.log(.info, msg: "[Downloader][\(file.name)], \(chunkIndex)/\(chunks.count) executing...")
            case (.finished, .downloading):
                unfinishedChunks.removeAll(where: { $0 == operation.chunk })
                // 分片全部完成
                if unfinishedChunks.isEmpty {
                    Logger.log(.info, msg: "[Downloader][\(file.name)] start merge...")
                    
                    try merge()
                    
                    Logger.log(.info, msg: "[Downloader][\(file.name)] merge success.")
                    self.state = .finished(destination)
                } else {
                    Logger.log(.info, msg: "[Downloader][\(file.name)], \(chunkIndex)/\(chunks.count) finished")
                    self.state = .downloading(progress: progress)
                }
            default:
                break
            }
        } catch AliyunpanError.DownloadError.downloadURLExpired {
            Logger.log(.error, msg: "[Downloader][\(file.name)], \(chunkIndex)/\(chunks.count) error, downloadURLExpired")
            
            // 下载链接过期
            retry(chunk: operation.chunk)
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            Logger.log(.error, msg: "[Downloader][\(file.name)], \(chunkIndex)/\(chunks.count) error, \(error)")
            
            switch error.code {
            case NSURLErrorTimedOut:
                retry(chunk: operation.chunk)
            case NSURLErrorCancelled:
                return
            default:
                self.state = .failed(error)
            }
        } catch {
            Logger.log(.error, msg: "[Downloader][\(file.name)], \(chunkIndex)/\(chunks.count) error, \(error)")
            
            self.state = .failed(error)
        }
    }
    
    func chunkOperationDidWriteData(_ bytesWritten: Int64) {
        writedSize += bytesWritten
        state = .downloading(progress: progress)
        
        // 通知下载器更新
        delegate?.downloadTask(task: self, didWriteData: bytesWritten)
    }
}

extension AliyunpanDownloadTask: DownloadChunkOperationDataSource {
    func getFileDownloadUrl() async throws -> URL {
        guard let delegate else {
            throw AliyunpanError.DownloadError.invalidClient
        }
        return try await downloadURLActor.getDownloadURL(with: file, by: delegate)
    }
}
