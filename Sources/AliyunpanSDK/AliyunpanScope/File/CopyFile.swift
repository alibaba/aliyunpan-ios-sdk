//
//  CopyFile.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 复制文件或文件夹
    public class CopyFile: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/copy"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 父文件ID、根目录为 root
            public let to_parent_file_id: String
            /// 目标drive，默认是当前drive_id
            public let to_drive_id: String?
            /// 当目标文件夹下存在同名文件时，是否自动重命名，默认为 false，默认允许同名文件
            public let auto_rename: Bool?

            public init(drive_id: String, file_id: String, to_parent_file_id: String, to_drive_id: String? = nil, auto_rename: Bool? = nil) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.to_parent_file_id = to_parent_file_id
                self.to_drive_id = to_drive_id
                self.auto_rename = auto_rename
            }
        }

        public struct Response: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 异步任务id。当复制的是文件时，不返回该字段；当复制的是文件夹时，为后台异步复制，会返回该字段
            public var async_task_id: String?
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
