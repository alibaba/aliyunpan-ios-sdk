//
//  GetUsersInfo.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanUserScope {
	/// 通过 access_token 获取用户信息
	public class GetUsersInfo: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .get }
		public var uri: String {
			"/oauth/users/info"
		}

		public typealias Request = Void

		public struct Response: Codable {
			/// 用户ID，具有唯一性
			public let id: String
			/// 昵称
			public let name: String
			/// 头像地址
			public let avatar: String
			/// 需要联系运营申请 user:phone 权限
			public var phone: String?
		}
        
        public init() {}
	}
}
