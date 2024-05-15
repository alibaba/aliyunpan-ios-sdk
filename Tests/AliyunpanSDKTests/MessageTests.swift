//
//  MessageTests.swift
//  AliyunpanSDKTests
//
//  Created by zhaixian on 2023/12/5.
//

import XCTest
@testable import AliyunpanSDK

extension AliyunpanError.AuthorizeError: Equatable {
    public static func == (lhs: AliyunpanError.AuthorizeError, rhs: AliyunpanError.AuthorizeError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

class MessageTests: XCTestCase {
    func testAliyunpanMessage() throws {
        let state = Date().timeIntervalSince1970
        
        let url1 = URL(string: "smartdrive://authorize?state=\(state)")!
        let message1 = try AliyunpanMessage(url1)
        XCTAssertEqual(message1.state, "\(state)")
        XCTAssertEqual(message1.originalURL, url1)
        
        let url2 = URL(string: "abcd://authorize?state=\(state)")!
        XCTAssertThrowsError(try AliyunpanMessage(url2)) { error in
            XCTAssertEqual(error as! AliyunpanError.AuthorizeError, AliyunpanError.AuthorizeError.invalidAuthorizeURL)
        }
        
        let url3 = URL(string: "https://stg.alipan.com/applink/authorize?state=\(state)")!
        let message3 = try AliyunpanMessage(url3)
        XCTAssertEqual(message3.state, "\(state)")
        XCTAssertEqual(message3.originalURL, url3)
        
        let url4 = URL(string: "https://www.alipan.com/applink/authorize?state=\(state)")!
        let message4 = try AliyunpanMessage(url4)
        XCTAssertEqual(message4.state, "\(state)")
        XCTAssertEqual(message4.originalURL, url4)
    }
    
    func testAliyunpanAuthMessage() throws {
        let state = Date().timeIntervalSince1970
        let code = "abcd"
        
        let url1 = URL(string: "smartdrive123456://authorize?state=\(state)&code=\(code)")!
        let message1 = try AliyunpanAuthorizeMessage(url1)
        XCTAssertEqual(message1.state, "\(state)")
        XCTAssertEqual(message1.authCode, code)
        XCTAssertEqual(message1.originalURL, url1)
        
        let url2 = URL(string: "abcd://authorize?state=\(state)&code=\(code)")!
        XCTAssertThrowsError(try AliyunpanAuthorizeMessage(url2)) { error in
            XCTAssertEqual(error as! AliyunpanError.AuthorizeError, AliyunpanError.AuthorizeError.invalidAuthorizeURL)
        }
    }
}
