//
//  GetVipInfo.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanUserScope {
	/// 获取用户vip信息
	public class GetVipInfo: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .post }
		public var uri: String {
			"/v1.0/user/getVipInfo"
		}

		public typealias Request = Void

		public struct Response: Codable {
			/// 枚举：member, vip, svip
			public let identity: String
			/// 过期时间，时间戳，单位秒
			public let expire: TimeInterval?
			/// 20t、8t
			public var level: String?
		}
        
        public init() {}
	}
}
