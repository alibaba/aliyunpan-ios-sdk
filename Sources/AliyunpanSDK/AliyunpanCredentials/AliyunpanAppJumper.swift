//
//  AliyunpanAppJumper.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/23.
//

import Foundation

extension Notification.Name {
    static let hasReceivedMessage = Notification.Name("AliyunpanSDK.Notification.hasReceivedMessage")
}

/// 用于应用之间跳转
class AliyunpanAppJumper {
    @MainActor private func openURL(_ url: URL) async {
        await Platform.open(url)
    }
    
    func jump(to url: URL) async throws -> String {
        guard await Platform.canOpenURL(url) else {
            throw AliyunpanError.AuthorizeError.notInstalledApp
        }
        
        let message = try AliyunpanMessage(url)
        
        var observer: NSObjectProtocol?
        defer {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
        await openURL(url)
        
        let result = try await withCheckedThrowingContinuation { continuation in
            observer = NotificationCenter.default.addObserver(forName: .hasReceivedMessage, object: nil, queue: nil) { notification in
                guard let authMessage = notification.object as? AliyunpanAuthorizeMessage else {
                    return
                }
                if authMessage.id == message.id {
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
        }
        return result
    }
    
    static func handle(url: URL) -> Bool {
        guard let message = try? AliyunpanAuthorizeMessage(url) else {
            return false
        }
        NotificationCenter.default.post(name: .hasReceivedMessage, object: message)
        return true
    }
}
