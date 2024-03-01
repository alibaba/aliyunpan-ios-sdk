//
//  GetVipFeatureList.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanVIPScope {
    /// 开始试用付费功能
    public class GetVipFeatureList: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .get }
        public var uri: String {
            "/business/v1.0/vip/feature/list"
        }

        public typealias Request = Void

        public struct Response: Codable {
            public struct FeatureItem: Codable {
                /// 付费功能标记
                public let code: String
                /// 是否拦截
                public let intercept: Bool
                /// noTrial 不允许试用
                /// onTrial 试用中
                /// endTrial 试用结束
                /// allowTrial 允许试用，还未开始
                public let trialStatus: String
                /// 允许试用的时间，单位分钟。
                public let trialDuration: Int
                /// 开始试用的时间戳
                public let trialStartTime: TimeInterval?
            }

            /// 付费功能数组
            public let result: [FeatureItem]
        }

        public init() {}
    }
}
