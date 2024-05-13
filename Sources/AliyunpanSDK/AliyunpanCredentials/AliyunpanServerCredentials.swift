//
//  AliyunpanServerCredentials.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/21.
//

import Foundation

/// 三方业务 Server 抽象协议
public protocol AliyunpanBizServer {
    /// 根据 appId、authCode 请求 token
    func requestToken(appId: String, authCode: String) async throws -> AliyunpanToken
}

class AliyunpanServerCredentials: AliyunpanCredentialsProtocol {
    private let server: AliyunpanBizServer
    
    init(_ server: AliyunpanBizServer) {
        self.server = server
    }

    func authorize(appId: String, scope: String) async throws -> AliyunpanToken {
        let redirectUri = try await HTTPRequest(
            command:
                AliyunpanScope.Internal.Authorize(
                    .init(
                        client_id: appId,
                        redirect_uri: "oob",
                        scope: scope,
                        response_type: "code",
                        auto_login: "true")))
            .response()
            .redirectUri
        
        let authenticator = AliyunpanAuthenticator()
        let authCode = try await authenticator.authorize(redirectUri)
        
        var token = try await server.requestToken(appId: appId, authCode: authCode)
        token.expires_in += Date().timeIntervalSince1970
        return token
    }
}
