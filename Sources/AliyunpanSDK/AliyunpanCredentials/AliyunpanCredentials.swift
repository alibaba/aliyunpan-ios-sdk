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
    /// PKCE 授权
    /// https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-proof-key-for-code-exchange-pkce
    case pkce
    /// 标准授权，有 Server 的业务才可使用
    case server(AliyunpanBizServer)
    
    var implement: AliyunpanCredentialsProtocol {
        switch self {
        case .pkce:
            return AliyunpanPKCECredentials()
        case .server(let server):
            return AliyunpanServerCredentials(server)
        }
    }
}
