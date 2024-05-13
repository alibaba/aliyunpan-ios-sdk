//
//  AliyunpanMessage.swift
//  
//
//  Created by zhaixian on 2023/11/27.
//

import Foundation

class AliyunpanMessage {
    let state: String
    let originalURL: URL
    
    init(_ url: URL) throws {
        let isSmartDriveScheme = url.scheme?.lowercased().starts(with: "smartdrive") == true
        let isSmartDriveUniversalLink = url.host?.hasSuffix(".alipan.com") == true
        guard isSmartDriveScheme || isSmartDriveUniversalLink else {
            throw AliyunpanError.AuthorizeError.invalidAuthorizeURL
        }
        let queryItems = url.queryItems
        originalURL = url
        state = queryItems.first(where: { $0.name == "state" })?.value ?? "Unknown"
    }
}

class AliyunpanAuthorizeMessage: AliyunpanMessage {
    let authCode: String?
    let error: String?
    let errorMsg: String?
    
    override init(_ url: URL) throws {
        let queryItems = url.queryItems
        authCode = queryItems.first(where: { $0.name == "code" })?.value
        error = queryItems.first(where: { $0.name == "error" })?.value
        errorMsg = queryItems.first(where: { $0.name == "errorMsg" })?.value
        try super.init(url)
    }
}
