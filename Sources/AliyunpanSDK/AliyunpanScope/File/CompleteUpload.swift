//
//  CompleteUpload.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 标记文件上传完毕
    public class CompleteUpload: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/complete"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 文件创建获取的upload_id
            public let upload_id: String

            public init(drive_id: String, file_id: String, upload_id: String) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.upload_id = upload_id
            }
        }

        public typealias Response = AliyunpanFile

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
