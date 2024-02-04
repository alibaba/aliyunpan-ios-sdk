//
//  ListUploadedParts.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 列举已上传分片
    public class ListUploadedParts: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/listUploadedParts"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 文件创建获取的upload_id
            public let upload_id: String
            public var part_number_marker: String?

            public init(drive_id: String, file_id: String, upload_id: String, part_number_marker: String? = nil) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.upload_id = upload_id
                self.part_number_marker = part_number_marker
            }
        }

        public struct Response: Codable {
            /// drive id
            public let drive_id: String
            /// upload_id
            public let upload_id: String
            /// 是否并行上传
            public let parallelUpload: Bool
            /// 已经上传分片列表
            public let uploaded_parts: [AliyunpanFile.PartInfo]
            /// 下一页起始资源标识符, 最后一页该值为空
            public var next_part_number_marker: String?
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
