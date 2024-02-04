//
//  GetUsersScopes.swift
//  AliyunpanSDK
//  gen code
//

import Foundation

extension AliyunpanUserScope {
    /// 通过 access_token 获取用户权限信息
    public class GetUsersScopes: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .get }
        public var uri: String {
            "/oauth/users/scopes"
        }

        public typealias Request = Void

        public struct Response: Codable {
            public struct ScopeItem: Codable {
                let scope: String
            }

            /// 用户ID
            public let id: String
            /// 数组为空时，没有权限。
            public let scopes: [ScopeItem]
        }

        public init() {}
    }
}
