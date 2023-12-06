//
//  AliyunpanDownloader.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/1.
//

import Foundation

public struct DownloadResult {
    public let progress: Double
    public let url: URL?
    
    public static func completed(url: URL) -> DownloadResult {
        DownloadResult(progress: 1, url: url)
    }
    
    public static func progressing(_ progress: Double) -> DownloadResult {
        DownloadResult(progress: progress, url: nil)
    }
}

public class AliyunpanDownloader: NSObject {
    struct DownloadChunk {
        let start: Int64
        let end: Int64
    }
    
    class StateProvider {
        let progressHandler: (Int64, Int64) -> Void
        let completionHandler: (Result<URL, Error>) -> Void
        
        init(progressHandler: @escaping (Int64, Int64) -> Void, completionHandler: @escaping (Result<URL, Error>) -> Void) {
            self.progressHandler = progressHandler
            self.completionHandler = completionHandler
        }
    }
    
    /// 分片间距
    private static let chunkSize = 4_000_000
    
    /// 最大并发数，必须小于 10
    private let maxConcurrentOperationCount: Int
    
    private(set) lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue(
            name: "com.AliyunpanSDK.downloader.queue",
            maxConcurrentOperationCount: maxConcurrentOperationCount)
        return queue
    }()
    
    /// 已写数据大小
    private lazy var totalWritedSize: Int64 = {
        chunks.enumerated().compactMap { index, _ in
            let path = getChunkPath(with: index).path
            guard FileManager.default.fileExists(atPath: path) else {
                return nil
            }
            let attributes = try? FileManager.default.attributesOfItem(atPath: path)
            return attributes?[.size] as? Int64
        }.reduce(0, +)
    }()
    
    private var unfininshedChunks: [DownloadChunk] {
        chunks.enumerated().compactMap { index, chunk in
            let path = getChunkPath(with: index).path
            guard !FileManager.default.fileExists(atPath: path) else {
                return nil
            }
            return chunk
        }
    }
    
    /// 全部完成
    private var isFinished: Bool {
        unfininshedChunks.count == 0
    }
    
    private lazy var session: URLSession = {
        URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: downloadQueue)
    }()
    
    let url: URL
    let totalSize: Int64
    let destination: URL
    let chunks: [DownloadChunk]
    var stateProvider: StateProvider?
    var tasks: [URLSessionDownloadTask] = []
    
    init(
        url: URL,
        size: Int64,
        destination: URL,
        maxConcurrentOperationCount: Int) {
        self.url = url
        self.totalSize = size
        self.destination = destination
        self.maxConcurrentOperationCount = min(10, maxConcurrentOperationCount)
        self.chunks = stride(from: 0, to: size, by: Self.chunkSize).map {
            let start = $0
            let end = $0 + Int64(Self.chunkSize)
            return DownloadChunk(start: start, end: min(end, size))
        }
        super.init()
    }
    
    private func merge() throws {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        fileManager.createFile(atPath: destination.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: destination)
        
        try chunks.enumerated().forEach { index, _ in
            let chunkFileURL = getChunkPath(with: index)
            
            let data = try Data(contentsOf: chunkFileURL)
            fileHandle.write(data)
            
            try? FileManager.default.removeItem(at: chunkFileURL)
        }
        try fileHandle.close()
    }
    
    private func retry(task: URLSessionTask) {
        if let request = task.originalRequest {
            let task = session.downloadTask(with: request)
            downloadQueue.addOperation {
                task.resume()
            }
        }
    }
}

extension AliyunpanDownloader {
    private func download(chunks: [DownloadChunk]) -> AsyncThrowingStream<DownloadResult, Error> {
        AsyncThrowingStream { continuation in
            stateProvider = StateProvider { current, total in
                let progress = min(1, max(0, Double(current) / Double(total)))
                continuation.yield(DownloadResult.progressing(progress))
            } completionHandler: { result in
                switch result {
                case .success(let localURL):
                    continuation.yield(DownloadResult.completed(url: localURL))
                    continuation.finish()
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            }
            
            let url = self.url
            
            tasks = chunks.map { chunk in
                let start = chunk.start
                let end: String = "\(chunk.end >= totalSize ? "" : "\(chunk.end)")"
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("bytes=\(start)-\(end)", forHTTPHeaderField: "Range")
                return session.downloadTask(with: urlRequest)
            }
            
            /// 初始化
            let progress = Double(totalWritedSize) / Double(totalSize)
            continuation.yield(DownloadResult.progressing(progress))
            tasks.forEach { task in
                downloadQueue.addOperation {
                    task.resume()
                }
            }
        }
    }
    
    /// 下载文件
    /// - Parameters:
    ///   - continue: 是否继续上一次未完成的下载，如 false，则会重新下载
    public func download(continue: Bool = true) -> AsyncThrowingStream<DownloadResult, Error> {
        if `continue` {
            return download(chunks: unfininshedChunks)
        } else {
            // 重置进度
            totalWritedSize = 0
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
        tasks.forEach {
            $0.resume()
        }
    }
    
    /// 暂停下载
    public func pause() {
        tasks.forEach {
            $0.suspend()
        }
    }
    
    /// 取消下载
    /// 会同时清理已下载分片
    public func cancel() {
        tasks.forEach {
            $0.cancel()
        }
        chunks.enumerated().forEach { index, _ in
            let url = getChunkPath(with: index)
            try? FileManager.default.removeItem(at: url)
        }
        
        try? FileManager.default.removeItem(at: destination)
    }
}

extension AliyunpanDownloader: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error as? NSError, error.domain == NSURLErrorDomain else {
            return
        }
        switch error.code {
        case NSURLErrorTimedOut:
            retry(task: task)
        default:
            stateProvider?.completionHandler(.failure(error))
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        totalWritedSize += bytesWritten
        stateProvider?.progressHandler(totalWritedSize, totalSize)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        do {
            let directory = destination.deletingLastPathComponent()
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            
            let target = getChunkPath(by: downloadTask)
            try fileManager.moveItem(at: location, to: target)
        } catch {
            stateProvider?.completionHandler(.failure(error))
        }
        
        if isFinished {
            Task {
                do {
                    try merge()
                    stateProvider?.completionHandler(.success(destination))
                } catch {
                    stateProvider?.completionHandler(.failure(error))
                }
            }
        }
    }
}

extension AliyunpanDownloader {
    private func getChunkIndex(by task: URLSessionDownloadTask) -> Int {
        let range = task.originalRequest?.allHTTPHeaderFields?["Range"] ?? ""
        let rangeValue = range.split(separator: "=").last ?? ""
        let index = (Int(rangeValue.split(separator: "-").first ?? "") ?? 0) / Self.chunkSize
        return index
    }
    
    private func getChunkPath(by task: URLSessionDownloadTask) -> URL {
        let index = getChunkIndex(by: task)
        return getChunkPath(with: index)
    }
    
    private func getChunkPath(with index: Int) -> URL {
        var fileURL = destination.deletingLastPathComponent()
        fileURL.appendPathComponent("\(destination.lastPathComponent)~aliyunpansdk.\(index)")
        return fileURL
    }
}
