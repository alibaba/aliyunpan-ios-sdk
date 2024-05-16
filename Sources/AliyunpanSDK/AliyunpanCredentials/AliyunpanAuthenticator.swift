//
//  AliyunpanAuthenticator.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/23.
//

import Foundation
import AuthenticationServices

extension Notification.Name {
    static let hasReceivedMessage = Notification.Name("AliyunpanSDK.Notification.hasReceivedMessage")
}

/// 用于获取 AuthCode
class AliyunpanAuthenticator: NSObject {
    private var webAuthorizeHandler: ((Result<String, Error>) -> Void)?
    
    @MainActor private func openURL(_ url: URL) async {
        await Platform.open(url)
    }
    
    /// 获取 AuthCode
    func authorize(_ url: URL) async throws -> String {
        let isInstalledApp = await Aliyunpan.isInstalled
        
        if isInstalledApp {
            return try await authorize(withAppLink: url)
        } else {
            // sso 授权
            return try await authorize(withSSO: url)
        }
    }
    
    /// 根据 AppLink 获取 AuthCode
    @MainActor
    func authorize(withAppLink appLink: URL) async throws -> String {
        var observer: NSObjectProtocol?
        defer {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
        await openURL(appLink)
        
        let result = try await withCheckedThrowingContinuation { continuation in
            observer = NotificationCenter.default.addObserver(forName: .hasReceivedMessage, object: nil, queue: nil) { notification in
                guard let authMessage = notification.object as? AliyunpanAuthorizeMessage else {
                    return
                }
                if let authCode = authMessage.authCode {
                    continuation.resume(with: .success(authCode))
                } else {
                    continuation.resume(with: .failure(
                        AliyunpanError.AuthorizeError.authorizeFailed(
                            error: authMessage.error,
                            errorMsg: authMessage.errorMsg)))
                }
            }
        }
        return result
    }
        
    @MainActor
    func authorize(withSSO url: URL) async throws -> String {
        let urlString = url.absoluteString.replacingOccurrences(
            of: "alipan.com/applink/authorize",
            with: "alipan.com/o/oauth/authorize")
        // TODO: - auto_login 服务修复后需要去除主动 auto_login 参数
        guard let url = URL(string: urlString + "&source=app_link&auto_login=true") else {
            throw AliyunpanError.AuthorizeError.invalidAuthorizeURL
        }
        return try await startAuthenticationSession(url)
    }
    
    func startAuthenticationSession(_ url: URL) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            if #available(iOS 13, macOS 10.15, tvOS 16.0, visionOS 1, *) {
                let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "smartdrive") { url, error in
                    if let error {
                        continuation.resume(with: .failure(error))
                        return
                    }
                    
                    let components = URLComponents(string: url?.absoluteString ?? "")
                    if let code = components?.queryItems?.first(where: { $0.name == "code" })?.value {
                        continuation.resume(with: .success(code))
                    } else {
                        continuation.resume(with: .failure(AliyunpanError.AuthorizeError.invalidCode))
                    }
                }
#if canImport(TVUIKit)
#else
                session.presentationContextProvider = self
#endif
                DispatchQueue.main.async {
                    session.start()
                }
            } else {
                continuation.resume(with: .failure(AliyunpanError.AuthorizeError.invalidPlatform))
            }
        }
    }
    
    static func handle(url: URL) -> Bool {
        guard let message = try? AliyunpanAuthorizeMessage(url) else {
            return false
        }
        NotificationCenter.default.post(name: .hasReceivedMessage, object: message)
        return true
    }
}

#if canImport(TVUIKit)
#else
extension AliyunpanAuthenticator: ASWebAuthenticationPresentationContextProviding {
    @MainActor
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        Platform.mainPresentationAnchor
    }
}
#endif
