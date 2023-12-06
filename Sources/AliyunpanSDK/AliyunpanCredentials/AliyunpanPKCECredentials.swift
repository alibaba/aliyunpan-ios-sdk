//
//  AliyunpanPKCECredentials.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/21.
//

import Foundation

class AliyunpanPKCECredentials: AliyunpanCredentialsProtocol {
    private let jumper = AliyunpanAppJumper()

    let codeVerifier: String
    let codeChallenge: String
    
    init() {
        codeVerifier = "\(Int.random(in: 43...128))"
        codeChallenge = AliyunpanCrypto.sha256AndBase64(codeVerifier)
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
                        code_challenge: codeChallenge,
                        code_challenge_method: "S256")))
            .response()
            .redirectUri
        let authCode = try await jumper.jump(to: redirectUri)
        var token = try await HTTPRequest(command: AliyunpanScope.Internal.GetAccessToken(
                .init(
                    client_id: appId,
                    grant_type: "authorization_code",
                    code: authCode,
                    code_verifier: codeVerifier)))
            .response()
        token.expires_in += Date().timeIntervalSince1970
        return token
    }
}
