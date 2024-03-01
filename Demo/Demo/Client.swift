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

let client = AliyunpanClient(
    appId: appId,
    scope: scope
)
