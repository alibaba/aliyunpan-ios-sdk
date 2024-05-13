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
    @State var status: AliyunpanAuthorizeQRCodeStatus?
    @State var userInfo: AliyunpanScope.User.GetUsersInfo.Response?
    
    var isAuthorized: Bool {
        userInfo != nil
    }
    
    var body: some View {
        if !isAuthorized {
            Button("Authorize") {
                Task {
                    do {
                        let userInfo = try await client.authorize(
                            credentials: .pkce)
                        .send(AliyunpanScope.User.GetUsersInfo())
                        self.userInfo = userInfo
                    } catch {
                        print(error)
                    }
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

struct ContentView: View {
    @State var authorizeView = AuthorizeView()
    
    var body: some View {
        authorizeView
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
