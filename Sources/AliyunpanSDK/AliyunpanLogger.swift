//
//  AliyunpanLogger.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2024/3/14.
//

import Foundation

public enum AliyunpanLogLevel: Int {
    case debug
    case info
    case warn
    case error
    
    var msg: String {
        switch self {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warn:
            return "⚠️"
        case .error:
            return "❌"
        }
    }
}

class Logger {
    static func log(_ level: AliyunpanLogLevel, msg: String) {
        guard level.rawValue >= Aliyunpan.logLevel.rawValue else {
            return
        }
        print("[AliyunpanSDK][\(level.msg)]\(msg)")
    }
}
