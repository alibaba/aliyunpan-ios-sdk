//
//  HTTPRequestTests.swift
//  AliyunpanSDKTests
//
//  Created by zhaixian on 2023/11/24.
//

import XCTest
@testable import AliyunpanSDK

class HTTPRequestTests: XCTestCase {
    func testURLExtension() throws {
        let url = URL(string: "https://alipan.com?a=1&b=2&c=3&d=4")!
        let queryItem = url.queryItems
        XCTAssertEqual(queryItem.count, 4)
        XCTAssertEqual(queryItem[0].name, "a")
        XCTAssertEqual(queryItem[0].value, "1")
        XCTAssertEqual(queryItem[1].name, "b")
        XCTAssertEqual(queryItem[1].value, "2")
        XCTAssertEqual(queryItem[2].name, "c")
        XCTAssertEqual(queryItem[2].value, "3")
        XCTAssertEqual(queryItem[3].name, "d")
        XCTAssertEqual(queryItem[3].value, "4")
        
        let url2 = URL(string: "https://alipan.com")!
        XCTAssertEqual(url2.queryItems.count, 0)
    }
    
    func testHTTPHeader1() throws {
        let request = HTTPRequest(command: AliyunpanScope.User.GetUsersInfo())
        let urlRequest = try request.asURLRequest()
        XCTAssertEqual(urlRequest.headers.count, HTTPHeaders.default.count)
        HTTPHeaders.default.forEach {
            XCTAssertTrue(urlRequest.headers.contains($0))
        }
    }
    
    func testHTTPHeader2() throws {
        let request = HTTPRequest(command: AliyunpanScope.User.GetUsersInfo())
            .headers([
                .acceptEncoding("other"),
                .authorization(bearerToken: "abc")
            ])
        let urlRequest = try request.asURLRequest()
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!["Accept-Encoding"], "other")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!["Authorization"], "Bearer abc")
    }
}
