//
//  ContentView.swift
//  Demo-visionOS
//
//  Created by zhaixian on 2024/2/19.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AliyunpanSDK

struct AuthorizeView: View {
    @State var image = UIImage()
    @State var status: AliyunpanAuthorizeQRCodeStatus?
    @State var userInfo: AliyunpanScope.User.GetUsersInfo.Response?

    var isAuthorizing: Bool {
        status != nil && status != .scanSuccess
    }
    
    var isAuthorized: Bool {
        userInfo != nil
    }
    
    var showAuthorizeButton: Bool {
        guard !isAuthorized else {
            return false
        }
        return !isAuthorizing
    }
    
    var body: some View {
        Image(uiImage: image)
            .padding(.bottom, 50)
        
        if showAuthorizeButton {
            Button("Authorize") {
                Task {
                    let userInfo = try await client.authorize(
                        credentials: .qrCode(self))
                    .send(AliyunpanScope.User.GetUsersInfo())
                    self.userInfo = userInfo
                }
            }
            .font(.extraLargeTitle)
        } else {
            Text(userInfo?.name ?? "")
                .font(.extraLargeTitle)
            
            Text(userInfo?.id ?? "")
                .font(.largeTitle)
        }
    }
}

extension AuthorizeView: AliyunpanQRCodeContainer {
    func showAliyunpanAuthorizeQRCode(with url: URL) {
        Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                self.image = image
            }
        }
    }
    
    func authorizeQRCodeStatusUpdated(_ status: AliyunpanSDK.AliyunpanAuthorizeQRCodeStatus) {
        self.status = status
    }
}

struct ContentView: View {
    @State var authorizeView = AuthorizeView()
    
    var body: some View {
        authorizeView
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
