//
//  GetVipFeatureTrial.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanVIPScope {
	/// 开始试用付费功能
	public class GetVipFeatureTrial: AliyunpanCommand {
		public var httpMethod: HTTPMethod { .post }
		public var uri: String {
			"/business/v1.0/vip/feature/trial"
		}

		public struct Request: Codable {
			/// 付费功能。枚举列表
			public let featureCode: String
            
            public init(featureCode: String) {
                self.featureCode = featureCode
            }
		}

		public struct Response: Codable {
			/// noTrial 不允许试用 onTrial 试用中 endTrial 试用结束 allowTrial 允许试用，还未开始
			public let trialStatus: String
			/// 允许试用的时间，单位分钟。
			public let trialDuration: Int
			/// 开始试用的时间戳
			public let trialStartTime: Int
		}

		public let request: Request?
		public init(_ request: Request) {
			self.request = request
		}
	}
}
