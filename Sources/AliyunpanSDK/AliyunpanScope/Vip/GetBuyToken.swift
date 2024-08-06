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

        public struct Request: Codable {
            public init() {}
        }

        public struct Response: Codable {
            /// 充值用户的身份标记
            public let token: String
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
