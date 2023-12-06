//
//  GetDriveInfo.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanUserScope {
	/// 获取用户信息和drive信息
	public class GetDriveInfo: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .post }
		public var uri: String {
			"/adrive/v1.0/user/getDriveInfo"
		}

		public typealias Request = Void

		public struct Response: Codable {
			/// 用户ID，具有唯一性
			public let user_id: String
			/// 昵称
			public let name: String
			/// 头像地址
			public let avatar: String
			/// 默认drive
			public let default_drive_id: String
			/// 资源库
			public var resource_drive_id: String?
			/// 备份盘
			public var backup_drive_id: String?
		}
        
        public init() {}
	}
}
