//
//  CreateFile.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 创建文件
    public class CreateFile: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/create"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// 根目录为root
            public let parent_file_id: String
            /// 文件名称，按照 utf8 编码最长 1024 字节，不能以 / 结尾
            public let name: String
            /// file | folder
            public let type: AliyunpanFile.FileType
            /// 重名策略
            public let check_name_mode: AliyunpanFile.CheckNameMode
            /// 最大分片数量 10000
            public let part_info_list: [AliyunpanFile.PartInfo]?
            /// 仅上传livp格式的时候需要，常见场景不需要
            public let streams_info: AliyunpanFile.StreamsInfo?
            /// 针对大文件sha1计算非常耗时的情况， 可以先在读取文件的前1k的sha1， 如果前1k的sha1没有匹配的， 那么说明文件无法做秒传， 如果1ksha1有匹配再计算文件sha1进行秒传，这样有效边避免无效的sha1计算。
            public let pre_hash: String?
            /// 秒传必须, 文件大小，单位为 byte
            public let size: Int?
            /// 秒传必须, 文件内容 hash 值，需要根据 content_hash_name 指定的算法计算，当前都是sha1算法
            public let content_hash: String?
            /// 秒传必须, 默认都是 sha1
            public let content_hash_name: String?
            /// 秒传必须
            public let proof_code: String?
            /// 固定 v1
            public let proof_version: String?
            /// 本地创建时间，格式yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
            public let local_created_at: Date?
            /// 本地修改时间，格式yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
            public let local_modified_at: Date?

            public init(
                drive_id: String,
                parent_file_id: String,
                name: String,
                type: AliyunpanFile.FileType = .file,
                check_name_mode: AliyunpanFile.CheckNameMode,
                part_info_list: [AliyunpanFile.PartInfo]? = nil,
                streams_info: AliyunpanFile.StreamsInfo? = nil,
                pre_hash: String? = nil,
                size: Int? = nil,
                content_hash: String? = nil,
                content_hash_name: String? = nil,
                proof_code: String? = nil,
                proof_version: String? = nil,
                local_created_at: Date? = nil,
                local_modified_at: Date? = nil) {
                self.drive_id = drive_id
                self.parent_file_id = parent_file_id
                self.name = name
                self.type = type
                self.check_name_mode = check_name_mode
                self.part_info_list = part_info_list
                self.streams_info = streams_info
                self.pre_hash = pre_hash
                self.size = size
                self.content_hash = content_hash
                self.content_hash_name = content_hash_name
                self.proof_code = proof_code
                self.proof_version = proof_version
                self.local_created_at = local_created_at
                self.local_modified_at = local_modified_at
            }
        }

        public struct Response: Codable {
            public let drive_id: String
            public let file_id: String
            public let status: String?
            public let parent_file_id: String
            public let file_name: String
            public let available: Bool?
            /// 是否存在同名文件
            public let exist: Bool?
            /// 是否秒传
            public let rapid_upload: Bool?
            public let part_info_list: [AliyunpanFile.PartInfo]
            /// 创建文件夹返回空
            public var upload_id: String?
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
