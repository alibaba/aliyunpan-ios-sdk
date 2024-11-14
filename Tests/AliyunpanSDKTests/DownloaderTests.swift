//
//  DownloaderTests.swift
//  AliyunpanSDKTests
//
//  Created by zhaixian on 2023/12/6.
//

import XCTest
@testable import AliyunpanSDK

class DownloaderTests: XCTestCase {
    let file = AliyunpanFile(
        drive_id: "drive_id",
        file_id: "file_id",
        parent_file_id: "",
        name: "",
        size: 12_345_678,
        file_extension: nil,
        content_hash: nil,
        type: .file,
        mime_type: nil,
        thumbnail: nil,
        url: nil,
        created_at: nil,
        updated_at: nil,
        play_cursor: nil,
        duration: nil,
        image_media_metadata: nil,
        video_media_metadata: nil)
    
    let destination = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

    func testChunk() {
        let chunk1 = AliyunpanDownloadChunk(rangeString: "bytes=0-999", fileSize: file.size ?? 0)
        XCTAssertEqual(chunk1?.start, 0)
        XCTAssertEqual(chunk1?.end, 1000)

        let chunk2 = AliyunpanDownloadChunk(rangeString: "bytes=1000-", fileSize: file.size ?? 0)
        XCTAssertEqual(chunk2?.start, 1000)
        XCTAssertEqual(chunk2?.end, 12_345_678)

        let chunk3 = AliyunpanDownloadChunk(rangeString: "bytes=-", fileSize: file.size ?? 0)
        XCTAssertNil(chunk3)

        let chunk4 = AliyunpanDownloadChunk(rangeString: "bytes", fileSize: file.size ?? 0)
        XCTAssertNil(chunk4)

        let downloadTask = AliyunpanDownloadTask(
            file: file,
            destination: destination,
            delegate: nil)
        let chunks = downloadTask.chunks
        XCTAssertEqual(chunks[0], .init(start: 0, end: 4_000_000))
        XCTAssertEqual(chunks[1], .init(start: 4_000_000, end: 8_000_000))
        XCTAssertEqual(chunks[2], .init(start: 8_000_000, end: 12_000_000))
        XCTAssertEqual(chunks[3], .init(start: 12_000_000, end: 12_345_678))
        XCTAssertEqual(chunks.count, 4)
    }
}
