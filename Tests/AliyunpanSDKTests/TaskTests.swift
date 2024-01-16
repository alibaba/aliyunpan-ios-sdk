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
            let _ = try await withTimeout(seconds: 0.05) {
                try await Task.sleep(seconds: 0.1)
                return 1
            }
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
        
        let value1 = try await withTimeout(seconds: 0.05) {
            Task {
                try await Task.sleep(seconds: 0.05)
                return 1
            }
        }.value
        XCTAssertEqual(1, value1)
        
        let value2 = try await withTimeout(seconds: 0.05) {
            Task {
                try await Task.sleep(seconds: 0.025)
                return 1
            }
        }.value
        XCTAssertEqual(1, value2)
    }
}
