//
//  DownloaderTaskTests.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/21.
//

import XCTest
@testable import AliyunpanSDK

let file = AliyunpanFile(
    drive_id: "drive_id",
    file_id: "file_id",
    parent_file_id: "",
    name: "",
    size: 12_345_678,
    file_extension: nil,
    content_hash: nil,
    type: .file,
    thumbnail: nil,
    url: nil,
    created_at: nil,
    updated_at: nil,
    play_cursor: nil,
    image_media_metadata: nil,
    video_media_metadata: nil)

class DownloaderTaskTests: XCTestCase, AliyunpanDownloadTaskDelegate {
    let destination = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    
    private let operationQueue = OperationQueue(
        name: "test",
        maxConcurrentOperationCount: 10)
    
    func testTask() throws {
        let task = AliyunpanDownloadTask(
            file: file,
            destination: destination,
            delegate: self)
        
        task.start()
        XCTAssertEqual(operationQueue.operations.count, 4)
     
        task.cancel()
        XCTAssertEqual(operationQueue.operations.count, 0)
        
        task.start()
        XCTAssertEqual(operationQueue.operations.count, 4)

        task.pause()
        XCTAssertEqual(operationQueue.operations.count, 0)
    }
    
    func getFileDownloadUrl(driveId: String, fileId: String) async throws -> AliyunpanScope.File.GetFileDownloadUrl.Response {
        try await Task.sleep(seconds: 1)
        return AliyunpanScope.File.GetFileDownloadUrl.Response(
            url: URL(string: "https://alipan.com")!,
            expiration: Date().addingTimeInterval(100),
            method: "GET")
    }
    
    func getOperationQueue() -> OperationQueue {
        operationQueue
    }
    
    func downloadTask(_ task: AliyunpanDownloadTask, didUpdateState state: AliyunpanDownloadTask.State) {}
    
    func downloadTask(task: AliyunpanDownloadTask, didWriteData bytesWritten: Int64) {}
}

class DownloaderActorTests: XCTestCase, AliyunpanDownloadTaskDelegate {
    private var getDownloadURLCount = 0
    
    func testDownloadActor() async throws {
        let actor = DownloadURLActor()
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        
        XCTAssertEqual(getDownloadURLCount, 1)
        
        try await Task.sleep(seconds: 0.06)
        
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        
        XCTAssertEqual(getDownloadURLCount, 2)
        
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        _ = try await actor.getDownloadURL(with: file, by: self)
        
        XCTAssertEqual(getDownloadURLCount, 2)
    }
    
    func getFileDownloadUrl(driveId: String, fileId: String) async throws -> AliyunpanScope.File.GetFileDownloadUrl.Response {
        try await Task.sleep(seconds: 0.05)
        
        getDownloadURLCount += 1
        
        return AliyunpanScope.File.GetFileDownloadUrl.Response(
            url: URL(string: "https://alipan.com")!,
            expiration: Date().addingTimeInterval(0.05),
            method: "GET")
    }
    
    func getOperationQueue() -> OperationQueue {
        OperationQueue()
    }
    
    func downloadTask(_ task: AliyunpanDownloadTask, didUpdateState state: AliyunpanDownloadTask.State) {}
    
    func downloadTask(task: AliyunpanDownloadTask, didWriteData bytesWritten: Int64) {}
}
