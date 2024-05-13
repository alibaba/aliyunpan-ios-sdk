//
//  AliyunpanCredentials.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/21.
//

import Foundation

protocol AliyunpanCredentialsProtocol {
    func authorize(appId: String, scope: String) async throws -> AliyunpanToken
}

public enum AliyunpanCredentials {
    /// PKCE 授权，无需服务端，需要安装阿里云盘客户端
    /// 有阿里云盘客户端会唤端授权，否则会唤起 h5 进行 sso 授权
    /// https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-proof-key-for-code-exchange-pkce
    case pkce
    /// 标准授权，需要服务端
    /// 有阿里云盘客户端会唤端授权，否则会唤起 h5 进行 sso 授权
    case server(AliyunpanBizServer)
    /// 二维码授权，无需服务端，无需安装阿里云盘客户端
    case qrCode(AliyunpanQRCodeContainer)
    /// 手动注入 token
    case token(AliyunpanToken)
    
    var implement: AliyunpanCredentialsProtocol {
        switch self {
        case .pkce:
            return AliyunpanPKCECredentials()
        case .server(let server):
            return AliyunpanServerCredentials(server)
        case .qrCode(let container):
            return AliyunpanQRCodeCredentials(container)
        case .token(let token):
            return AliyunpanTokenCredentials(token)
        }
    }
}
