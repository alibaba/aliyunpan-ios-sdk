//
//  AliyunpanToken.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/23.
//

import Foundation

public struct AliyunpanToken: Codable {
    /// Bearer
    public let token_type: String
    /// 用来获取用户信息的access_token。刷新后，旧access_token不会立即失效
    public let access_token: String
    /// 单次有效，用来刷新access_token，90天有效期。刷新后，返回新的refresh_token，请保存以便下一次刷新使用
    public let refresh_token: String?
    /// access_token的过期时间，单位秒
    public internal(set) var expires_in: TimeInterval
    
    /// 是否已过期
    public var isExpired: Bool {
        Date().timeIntervalSince1970 > expires_in
    }
}

extension AliyunpanToken: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(token_type)
        hasher.combine(access_token)
        hasher.combine(refresh_token)
        hasher.combine(expires_in)
    }
}

extension AliyunpanToken: CustomStringConvertible {
    public var description: String {
        """
[AliyunpanToken]
    token_type: \(token_type)
    access_token: \(access_token)
    refresh_token: \(refresh_token ?? "nil")
    expires_in: \(expires_in)
"""
    }
}
