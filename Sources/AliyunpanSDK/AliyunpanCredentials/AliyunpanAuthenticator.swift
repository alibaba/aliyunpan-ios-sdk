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
        guard let url = URL(string: urlString + "&source=app_link") else {
            throw AliyunpanError.AuthorizeError.invalidAuthorizeURL
        }
        return try await startAuthenticationSession(url)
    }
    
    func startAuthenticationSession(_ url: URL) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
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
            session.presentationContextProvider = self
            DispatchQueue.main.async {
                session.start()
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

extension AliyunpanAuthenticator: ASWebAuthenticationPresentationContextProviding {
    @MainActor
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        Platform.mainPresentationAnchor
    }
}
