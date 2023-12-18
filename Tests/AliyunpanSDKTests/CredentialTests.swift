//
//  CredentialTests.swift
//  AliyunpanSDKTests
//
//  Created by zhaixian on 2023/12/13.
//

import Foundation

import XCTest
@testable import AliyunpanSDK

class TestBizServer: AliyunpanBizServer {
    func requestToken(appId: String, authCode: String) async throws -> AliyunpanToken {
        return .init(token_type: "", access_token: "", refresh_token: nil, expires_in: 0)
    }
}

class TestQRCodeContainer: AliyunpanQRCodeContainer {
    func authorizeQRCodeStatusUpdated(_ status: AliyunpanSDK.AliyunpanAuthorizeQRCodeStatus) {}
    
    func showAliyunpanAuthorizeQRCode(with url: URL) {}
}

class CredentialTests: XCTestCase {
    func testCredential() throws {
        XCTAssertTrue(AliyunpanCredentials.pkce.implement is AliyunpanPKCECredentials)
        XCTAssertTrue(AliyunpanCredentials.server(TestBizServer()).implement is AliyunpanServerCredentials)
        XCTAssertTrue(AliyunpanCredentials.qrCode(TestQRCodeContainer()).implement is AliyunpanQRCodeCredentials)
    }
}
