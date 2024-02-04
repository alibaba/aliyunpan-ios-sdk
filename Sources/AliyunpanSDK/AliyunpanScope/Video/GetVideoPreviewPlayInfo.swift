//
//  GetVideoPreviewPlayInfo.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanVideoScope {
    /// 获取文件播放详情
    public class GetVideoPreviewPlayInfo: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/getVideoPreviewPlayInfo"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// file_id
            public let file_id: String
            /// live_transcoding 边转边播
            public let category: String
            /// 默认true
            public let get_subtitle_info: Bool?
            /// 默认所有类型，枚举 LD|SD|HD|FHD|QHD
            public let template_id: String?
            /// 单位秒，最长4小时，默认15分钟。
            public let url_expire_sec: Int?
            /// 默认fale，为true，仅会员可以查看所有内容
            public let only_vip: Bool?
            /// 是否获取视频的播放进度，默认为false
            public let with_play_cursor: Bool?

            public init(drive_id: String, file_id: String, category: String = "live_transcoding", get_subtitle_info: Bool? = nil, template_id: String? = nil, url_expire_sec: Int? = nil, only_vip: Bool? = nil, with_play_cursor: Bool? = nil) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.category = category
                self.get_subtitle_info = get_subtitle_info
                self.template_id = template_id
                self.url_expire_sec = url_expire_sec
                self.only_vip = only_vip
                self.with_play_cursor = with_play_cursor
            }
        }

        public struct Response: Codable {
            public let domain_id: String?
            public let drive_id: String
            public let file_id: String
            public let video_preview_play_info: AliyunpanFile.VideoPreviewPlayInfo
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
