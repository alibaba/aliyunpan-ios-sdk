//
//  UpdateFile.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 文件更新
    public class UpdateFile: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/update"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 新的文件名
            public let name: String?
            /// 重名策略
            public let check_name_mode: AliyunpanFile.CheckNameMode?
            /// 收藏 true，移除收藏 false
            public let starred: Bool?

            public init(drive_id: String, file_id: String, name: String? = nil, check_name_mode: AliyunpanFile.CheckNameMode? = nil, starred: Bool? = nil) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.name = name
                self.check_name_mode = check_name_mode
                self.starred = starred
            }
        }

        public typealias Response = AliyunpanFile

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
