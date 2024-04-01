//
//  AliyunpanClient.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/22.
//

import Foundation

public struct AliyunpanClientConfig {
    /// 应用 ID
    public let appId: String
    /// 申请权限
    public let scope: String
    /// 业务方自定义 id，可实现账号互绑
    public var identifier: String?
    
    /// - Parameters:
    ///   - appId: 应用 ID
    ///   - scope: 申请权限
    ///   - identifier: 业务方自定义 id
    public init(appId: String, scope: String, identifier: String? = nil) {
        self.appId = appId
        self.scope = scope
        self.identifier = identifier
    }
}

public class AliyunpanClient {
    private let config: AliyunpanClientConfig
    
    private var tokenStorageKey: String {
        "com.aliyunpanSDK.accessToken_\(config.appId)_\(config.identifier ?? "-")"
    }
    
    @MainActor var token: AliyunpanToken? {
        willSet {
            if token != newValue,
               let data = try? JSONParameterEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: tokenStorageKey)
            }
        }
    }
    
    /// 获取当前持久化的 accessToken
    @MainActor public var accessToken: String? {
        token?.access_token
    }
    
    /// 下载器
    public lazy var downloader: AliyunpanDownloader = {
        let downloader = AliyunpanDownloader()
        downloader.client = self
        return downloader
    }()
    
    /// 上传器
    public lazy var uploader: AliyunpanUploader = {
        let uploader = AliyunpanUploader()
        uploader.client = self
        return uploader
    }()
    
    public init(_ config: AliyunpanClientConfig) {
        self.config = config
        
        if let tokenData = UserDefaults.standard.data(forKey: tokenStorageKey) {
            token = try? JSONParameterDecoder().decode(AliyunpanToken.self, from: tokenData)
        }
    }
    
    public convenience init(appId: String, scope: String, identifier: String? = nil) {
        self.init(.init(appId: appId, scope: scope, identifier: identifier))
    }
    
    /// 强制清除 token 持久化
    @MainActor public func cleanToken() {
        token = nil
    }
    
    /// 授权
    /// 如本地持久化未过期会取持久化，否则会开始授权
    /// - Parameter credentials: 授权方式
    /// - Returns: token
    @discardableResult
    public func authorize(
        credentials: AliyunpanCredentials = .pkce
    ) async throws -> AliyunpanToken {
        if let token = await token, !token.isExpired {
            return token
        }
        let token = try await credentials.implement.authorize(
            appId: config.appId,
            scope: config.scope
        )
        await MainActor.run { [weak self] in
            self?.token = token
        }
        return token
    }
    
    /// 发送请求
    ///
    /// - throws:
    ///     `DecodingError`: JSON 解析错误
    ///     `AliyunpanAuthorizeError`: 授权错误
    ///     `AliyunpanServerError`: 服务端错误
    ///     `AliyunpanNetworkSystemError`: 网络系统错误
    public func send<T: AliyunpanCommand>(_ command: T) async throws -> T.Response where T.Response: Decodable {
        guard let token = await token else {
            throw AliyunpanError.AuthorizeError.accessTokenInvalid
        }
        return try await token.send(command)
    }
    
    /// 发送请求
    ///
    /// - throws:
    ///     `DecodingError`: JSON 解析错误
    ///     `AliyunpanAuthorizeError`: 授权错误
    ///     `AliyunpanServerError`: 服务端错误
    ///     `AliyunpanNetworkSystemError`: 网络系统错误
    public func send<T: AliyunpanCommand>(
        _ command: T,
        completionHandle: @escaping (Result<T.Response, Error>) -> Void) where T.Response: Decodable {
        Task {
            do {
                let response = try await send(command)
                completionHandle(.success(response))
            } catch {
                completionHandle(.failure(error))
            }
        }
    }
}

extension AliyunpanToken {
    /// 发送请求
    ///
    /// - throws:
    ///     `DecodingError`: JSON 解析错误
    ///     `AliyunpanAuthorizeError`: 授权错误
    ///     `AliyunpanServerError`: 服务端错误
    ///     `AliyunpanNetworkSystemError`: 网络系统错误
    public func send<T: AliyunpanCommand>(_ command: T) async throws -> T.Response where T.Response: Decodable {
        let result = try await HTTPRequest(command: command)
            .headers([.authorization(bearerToken: access_token)])
            .response()
        return result
    }
    
    /// 发送请求
    ///
    /// - throws:
    ///     `DecodingError`: JSON 解析错误
    ///     `AliyunpanAuthorizeError`: 授权错误
    ///     `AliyunpanServerError`: 服务端错误
    ///     `AliyunpanNetworkSystemError`: 网络系统错误
    public func send<T: AliyunpanCommand>(
        _ command: T,
        completionHandle: @escaping (Result<T.Response, Error>) -> Void) where T.Response: Decodable {
        Task {
            do {
                let response = try await send(command)
                completionHandle(.success(response))
            } catch {
                completionHandle(.failure(error))
            }
        }
    }
}
