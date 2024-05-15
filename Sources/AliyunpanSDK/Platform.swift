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

import AuthenticationServices

class Platform: NSObject {
    @MainActor
    static func canOpenURL(_ url: URL) -> Bool {
#if canImport(UIKit) || canImport(TVUIKit)
        return UIApplication.shared.canOpenURL(url)
#endif
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        return NSWorkspace.shared.urlForApplication(toOpen: url) != nil
#endif
    }
    
    @MainActor
    static func open(_ url: URL) async {
#if canImport(UIKit) || canImport(TVUIKit)
        await UIApplication.shared.open(url)
#endif
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        NSWorkspace.shared.open(url)
#endif
    }
    
    @MainActor
    static var mainPresentationAnchor: ASPresentationAnchor {
#if canImport(UIKit) || canImport(TVUIKit)
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.windows.first ?? ASPresentationAnchor()
#endif
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        return NSApplication.shared.mainWindow ?? ASPresentationAnchor()
#endif
    }
}
