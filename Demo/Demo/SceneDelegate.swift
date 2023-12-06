//
//  SceneDelegate.swift
//  Demo
//
//  Created by zhaixian on 2023/11/23.
//

import UIKit
import AliyunpanSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            Aliyunpan.handleOpenURL(url)
        }
    }
}
