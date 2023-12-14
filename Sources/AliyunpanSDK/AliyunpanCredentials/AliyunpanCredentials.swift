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
    /// PKCE 授权，
    /// iOS
    /// https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-proof-key-for-code-exchange-pkce
    case pkce
    /// 标准授权，有 Server 的业务才可使用
    /// iOS
    case server(AliyunpanBizServer)
    /// 二维码授权
    /// iOS、MacOS、tvOS
    case qrCode(AliyunpanQRCodeContainer)
    
    var implement: AliyunpanCredentialsProtocol {
        switch self {
        case .pkce:
            return AliyunpanPKCECredentials()
        case .server(let server):
            return AliyunpanServerCredentials(server)
        case .qrCode(let container):
            return AliyunpanQRCodeCredentials(container)
        }
    }
}
