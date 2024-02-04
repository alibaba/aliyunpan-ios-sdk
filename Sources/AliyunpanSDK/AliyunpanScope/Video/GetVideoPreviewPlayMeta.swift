//
//  GetVideoPreviewPlayMeta.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanVideoScope {
    /// 获取文件播放元数据
    public class GetVideoPreviewPlayMeta: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/getVideoPreviewPlayMeta"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// live_transcoding 边转边播
            public let category: String?
            /// 默认所有类型，枚举 LD|SD|HD|FHD|QHD
            public let template_id: String?

            public init(drive_id: String, file_id: String, category: String?, template_id: String?) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.category = category
                self.template_id = template_id
            }
        }

        public struct Response: Codable {
            public let domain_id: String
            public let drive_id: String
            public let file_id: String
            public let video_preview_play_meta: AliyunpanFile.VideoPreviewPlayInfo
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
