//
//  GetUploadURL.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 刷新获取上传地址
    public class GetUploadURL: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/getUploadUrl"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 文件创建获取的upload_id
            public let upload_id: String
            /// 分片信息列表
            public var part_info_list: [AliyunpanFile.PartInfo]?
        }

        public struct Response: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 上传ID
            public let upload_id: String
            /// 格式：yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
            public let created_at: String
            /// 分片信息列表
            public let part_info_list: [AliyunpanFile.PartInfo]
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
