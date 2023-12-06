//
//  TrashFileToRecyclebin.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanFileScope {
	/// 放入回收站
	public class TrashFileToRecyclebin: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .post }
		public var uri: String {
			"/adrive/v1.0/openFile/recyclebin/trash"
		}

		public struct Request: Codable {
			/// drive id
			public let drive_id: String
			/// file_id
			public let file_id: String
            
            public init(drive_id: String, file_id: String) {
                self.drive_id = drive_id
                self.file_id = file_id
            }
		}

		public struct Response: Codable {
			/// drive id
			public let drive_id: String
			/// file_id
			public let file_id: String
			/// 异步任务id，有的话表示需要经过异步处理。
			public var async_task_id: String?
		}

		public let request: Request?
		public init(_ request: Request) {
			self.request = request
		}
	}
}
