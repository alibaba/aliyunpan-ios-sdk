//
//  Platform.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/13.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(TVUIKit)
import TVUIKit
#endif

class Platform {
    
    static func canOpenURL(_ url: URL) -> Bool {
#if canImport(UIKit) || canImport(TVUIKit)
        return UIApplication.shared.canOpenURL(url)
#endif
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        return NSWorkspace.shared.open(url)
#endif
    }
    
    static func open(_ url: URL) async {
#if canImport(UIKit) || canImport(TVUIKit)
        await UIApplication.shared.open(url)
#endif
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        NSWorkspace.shared.open(url)
#endif
    }
}
