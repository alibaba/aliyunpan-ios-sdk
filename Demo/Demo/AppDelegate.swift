//
//  AppDelegate.swift
//  Demo
//
//  Created by zhaixian on 2023/11/23.
//

import UIKit
import AliyunpanSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let client: AliyunpanClient = AliyunpanClient(
        .init(
            appId: "YOUR_APP_ID", // 替换成你的 AppID
            scope: "user:base,file:all:read,file:all:write",
            credentials: .pkce))
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        Aliyunpan.setLogLevel(.info)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return Aliyunpan.handleOpenURL(url)
    }
}
