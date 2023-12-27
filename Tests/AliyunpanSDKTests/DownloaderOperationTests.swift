//
//  DownloaderOperationTests.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/21.
//

import XCTest
@testable import AliyunpanSDK

class DownloaderOperationTests: XCTestCase {
    let destination = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

    let operationQueue = OperationQueue(
        name: "DownloaderOperationTests.queue",
        maxConcurrentOperationCount: 10)
    
    var completionHandle: ((DownloadChunkOperation, AsyncOperation.State) -> Void)?
    
    var chunkOperation: DownloadChunkOperation?
    
    func testSuccess() async throws {
        let chunkOperation = {
            let chunk = AliyunpanDownloadChunk(start: 0, end: 1000)
            let chunkOperation = DownloadChunkOperation(chunk: chunk, destination: destination.appendingPathComponent("testfile"), taskIdentifier: "")
            chunkOperation.delegate = self
            chunkOperation.dataSource = self
            return chunkOperation
        }()
        self.chunkOperation = chunkOperation
        
        XCTAssertEqual(chunkOperation.state, .ready)

        let stream = AsyncThrowingStream<(DownloadChunkOperation, AsyncOperation.State), Error> { continuation in
            completionHandle = { operation, state in
                continuation.yield((operation, state))
                if state == .finished {
                    continuation.finish()
                }
            }
            operationQueue.addOperation(chunkOperation)
        }

        var index = 0
        for try await result in stream {
            let url = try? result.0.result?.get()
            if index == 0 {
                XCTAssertEqual(url, nil)
                XCTAssertEqual(result.1, .executing)
            } else if index == 1 {
                XCTAssertEqual(result.1, .finished)
            }
            index += 1
        }
    }
    
    func testFailure() async throws {
        let chunkOperation = {
            let chunk = AliyunpanDownloadChunk(start: 1000, end: 4000)
            let chunkOperation = DownloadChunkOperation(chunk: chunk, destination: destination, taskIdentifier: "")
            chunkOperation.delegate = self
            chunkOperation.dataSource = self
            return chunkOperation
        }()
        self.chunkOperation = chunkOperation
        
        XCTAssertEqual(chunkOperation.state, .ready)

        let stream = AsyncThrowingStream<(DownloadChunkOperation, AsyncOperation.State), Error> { continuation in
            completionHandle = { operation, state in
                continuation.yield((operation, state))
                if state == .finished {
                    continuation.finish()
                }
            }
            operationQueue.addOperation(chunkOperation)
        }

        var index = 0
        for try await result in stream {
            if index == 0 {
                let url = try? result.0.result?.get()
                XCTAssertEqual(url, nil)
                XCTAssertEqual(result.1, .executing)
            } else if index == 1 {
                XCTAssertThrowsError(try result.0.result?.get())
                XCTAssertEqual(result.1, .finished)
            }
            index += 1
        }
    }
}

extension DownloaderOperationTests: DownloadChunkOperationDelegate {
    func chunkOperationDidWriteData(_ bytesWritten: Int64) {
        
    }
    
    func chunkOperation(_ operation: AliyunpanSDK.DownloadChunkOperation, didUpdatedState state: AliyunpanSDK.AsyncOperation.State) {
        completionHandle?(operation, state)
    }
}

extension DownloaderOperationTests: DownloadChunkOperationDataSource {
    func getFileDownloadUrl() async throws -> URL {
        URL(string: "https://aliyunpan.com")!
    }
}
