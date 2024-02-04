//
//  GetAsyncTask.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 获取异步任务状态
    public class GetAsyncTask: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/async_task/get"
        }

        public struct Request: Codable {
            /// 异步任务ID
            public let async_task_id: String

            public init(async_task_id: String) {
                self.async_task_id = async_task_id
            }
        }

        public struct Response: Codable {
            /// Succeed 成功，Running 处理中，Failed 已失败
            public let state: String
            /// 异步任务id。
            public let async_task_id: String
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
