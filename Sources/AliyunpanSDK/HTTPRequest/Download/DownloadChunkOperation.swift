//
//  DownloadChunkOperation.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/19.
//

import Foundation

protocol DownloadChunkOperationDelegate: AnyObject {
    func chunkOperation(_ operation: DownloadChunkOperation, didUpdatedState state: AsyncOperation.State)
    
    func chunkOperationDidWriteData(_ bytesWritten: Int64)
}

protocol DownloadChunkOperationDataSource: AnyObject {
    func getFileDownloadUrl() async throws -> URL
}

class DownloadChunkOperation: AsyncThrowOperation<URL, Error> {
    class StateProvider {
        let completionHandler: (Result<Data, Error>) -> Void
        
        init(completionHandler: @escaping (Result<Data, Error>) -> Void) {
            self.completionHandler = completionHandler
        }
    }
    
    weak var delegate: DownloadChunkOperationDelegate?
    weak var dataSource: DownloadChunkOperationDataSource?

    let chunk: AliyunpanDownloadChunk
    let destination: URL
    let taskIdentifier: String?
    
    private var fileManager: FileManager {
        FileManager.default
    }
    
    private var stateProvider: StateProvider?
    private var sessionTask: URLSessionTask?
    private var task: Task<Void, Never>?
    
    private lazy var urlSession: URLSession? =
        URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: .init(name: "com.aliyunpanSDK.downloadTaskQueue"))
    
    init(chunk: AliyunpanDownloadChunk, destination: URL, taskIdentifier: String) {
        self.chunk = chunk
        self.destination = destination
        self.taskIdentifier = taskIdentifier
    }
    
    override func main() {
        guard let dataSource else {
            cancel()
            return
        }
        
        task = Task {
            do {
                try await Task.sleep(seconds: 0.3)
                // 下载
                let data = try await download(chunk: chunk, with: dataSource)
                
                // 写入
                let directory = destination.deletingLastPathComponent()
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                
                if fileManager.fileExists(atPath: destination.path) {
                    try fileManager.removeItem(at: destination)
                }
                
                fileManager.createFile(atPath: destination.path, contents: data)

                result = .success(destination)
                finish()
            } catch {
                result = .failure(error)
                finish()
            }
        }
    }
    
    override func finish() {
        guard !isFinished else {
            return
        }
        clean {
            super.finish()
        }
    }
    
    override func cancel() {
        clean {
            super.cancel()
        }
    }
    
    private func clean(_ completion: () -> Void) {
        sessionTask?.cancel()
        sessionTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        task?.cancel()
        completion()
    }
    
    override func updateState(state: AsyncOperation.State, oldValue: AsyncOperation.State) {
        delegate?.chunkOperation(self, didUpdatedState: state)
    }
}

extension DownloadChunkOperation {
    private func download(
        chunk: AliyunpanDownloadChunk,
        with dataSource: DownloadChunkOperationDataSource
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            stateProvider = StateProvider { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            Task {
                do {
                    let downloadURL = try await dataSource.getFileDownloadUrl()
                    var urlRequest = URLRequest(url: downloadURL)
                    
                    urlRequest.setValue("bytes=\(chunk.start)-\(chunk.end - 1)", forHTTPHeaderField: "Range")
    
                    let urlSession = self.urlSession ?? URLSession(
                        configuration: .default,
                        delegate: self,
                        delegateQueue: .init(name: "com.aliyunpanSDK.downloadTaskQueue"))
                    
                    let sessionTask = urlSession.downloadTask(with: urlRequest)
                    sessionTask.resume()
                    self.sessionTask = sessionTask
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension DownloadChunkOperation {
    private func chunkOperationDidCompleteWithError(_ error: Error) {
        stateProvider?.completionHandler(.failure(error))
        stateProvider = nil
    }

    private func chunkOperatioDidFinishDownload(_ data: Data) {
        stateProvider?.completionHandler(.success(data))
        stateProvider = nil
    }
}

extension DownloadChunkOperation: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            chunkOperationDidCompleteWithError(error)
        } else if let response = task.response as? HTTPURLResponse,
           response.statusCode == 403,
           // https://help.aliyun.com/zh/oss/support/0002-00000069
           response.value(forHTTPHeaderField: "x-oss-ec") == "0002-00000069" {
            chunkOperationDidCompleteWithError(
                AliyunpanError.DownloadError.downloadURLExpired)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        delegate?.chunkOperationDidWriteData(bytesWritten)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            chunkOperatioDidFinishDownload(data)
        } catch {
            chunkOperationDidCompleteWithError(error)
        }
    }
}
