//
//  AliyunpanSDK.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/16.
//

import Foundation

public class Aliyunpan {
    public enum Environment {
        /// 预发
        case pre
        /// 线上
        case product
        
        var host: String {
            switch self {
            case .pre:
                return "https://stg-openapi.alipan.com"
            case .product:
                return "https://openapi.alipan.com"
            }
        }
    }
    
    /// 是否已安装阿里云盘
    @MainActor
    public static var isInstalled: Bool {
        guard let url = URL(string: "smartdrive://") else {
            return false
        }
        return Platform.canOpenURL(url)
    }
    
    private(set) static var logLevel: AliyunpanLogLevel = .warn
    public static func setLogLevel(_ level: AliyunpanLogLevel) {
        logLevel = level
    }
    
    public private(set) static var env: Environment = .product

    #if DEBUG
    public static func setEnvironment(_ env: Environment) {
        self.env = env
    }
    #endif
    
    @discardableResult
    public static func handleOpenURL(_ url: URL) -> Bool {
        AliyunpanAuthenticator.handle(url: url)
    }
}

let version = "0.3.5"
