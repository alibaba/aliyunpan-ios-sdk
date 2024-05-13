//
//  Demo_visionOSApp.swift
//  Demo-visionOS
//
//  Created by zhaixian on 2024/2/19.
//

import SwiftUI
import AliyunpanSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Aliyunpan.setEnvironment(environment)
        Aliyunpan.setLogLevel(logLevel)
        
        client.cleanToken()
        
        return true
    }
}

@main
struct Demo_visionOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
