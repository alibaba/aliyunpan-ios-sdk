//
//  AliyunpanSDKTests.swift
//  AliyunpanSDKTests
//
//  Created by zhaixian on 2023/11/16.
//

import XCTest
@testable import AliyunpanSDK

class AliyunpanSDKTests: XCTestCase {
    func testSDK() throws {
        XCTAssertEqual(Aliyunpan.logLevel, .warn)
        Aliyunpan.setLogLevel(.error)
        XCTAssertEqual(Aliyunpan.logLevel, .error)
        
        XCTAssertEqual(Aliyunpan.env, .product)
        XCTAssertEqual(Aliyunpan.env.host, "https://openapi.alipan.com")
        Aliyunpan.setEnvironment(.pre)
        XCTAssertEqual(Aliyunpan.env, .pre)
        XCTAssertEqual(Aliyunpan.env.host, "https://stg-openapi.alipan.com")
        
        let url1 = URL(string: "smartdrive123456://authorize?state=abc&code=anycode")!
        XCTAssertTrue(Aliyunpan.handleOpenURL(url1))
        let url2 = URL(string: "123456://authorize?state=abc&code=anycode")!
        XCTAssertFalse(Aliyunpan.handleOpenURL(url2))
    }
}
