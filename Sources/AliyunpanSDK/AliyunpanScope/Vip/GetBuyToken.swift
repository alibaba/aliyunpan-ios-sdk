//
//  GetBuyToken.swift
//  Pods
//
//  Created by BM on 2024/8/5.
//

extension AliyunpanVIPScope {
    /// 开始试用付费功能
    public class GetBuyToken: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/business/v1/openUser/getBuyToken"
        }

        public typealias Request = Void

        public struct Response: Codable {
            /// 充值用户的身份标记
            public let token: String
        }

        public init() {}
    }
}
