//
//  GetAccessToken.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanInternalScope {
    /// 通过code获取access_token或通过refresh_token刷新access_token。code10分钟内有效，只能用一次
    public class GetAccessToken: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/oauth/access_token"
        }

        public struct Request: Codable {
            /// 应用标识，创建应用时分配的appId
            public let client_id: String
            /// 身份类型 authorization_code 或 refresh_token
            public let grant_type: String
            /// 授权码
            public let code: String?
            /// 应用密钥，创建应用时分配的secret
            public let client_secret: String?
            /// 刷新token，单次请求有效
            public let refresh_token: String?
            /// pkce code_verifier
            public let code_verifier: String?

            public init(client_id: String, grant_type: String, code: String? = nil, client_secret: String? = nil, refresh_token: String? = nil, code_verifier: String? = nil) {
                self.client_id = client_id
                self.grant_type = grant_type
                self.code = code
                self.client_secret = client_secret
                self.refresh_token = refresh_token
                self.code_verifier = code_verifier
            }
        }

        public typealias Response = AliyunpanToken

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
