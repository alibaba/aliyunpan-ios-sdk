//
//  Client.swift
//  Demo
//
//  Created by zhaixian on 2024/2/20.
//

import Foundation
import AliyunpanSDK

let appId = "YOUR_APP_ID" // 替换成你的 AppID
let scope = "user:base,file:all:read,file:all:write"

/// 调试参数
/// 环境
let environment = Aliyunpan.Environment.product
/// 日志等级
let logLevel = AliyunpanLogLevel.info
/// 运行时清空 token
let cleanToken = true

let client = AliyunpanClient(
    appId: appId,
    scope: scope
)
