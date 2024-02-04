//
//  UpdateVideoRecord.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanVideoScope {
    /// 更新播放进度
    public class UpdateVideoRecord: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/video/updateRecord"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// 播放进度，单位s，可为小数
            public let play_cursor: String
            /// 视频总时长，单位s，可为小数
            public var duration: String?

            public init(drive_id: String, file_id: String, play_cursor: String, duration: String? = nil) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.play_cursor = play_cursor
                self.duration = duration
            }
        }

        public struct Response: Codable {
            public let domain_id: String
            public let drive_id: String
            public let file_id: String
            public let name: String
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
