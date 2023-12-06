//
//  GetFile.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
	/// 获取文件详情
	public class GetFile: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .post }
		public var uri: String {
			"/adrive/v1.0/openFile/get"
		}

		public struct Request: Codable {
			/// drive id
			public let drive_id: String
			/// file_id
			public let file_id: String
			/// 生成的视频缩略图截帧时间，单位ms，默认120000ms
			public var video_thumbnail_time: Int?
			/// 生成的视频缩略图宽度，默认480px
			public var video_thumbnail_width: Int?
			/// 生成的图片缩略图宽度，默认480px
			public var image_thumbnail_width: Int?
            
            public init(drive_id: String, file_id: String, video_thumbnail_time: Int? = nil, video_thumbnail_width: Int? = nil, image_thumbnail_width: Int? = nil) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.video_thumbnail_time = video_thumbnail_time
                self.video_thumbnail_width = video_thumbnail_width
                self.image_thumbnail_width = image_thumbnail_width
            }
		}

		public typealias Response = AliyunpanFile

		public let request: Request?
		public init(_ request: Request) {
			self.request = request
		}
	}
}
