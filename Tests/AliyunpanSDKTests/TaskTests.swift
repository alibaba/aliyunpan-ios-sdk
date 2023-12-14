//
//  TaskTests.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/15.
//

import Foundation
import XCTest
@testable import AliyunpanSDK

class TaskTests: XCTestCase {
    func testTimeout() async throws {
        do {
            let _ = try await withTimeout(seconds: 2) {
                try await Task.sleep(nanoseconds: UInt64(3 * 1_000_000_000))
                return 1
            }
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
        
        let value1 = try await withTimeout(seconds: 2) {
            Task {
                try await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
                return 1
            }
        }.value
        XCTAssertEqual(1, value1)
        
        let value2 = try await withTimeout(seconds: 2) {
            Task {
                try await Task.sleep(nanoseconds: UInt64(1 * 1_000_000_000))
                return 1
            }
        }.value
        XCTAssertEqual(1, value2)
    }
}
