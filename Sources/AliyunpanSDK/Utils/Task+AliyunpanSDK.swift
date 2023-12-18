//
//  Task+AliyunpanSDK.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/14.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async throws {
        try await sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

/// https://forums.swift.org/t/running-an-async-task-with-a-timeout/49733/28
@discardableResult
public func withTimeout<R>(
    seconds: TimeInterval,
    operation: @escaping @Sendable () async throws -> R
) async throws -> R {
    return try await withThrowingTaskGroup(of: R.self) { group in
        defer {
            group.cancelAll()
        }
        
        group.addTask {
            let result = try await operation()
            try Task.checkCancellation()
            return result
        }
        
        group.addTask {
            if seconds > 0 {
                try await Task.sleep(seconds: seconds)
            }
            try Task.checkCancellation()
            throw CancellationError()
        }
        
        if let result = try await group.next() {
            return result
        } else {
            throw CancellationError()
        }
    }
}
