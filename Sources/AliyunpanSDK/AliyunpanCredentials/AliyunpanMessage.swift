//
//  File.swift
//  
//
//  Created by zhaixian on 2023/11/27.
//

import Foundation

class AliyunpanMessage {
    let state: String
    let action: String
    let originalURL: URL
    
    init(_ url: URL) throws {
        guard url.scheme?.lowercased().starts(with: "smartdrive") == true else {
            throw AliyunpanAuthorizeError.invaildAuthorizeURL
        }
        let queryItems = url.queryItems
        self.originalURL = url
        self.action = url.host ?? ""
        self.state = queryItems.first(where: { $0.name == "state" })?.value ?? "Unknown"
    }
    
    var id: String {
        "\(action)_\(state)"
    }
}

class AliyunpanAuthorizeMessage: AliyunpanMessage {
    let authCode: String?
    let error: String?
    let errorMsg: String?
    
    override init(_ url: URL) throws {
        let queryItems = url.queryItems
        self.authCode = queryItems.first(where: { $0.name == "code" })?.value
        self.error = queryItems.first(where: { $0.name == "error" })?.value
        self.errorMsg = queryItems.first(where: { $0.name == "errorMsg" })?.value
        try super.init(url)
    }
}
