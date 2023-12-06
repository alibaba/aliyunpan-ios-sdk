//
//  DownloaderTests.swift
//  AliyunpanSDKTests
//
//  Created by zhaixian on 2023/12/6.
//

import XCTest
@testable import AliyunpanSDK

extension AliyunpanDownloader.DownloadChunk: Equatable {
    public static func == (lhs: AliyunpanDownloader.DownloadChunk, rhs: AliyunpanDownloader.DownloadChunk) -> Bool {
        lhs.start == rhs.start && lhs.end == rhs.end
    }
}

class DownloaderTests: XCTestCase {
    func testURLExtension() throws {
        let downloader = AliyunpanDownloader(
            url: URL(string: "http://alipan.com")!,
            size: 12_345_678,
            destination: FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!,
            maxConcurrentOperationCount: 10)
        
        let chunks = downloader.chunks
        XCTAssertEqual(chunks[0], .init(start: 0, end: 4_000_000))
        XCTAssertEqual(chunks[1], .init(start: 4_000_000, end: 8_000_000))
        XCTAssertEqual(chunks[2], .init(start: 8_000_000, end: 12_000_000))
        XCTAssertEqual(chunks[3], .init(start: 12_000_000, end: 12_345_678))
        XCTAssertEqual(chunks.count, 4)
    }
}
