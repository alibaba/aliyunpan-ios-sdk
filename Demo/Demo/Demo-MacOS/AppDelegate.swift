//
//  AppDelegate.swift
//  Demo-MacOS
//
//  Created by zhaixian on 2023/12/13.
//

import Cocoa
import AliyunpanSDK

@main
class AppDelegate: NSObject, NSApplicationDelegate {    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Aliyunpan.setLogLevel(.info)
    }
}
