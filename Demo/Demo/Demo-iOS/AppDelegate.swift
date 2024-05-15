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
    func applicationDidFinishLaunching(_ application: UIApplication) {
        Aliyunpan.setEnvironment(environment)
        Aliyunpan.setLogLevel(logLevel)
        
        client.cleanToken()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Aliyunpan.handleOpenURL(url)
    }
}
