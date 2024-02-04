//
//  GetStarredList.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
    /// 获取收藏文件列表
    public class GetStarredList: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/adrive/v1.0/openFile/starredList"
        }

        public struct Request: Codable {
            /// drive id
            public let drive_id: String
            /// 默认100，最大 100
            public var limit: Int?
            /// 分页标记
            public var marker: String?
            /// created_at, updated_at, name, size
            public var order_by: OrderBy?
            /// DESC ASC
            public var order_direction: OrderDirection?
            /// 生成的视频缩略图截帧时间，单位ms，默认120000ms
            public var video_thumbnail_time: Int?
            /// 生成的视频缩略图宽度，默认480px
            public var video_thumbnail_width: Int?
            /// 生成的图片缩略图宽度，默认480px
            public var image_thumbnail_width: Int?
            /// file 或 folder  , 默认所有类型
            public var type: AliyunpanFile.FileType?

            public init(drive_id: String, limit: Int? = nil, marker: String? = nil, order_by: OrderBy? = nil, order_direction: OrderDirection? = nil, video_thumbnail_time: Int? = nil, video_thumbnail_width: Int? = nil, image_thumbnail_width: Int? = nil, type: AliyunpanFile.FileType? = nil) {
                self.drive_id = drive_id
                self.limit = limit
                self.marker = marker
                self.order_by = order_by
                self.order_direction = order_direction
                self.video_thumbnail_time = video_thumbnail_time
                self.video_thumbnail_width = video_thumbnail_width
                self.image_thumbnail_width = image_thumbnail_width
                self.type = type
            }
        }

        public struct Response: Codable {
            public let items: [AliyunpanFile]
            /// 下个分页标记
            public var next_marker: String?
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
