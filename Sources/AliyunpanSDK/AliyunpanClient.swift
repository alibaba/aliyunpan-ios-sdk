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
    /// 鉴权方式
    public let credentials: AliyunpanCredentials
    /// 业务方自定义 id，可实现账号互绑
    public var identifier: String?
    
    /// - Parameters:
    ///   - appId: 应用 ID
    ///   - scope: 申请权限
    ///   - identifier: 业务方自定义 id
    ///   - credentials: 鉴权方式
    public init(appId: String, scope: String, identifier: String? = nil, credentials: AliyunpanCredentials) {
        self.appId = appId
        self.scope = scope
        self.identifier = identifier
        self.credentials = credentials
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
    
    public init(_ config: AliyunpanClientConfig) {
        self.config = config
        
        if let tokenData = UserDefaults.standard.data(forKey: tokenStorageKey) {
            self.token = try? JSONParameterDecoder().decode(AliyunpanToken.self, from: tokenData)
        }
    }
    
    /// 强制清除 token 持久化
    @MainActor public func cleanToken() {
        token = nil
    }
    
    /// 授权
    /// 如本地持久化有效会取持久化，否则会开始授权
    /// send 方法中会自动调用，通常无需主动调用该方法
    @discardableResult
    public func authorize() async throws -> AliyunpanToken {
        if let token = await token, !token.isExpired {
            return token
        }
        let token = try await config.credentials.implement.authorize(
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
        let accessToken = try await authorize().access_token
        do {
            let result = try await HTTPRequest(command: command)
                .headers([.authorization(bearerToken: accessToken)])
                .response()
            return result
        } catch {
            /// 授权过期重试
            if let error = error as? AliyunpanError.ServerError,
               error.isAccessTokenInvalidOrExpired {
                await MainActor.run { [weak self] in
                    self?.token = nil
                }
                return try await send(command)
            } else {
                throw error
            }
        }
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
