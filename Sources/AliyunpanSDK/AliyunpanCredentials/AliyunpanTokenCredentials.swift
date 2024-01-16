//
//  AliyunpanTokenCredentials.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2024/1/16.
//

import Foundation

class AliyunpanTokenCredentials: AliyunpanCredentialsProtocol {
    let token: AliyunpanToken
    
    init(_ token: AliyunpanToken) {
        self.token = token
    }
    
    func authorize(appId: String, scope: String) async throws -> AliyunpanToken {
        token
    }
}
