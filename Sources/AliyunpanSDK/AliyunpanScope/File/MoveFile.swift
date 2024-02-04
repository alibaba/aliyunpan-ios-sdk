//
//  MoveFile.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 移动文件或文件夹
    public class MoveFile: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/move"
        }

        public struct Request: Codable {
            /// 当前drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 父文件ID、根目录为 root
            public let to_parent_file_id: String
            /// 目标drive，默认是当前drive_id 目前只能在当前drive操作
            public let to_drive_id: String?
            /// 重名策略，默认为 .refuse
            public let check_name_mode: AliyunpanFile.CheckNameMode?
            /// 当云端存在同名文件时，使用的新名字
            public let new_name: String?

            public init(drive_id: String, file_id: String, to_parent_file_id: String, to_drive_id: String? = nil, check_name_mode: AliyunpanFile.CheckNameMode? = nil, new_name: String? = nil) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.to_parent_file_id = to_parent_file_id
                self.to_drive_id = to_drive_id
                self.check_name_mode = check_name_mode
                self.new_name = new_name
            }
        }

        public struct Response: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 文件是否已存在
            public let exist: Bool
            /// 异步任务id。如果返回为空字符串，表示直接移动成功。如果返回非空字符串，表示需要经过异步处理。
            public var async_task_id: String?
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
