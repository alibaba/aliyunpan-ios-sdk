//
//  GetFileDownloadUrl.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
	/// 获取文件下载详情
	public class GetFileDownloadUrl: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .post }
		public var uri: String {
			"/adrive/v1.0/openFile/getDownloadUrl"
		}

		public struct Request: Codable {
			/// drive id
			public let drive_id: String
			/// file_id
			public let file_id: String
			/// 下载地址过期时间，单位为秒，默认为 900 秒, 最长4h（14400秒）
			public var expire_sec: Int?
            
            public init(drive_id: String, file_id: String, expire_sec: Int? = nil) {
                self.drive_id = drive_id
                self.file_id = file_id
                self.expire_sec = expire_sec
            }
		}

		public struct Response: Codable {
			/// 下载地址
			public let url: URL
			/// 过期时间 格式：yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
			public let expiration: Date
			/// 下载方法
			public let method: String
		}

		public let request: Request?
		public init(_ request: Request) {
			self.request = request
		}
	}
}
