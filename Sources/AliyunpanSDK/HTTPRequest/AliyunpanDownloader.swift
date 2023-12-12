//
//  AliyunpanDownloader.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/1.
//

import Foundation

public struct AliyunpanDownloadResult {
    public let progress: Double
    public let url: URL?
    
    public static func completed(_ url: URL) -> AliyunpanDownloadResult {
        AliyunpanDownloadResult(progress: 1, url: url)
    }
    
    public static func progressing(_ progress: Double) -> AliyunpanDownloadResult {
        AliyunpanDownloadResult(progress: progress, url: nil)
    }
}

public enum DownloadState {
    case idle
    case downloading
    case pause
}

struct DownloadChunk {
    let start: Int64
    let end: Int64
    
    init(start: Int64, end: Int64) {
        self.start = start
        self.end = end
    }
    
    init?(rangeString: String, fileSize: Int64) {
        let rangeValue = rangeString.split(separator: "=").last ?? ""
        let array = rangeValue.split(separator: "-")
        guard array.count >= 1,
              let start = Int64(array[0]) else {
            return nil
        }
        let end: Int64
        if array.count == 2, let value = Int64(array[1]) {
            end = value + 1
        } else {
            end = fileSize
        }
        self = Self(start: start, end: end)
    }
}

public class AliyunpanDownloader: NSObject {
    actor DownloadRequester {
        var url: URL?
        var expiration: Date?
        
        func getDownloadURL(with file: AliyunpanFile, by client: AliyunpanClient) async throws -> URL {
            // 当前下载链接未过期
            if let url, let expiration, expiration > Date() {
                return url
            }
            let response = try await client.send(
                AliyunpanScope.File.GetFileDownloadUrl(
                    .init(drive_id: file.drive_id, file_id: file.file_id)))
            url = response.url
            expiration = response.expiration
            return response.url
        }
    }
    
    class StateProvider {
        let progressHandler: (Int64, Int64) -> Void
        let completionHandler: (Result<URL, Error>) -> Void
        
        init(progressHandler: @escaping (Int64, Int64) -> Void, completionHandler: @escaping (Result<URL, Error>) -> Void) {
            self.progressHandler = progressHandler
            self.completionHandler = completionHandler
        }
    }
    
    private lazy var session: URLSession = {
        URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: downloadQueue)
    }()
    
    /// 已写数据大小
    private var totalWritedSize: Int64 = 0
    
    /// 目标文件
    let file: AliyunpanFile
    /// 期望下载位置
    let destination: URL
    /// 分片
    let chunks: [DownloadChunk]
    /// 分片间距
    let chunkSize: Int
    /// 最大并发数，必须小于 10
    let maxConcurrentOperationCount: Int
    /// 文件总大小
    let totalSize: Int64
    let downloadQueue: OperationQueue
    
    private var stateProvider: StateProvider?
    
    let requester = DownloadRequester()
    let fileManager = FileManager.default
    
    weak var client: AliyunpanClient?
    
    public var state: DownloadState = .idle
    
    private lazy var lastTotalWritedSize: Int64 = {
        totalWritedSize
    }()
    
    private lazy var networkSpeedTimer: Timer = {
        return Timer(timeInterval: 1, target: self, selector: #selector(updateNetworkSpeed), userInfo: nil, repeats: true)
    }()
    
    /// 每秒传输的字节数
    public var networkSpeedMonitor: ((Int64) -> Void)? {
        didSet {
            RunLoop.current.add(networkSpeedTimer, forMode: .common)
            networkSpeedTimer.fire()
        }
    }
    
    deinit {
        networkSpeedTimer.invalidate()
    }
    
    init(file: AliyunpanFile,
         destination: URL,
         chunkSize: Int = 4_000_000,
         maxConcurrentOperationCount: Int) {
        self.file = file
        self.destination = destination
        self.maxConcurrentOperationCount = min(10, maxConcurrentOperationCount)
        self.chunkSize = chunkSize
        let totalSize = file.size ?? 0
        self.totalSize = totalSize
        self.chunks = stride(from: 0, to: totalSize, by: chunkSize).map {
            DownloadChunk(start: $0, end: min($0 + Int64(chunkSize), totalSize))
        }
        self.downloadQueue = OperationQueue(
            name: "com.AliyunpanSDK.downloader.queue",
            maxConcurrentOperationCount: maxConcurrentOperationCount)
        super.init()
    }
    
    /// 合并分片
    private func merge() throws {
        Logger.log(.info, msg: "[Downloader][\(file.name)] start merge...")
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
        Logger.log(.info, msg: "[Downloader][\(file.name)] merge success.")
    }
    
    private func retry(task: URLSessionTask) {
        if let request = task.originalRequest {
            let task = session.downloadTask(with: request)
            downloadQueue.addOperation {
                task.resume()
            }
        }
    }
    
    @objc private func updateNetworkSpeed() {
        let offset = min(totalWritedSize - lastTotalWritedSize, 0)
        networkSpeedMonitor?(offset)
        lastTotalWritedSize = totalWritedSize
    }
    
    /// 清除现场
    private func clean() {
        Logger.log(.debug, msg: "[Downloader][\(file.name)] clean")
        try? fileManager.removeItem(at: getChunkDirectory())
        try? fileManager.removeItem(at: destination)
    }
}

extension AliyunpanDownloader {
    private func download(chunks: [DownloadChunk]) -> AsyncThrowingStream<AliyunpanDownloadResult, Error> {
        AsyncThrowingStream { continuation in
            continuation.onTermination = { [weak self] _ in
                self?.session.invalidateAndCancel()
            }
            
            stateProvider = StateProvider { current, total in
                let progress = min(1, max(0, Double(current) / Double(total)))
                continuation.yield(AliyunpanDownloadResult.progressing(progress))
                Logger.log(.debug, msg: "[Downloader] downloading, progress:\(progress)")
            } completionHandler: { [weak self] result in
                guard let self else {
                    return
                }
                switch result {
                case .success(let localURL):
                    Logger.log(.info, msg: "[Downloader][\(self.file.name)] finshed, url:\(localURL.absoluteString)")
                    continuation.yield(AliyunpanDownloadResult.completed(localURL))
                    continuation.finish()
                case .failure(let error):
                    Logger.log(.info, msg: "[Downloader][\(self.file.name)] finshed with error:\(error)")
                    continuation.finish(throwing: error)
                }
            }
            
            // 初始化
            let progress = Double(totalWritedSize) / Double(totalSize)
            continuation.yield(AliyunpanDownloadResult.progressing(progress))
             
            if isFinished {
                do {
                    try merge()
                } catch {
                    stateProvider?.completionHandler(.failure(error))
                }
            } else {
                startDownload(chunks: chunks)
            }
        }
    }
    
    private func startDownload(chunks: [DownloadChunk]) {
        Logger.log(.info, msg: "[Downloader][\(file.name)] request chunks, \(chunks.count)/\(self.chunks.count)")

        totalWritedSize = getTotalWritedSize()
        session.invalidateAndCancel()
        session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: downloadQueue)
        
        guard let client else {
            stateProvider?.completionHandler(.failure(AliyunpanNetworkSystemError.invaildClient))
            return
        }
        
        Task {
            do {
                let downloadURL = try await requester.getDownloadURL(with: file, by: client)
                let tasks = chunks.map { chunk in
                    var urlRequest = URLRequest(url: downloadURL)
                    if chunk.end >= totalSize {
                        urlRequest.setValue("bytes=\(chunk.start)-", forHTTPHeaderField: "Range")
                    } else {
                        urlRequest.setValue("bytes=\(chunk.start)-\(chunk.end - 1)", forHTTPHeaderField: "Range")
                    }
                    return session.downloadTask(with: urlRequest)
                }

                tasks.forEach { task in
                    downloadQueue.addOperation {
                        task.resume()
                    }
                }
            } catch {
                stateProvider?.completionHandler(.failure(error))
            }
        }
    }
    
    /// 下载文件
    /// - Parameters:
    ///   - continue: 是否继续上一次未完成的下载，如 false，则会重新下载
    func download(continue: Bool = true) -> AsyncThrowingStream<AliyunpanDownloadResult, Error> {
        Logger.log(.info, msg: "[Downloader][\(file.name)] start, continue:\(`continue`), destination:\(destination.path)")
        if `continue` {
            return download(chunks: unfininshedChunks)
        } else {
            clean()
            return download(chunks: chunks)
        }
    }

    /// 下载文件
    /// - Parameters:
    ///   - continue: 是否继续上一次未完成的下载，如 false，则会重新下载
    public func download(
        continue: Bool = true,
        progressHandle: ((Double) -> Void)? = nil,
        completionHandle: @escaping (Result<URL, Error>) -> Void) {
        guard state != .downloading else {
            return
        }
        state = .downloading
        Task {
            do {
                for try await result in download(continue: `continue`) {
                    if let url = result.url {
                        completionHandle(.success(url))
                    } else {
                        progressHandle?(result.progress)
                    }
                }
            } catch {
                completionHandle(.failure(error))
            }
        }
    }
    
    /// 恢复下载
    public func resume() {
        guard state == .pause else {
            return
        }
        Logger.log(.info, msg: "[Downloader][\(file.name)] resume")
        state = .downloading
        startDownload(chunks: unfininshedChunks)
    }
    
    /// 暂停下载
    public func pause() {
        guard state == .downloading else {
            return
        }
        Logger.log(.info, msg: "[Downloader][\(file.name)] pause")
        state = .pause
        session.invalidateAndCancel()
    }
    
    /// 取消下载
    /// 会同时清理已下载分片
    public func cancel() {
        Logger.log(.info, msg: "[Downloader][\(file.name)] cancel")
        state = .idle
        session.invalidateAndCancel()
        clean()
    }
}

extension AliyunpanDownloader: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as? NSError, error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorTimedOut:
                retry(task: task)
            case NSURLErrorCancelled:
                return
            default:
                stateProvider?.completionHandler(.failure(error))
            }
        } else if let response = task.response as? HTTPURLResponse,
                  response.statusCode == 403 {
            Logger.log(.warn, msg: "[Downloader][\(file.name)] request has expired.")
            startDownload(chunks: unfininshedChunks)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        totalWritedSize += bytesWritten
        stateProvider?.progressHandler(totalWritedSize, totalSize)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            if let target = getChunkPath(by: downloadTask) {
                let directory = target.deletingLastPathComponent()
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                if fileManager.fileExists(atPath: target.path) {
                    try? fileManager.removeItem(at: target)
                }
                try fileManager.moveItem(at: location, to: target)
                let range = downloadTask.currentRequest?.allHTTPHeaderFields?["Range"] ?? ""
                Logger.log(.info, msg: "[Downloader][\(file.name)] the chunk has been downloaded, range:\(range)")
            }
            
            if isFinished {
                try merge()
                stateProvider?.completionHandler(.success(destination))
            }
        } catch {
            stateProvider?.completionHandler(.failure(error))
        }
    }
}

extension AliyunpanDownloader {
    /// 未完成分片
    private var unfininshedChunks: [DownloadChunk] {
        chunks.filter { chunk in
            let path = getChunkFilePath(with: chunk).path
            if !fileManager.fileExists(atPath: path) {
                return true
            }
            let attributes = try? fileManager.attributesOfItem(atPath: path)
            let size = attributes?[.size] as? Int64 ?? 0
            let targetSize = chunk.end - chunk.start
            return size < targetSize
        }
    }
    
    /// 全部完成
    private var isFinished: Bool {
        return unfininshedChunks.isEmpty
    }
    
    private func getTotalWritedSize() -> Int64 {
        return chunks.compactMap { chunk in
            let path = getChunkFilePath(with: chunk).path
            guard fileManager.fileExists(atPath: path) else {
                return nil
            }
            let attributes = try? fileManager.attributesOfItem(atPath: path)
            return attributes?[.size] as? Int64
        }.reduce(0, +)
    }
}

extension AliyunpanDownloader {
    private func getChunkPath(by task: URLSessionDownloadTask) -> URL? {
        let rangeString = task.originalRequest?.allHTTPHeaderFields?["Range"] ?? ""
        guard let chunk = DownloadChunk(rangeString: rangeString, fileSize: totalSize) else {
            return nil
        }
        return getChunkFilePath(with: chunk)
    }
    
    private func getChunkFilePath(with chunk: DownloadChunk) -> URL {
        var url = getChunkDirectory()
        url.appendPathComponent(
            "\(destination.lastPathComponent)_\(chunk.start)-\(chunk.end).mp4")
        return url
    }
    
    private func getChunkDirectory() -> URL {
        var url = destination.deletingLastPathComponent()
        url.appendPathComponent("\(file.drive_id)_\(file.file_id)~aliyunpansdk/")
        return url
    }
}
