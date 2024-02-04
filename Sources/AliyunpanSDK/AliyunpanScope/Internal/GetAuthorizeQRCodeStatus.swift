//
//  GetAuthorizeQRCodeStatus.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/15.
//

import Foundation

public enum AliyunpanAuthorizeQRCodeStatus: String, Codable {
    /// 等待扫码
    case waitLogin = "WaitLogin"
    /// 扫码成功，待确认
    case scanSuccess = "ScanSuccess"
    /// 授权成功
    case loginSuccess = "LoginSuccess"
    /// 二维码失效
    case qrCodeExpired = "QRCodeExpired"
}

extension AliyunpanInternalScope {
    /// 将用户浏览器重定向到云盘登录授权页面上
    public class GetAuthorizeQRCodeStatus: AliyunpanCommand {
        public var httpMethod: HTTPMethod { .get }
        public var uri: String {
            "/oauth/qrcode/\(sid)/status"
        }

        public struct Response: Codable {
            public let status: AliyunpanAuthorizeQRCodeStatus
            public let authCode: String?
        }

        typealias Request = Void

        let sid: String
        public init(sid: String) {
            self.sid = sid
        }
    }
}
