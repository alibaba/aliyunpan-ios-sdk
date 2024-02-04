//
//  BatchGet.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 批量获取文件详情
    public class BatchGet: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/batch/get"
        }

        public struct Request: Codable {
            public struct Item: Codable {
                public let drive_id: String
                public let file_id: String

                public init(drive_id: String, file_id: String) {
                    self.drive_id = drive_id
                    self.file_id = file_id
                }
            }

            public let file_list: [Item]

            public init(file_list: [Item]) {
                self.file_list = file_list
            }
        }

        public struct Response: Codable {
            public let items: [AliyunpanFile]
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
