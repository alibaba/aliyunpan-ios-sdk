//
//  GetVideoRecentList.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanVideoScope {
    /// 获取最近播放列表
    public class GetVideoRecentList: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.1/openFile/video/recentList"
        }

        public struct Request: Codable {
            /// 缩略图宽度
            public let video_thumbnail_width: Int?

            public init(video_thumbnail_width: Int? = nil) {
                self.video_thumbnail_width = video_thumbnail_width
            }
        }

        public struct Response: Codable {
            public let items: [AliyunpanFile]
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
