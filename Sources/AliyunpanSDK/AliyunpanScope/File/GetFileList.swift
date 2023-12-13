//
//  GetFileList.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
	/// 获取文件列表
	public class GetFileList: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .post }
		public var uri: String {
			"/adrive/v1.0/openFile/list"
		}

		public struct Request: Codable {
			/// drive id
			public let drive_id: String
			/// 根目录为root
			public let parent_file_id: String
			/// 返回文件数量，默认 50，最大 100
			public var limit: Int?
			/// 分页标记
			public var marker: String?
			/// created_at, updated_at, name, size, name_enhanced
			public var order_by: OrderBy?
			/// DESC ASC
			public var order_direction: OrderDirection?
			/// 分类，目前有枚举：video | doc | audio | zip | others | image, 可任意组合，按照逗号分割，例如 video,doc,audio, image,doc
            public var category: AliyunpanFile.FileCategory?
			/// all | file | folder， 默认所有类型, type为folder时，category不做检查
            public var type: AliyunpanFile.FileType?
			/// 生成的视频缩略图截帧时间，单位ms，默认120000ms
			public var video_thumbnail_time: Int?
			/// 生成的视频缩略图宽度，默认480px
			public var video_thumbnail_width: Int?
			/// 生成的图片缩略图宽度，默认480px
			public var image_thumbnail_width: Int?
			/// 当填 * 时，返回文件所有字段
			public var fields: String?
            
            public init(drive_id: String, parent_file_id: String, limit: Int? = nil, marker: String? = nil, order_by: OrderBy? = nil, order_direction: OrderDirection? = nil, category: AliyunpanFile.FileCategory? = nil, type: AliyunpanFile.FileType? = nil, video_thumbnail_time: Int? = nil, video_thumbnail_width: Int? = nil, image_thumbnail_width: Int? = nil, fields: String? = nil) {
                self.drive_id = drive_id
                self.parent_file_id = parent_file_id
                self.limit = limit
                self.marker = marker
                self.order_by = order_by
                self.order_direction = order_direction
                self.category = category
                self.type = type
                self.video_thumbnail_time = video_thumbnail_time
                self.video_thumbnail_width = video_thumbnail_width
                self.image_thumbnail_width = image_thumbnail_width
                self.fields = fields
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
