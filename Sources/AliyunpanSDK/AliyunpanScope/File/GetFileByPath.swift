//
//  GetFileByPath.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
	/// 根据文件路径查找文件
	public class GetFileByPath: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .post }
		public var uri: String {
			"/adrive/v1.0/openFile/get_by_path"
		}

		public struct Request: Codable {
			/// drive id
			public let drive_id: String
			/// file_path
			public let file_path: String
            
            init(drive_id: String, file_path: String) {
                self.drive_id = drive_id
                self.file_path = file_path
            }
		}

		public typealias Response = AliyunpanFile

		public let request: Request?
		public init(_ request: Request) {
			self.request = request
		}
	}
}
