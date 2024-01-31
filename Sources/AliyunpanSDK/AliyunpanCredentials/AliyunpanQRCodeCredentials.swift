//
//  AliyunpanQRCodeCredentials.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/14.
//

import Foundation

/// 二维码授权容器协议
public protocol AliyunpanQRCodeContainer {
    /// 展示二维码
    @MainActor func showAliyunpanAuthorizeQRCode(with url: URL)
    
    /// 授权状态发生变化，可以在这里做一些 UI 变更
    @MainActor func authorizeQRCodeStatusUpdated(_ status: AliyunpanAuthorizeQRCodeStatus)
}

class AliyunpanQRCodeCredentials: AliyunpanCredentialsProtocol {
    let codeVerifier: String
    let codeChallenge: String
    
    private let container: AliyunpanQRCodeContainer
    
    init(_ container: AliyunpanQRCodeContainer) {
        codeVerifier = "\(Int.random(in: 43...128))"
        codeChallenge = AliyunpanCrypto.sha256AndBase64(codeVerifier)
        self.container = container
    }
    
    private func pollingWaitAuthorize(sid: String, timeout: TimeInterval) -> AsyncThrowingStream<(status: AliyunpanAuthorizeQRCodeStatus, authCode: String?), Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    try await withTimeout(seconds: timeout) {
                        var authCode: String?
                        while authCode == nil, !Task.isCancelled {
                            let response = try? await HTTPRequest(
                                command:
                                    AliyunpanScope.Internal.GetAuthorizeQRCodeStatus(sid: sid))
                                .response()
                            
                            if response?.status == .qrCodeExpired {
                                throw CancellationError()
                            }
                            
                            if let response {
                                authCode = response.authCode
                                let status = response.status
                                continuation.yield((status, authCode))
                            }
                            
                            if authCode == nil {
                                try await Task.sleep(seconds: 1)
                            }
                        }
                        continuation.finish()
                    }
                } catch is CancellationError {
                    continuation.finish(throwing: AliyunpanError.AuthorizeError.qrCodeAuthorizeTimeout)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
        
    }
    
    func authorize(appId: String, scope: String) async throws -> AliyunpanToken {
        // 请求二维码
        let response = try await HTTPRequest(
            command:
                AliyunpanScope.Internal.GetAuthorizeQRCode(
                    .init(
                        client_id: appId,
                        scopes: Array(scope.split(separator: ",").map { String($0) }),
                        code_challenge: codeChallenge,
                        code_challenge_method: "S256")))
            .response()
        
        // 展示二维码
        await container.showAliyunpanAuthorizeQRCode(with: response.qrCodeUrl)
        
        // 轮询等待，180s有效
        var authCode: String?
        for try await result in pollingWaitAuthorize(sid: response.sid, timeout: 180) {
            authCode = result.authCode
            let status = result.status
            await container.authorizeQRCodeStatusUpdated(status)
        }
        
        if let authCode {
            // authcode 换 token
            var token = try await HTTPRequest(command: AliyunpanScope.Internal.GetAccessToken(
                    .init(
                        client_id: appId,
                        grant_type: "authorization_code",
                        code: authCode,
                        code_verifier: codeVerifier)))
                .response()
            token.expires_in += Date().timeIntervalSince1970
            return token
        } else {
            // 实际不会走到
            throw AliyunpanError.AuthorizeError.qrCodeAuthorizeTimeout
        }
    }
}
