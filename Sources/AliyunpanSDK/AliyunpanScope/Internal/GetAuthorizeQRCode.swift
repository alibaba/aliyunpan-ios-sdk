//
//  GetAuthorizeQRCode.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/14.
//

import Foundation

extension AliyunpanInternalScope {
    /// 将用户浏览器重定向到云盘登录授权页面上
    public class GetAuthorizeQRCode: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .post }
        public var uri: String {
            "/oauth/authorize/qrcode"
        }

        public struct Request: Codable {
            /// 创建应用时分配的appId
            public let client_id: String
            /// 申请的授权范围，多个用逗号分隔（示例：user:base,file:all:read）
            public let scopes: [String]
            public let code_challenge: String?
            public let code_challenge_method: String?

            public init(client_id: String, scopes: [String], code_challenge: String?, code_challenge_method: String?) {
                self.client_id = client_id
                self.scopes = scopes
                self.code_challenge = code_challenge
                self.code_challenge_method = code_challenge_method
            }
        }

        public struct Response: Codable {
            public let qrCodeUrl: URL
            public let sid: String
        }

        public let request: Request?
        public init(_ request: Request) {
            self.request = request
        }
    }
}
