//
//  AliyunpanClientTests.swift
//  AliyunpanSDKTests
//
//  Created by zhaixian on 2023/12/5.
//

import XCTest
@testable import AliyunpanSDK

class AliyunpanClientTests: XCTestCase {
    @MainActor func testToken() {
        let client1 = AliyunpanClient(.init(appId: "app", scope: "scope", identifier: "user1"))
        let client2 = AliyunpanClient(.init(appId: "app", scope: "scope", identifier: "user2"))
        let client3 = AliyunpanClient(appId: "app", scope: "scope")

        let now = Date()
        let token = AliyunpanToken(
            token_type: "token_type1",
            access_token: "access_token1",
            refresh_token: "refresh_token1",
            expires_in: now.timeIntervalSince1970)
        client1.token = token
        XCTAssertEqual(client1.accessToken, "access_token1")
        XCTAssertEqual(client1.token?.token_type, "token_type1")
        XCTAssertEqual(client1.token?.refresh_token, "refresh_token1")
        XCTAssertEqual(client1.token?.expires_in, now.timeIntervalSince1970)
        XCTAssertEqual(client2.accessToken, nil)
        XCTAssertEqual(client3.accessToken, nil)
        client1.cleanToken()
        XCTAssertEqual(client1.accessToken, nil)
        XCTAssertEqual(client2.accessToken, nil)
        XCTAssertEqual(client3.accessToken, nil)
    }
}
