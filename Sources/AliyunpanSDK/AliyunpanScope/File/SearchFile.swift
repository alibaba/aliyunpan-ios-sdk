//
//  SearchFile.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
	/// 文件搜索
	public class SearchFile: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .post }
		public var uri: String {
			"/adrive/v1.0/openFile/search"
		}

		public struct Request: Codable {
			/// drive id
			public let drive_id: String
			/// 返回文件数量，默认 100，最大100
			public let limit: Int?
			/// 分页标记
			public let marker: String?
			/// 查询语句，样例：固定目录搜索，只搜索一级 parent_file_id = '123' 精确查询 name = '123' 模糊匹配 name match '123' 搜索指定后缀文件 file_extension = 'apk'  范围查询 created_at < '2019-01-14T00:00:00' 复合查询： type = 'folder' or name = '123' parent_file_id = 'root' and name = '123' and category = 'video'
			public let query: String?
			/// created_at ASC | DESC updated_at ASC | DESC name ASC | DESC size ASC | DESC
			public let order_by: String?
			/// 生成的视频缩略图截帧时间，单位ms，默认120000ms
			public let video_thumbnail_time: Int?
			/// 生成的视频缩略图宽度，默认480px
			public let video_thumbnail_width: Int?
			/// 生成的图片缩略图宽度，默认480px
			public let image_thumbnail_width: Int?
			/// 是否返回总数
			public let return_total_count: Bool?
            
            public init(drive_id: String, limit: Int? = nil, marker: String? = nil, query: String? = nil, order_by: String? = nil, video_thumbnail_time: Int? = nil, video_thumbnail_width: Int? = nil, image_thumbnail_width: Int? = nil, return_total_count: Bool? = nil) {
                self.drive_id = drive_id
                self.limit = limit
                self.marker = marker
                self.query = query
                self.order_by = order_by
                self.video_thumbnail_time = video_thumbnail_time
                self.video_thumbnail_width = video_thumbnail_width
                self.image_thumbnail_width = image_thumbnail_width
                self.return_total_count = return_total_count
            }
		}

		public struct Response: Codable {
			public let items: [AliyunpanFile]
			/// 下个分页标记
			public var next_marker: String?
			public var total_count: Int?
		}

		public let request: Request?
		public init(_ request: Request) {
			self.request = request
		}
	}
}
