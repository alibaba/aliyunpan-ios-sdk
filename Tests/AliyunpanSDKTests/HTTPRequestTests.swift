//
//  HTTPRequestTests.swift
//  AliyunpanSDKTests
//
//  Created by zhaixian on 2023/11/24.
//

import XCTest
@testable import AliyunpanSDK

extension Array where Element == URLQueryItem {
    subscript(key: String) -> String? {
        first(where: { $0.name == key })?.value
    }

}

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
        let request = HTTPRequest(command: AliyunpanScope.User.GetDriveInfo())
        let urlRequest = try request.asURLRequest()
        XCTAssertEqual(urlRequest.headers.count, HTTPHeaders.default.count)
        HTTPHeaders.default.forEach {
            XCTAssertTrue(urlRequest.headers.contains($0))
        }
    }
    
    func testHTTPHeader2() throws {
        let request = HTTPRequest(command: AliyunpanScope.User.GetVipInfo())
            .headers([
                .acceptEncoding("other"),
                .authorization(bearerToken: "abc")
            ])
        let urlRequest = try request.asURLRequest()
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!["Accept-Encoding"], "other")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!["Authorization"], "Bearer abc")
    }
    
    func testHTTPBody1() throws {
        let request = HTTPRequest(
            command: AliyunpanScope.File.GetFileList(
                .init(drive_id: "drive_id1",
                      parent_file_id: "parent_file_id1",
                      limit: 300,
                      marker: "next_marker",
                      order_by: .created_at,
                      order_direction: .desc)))
        let urlRequest = try request.asURLRequest()
        XCTAssertEqual(urlRequest.httpMethod?.lowercased(), "post")
        

        let json = try JSONSerialization.jsonObject(with: urlRequest.httpBody!) as! [String: Any]
        XCTAssertEqual(json["drive_id"] as! String, "drive_id1")
        XCTAssertEqual(json["parent_file_id"] as! String, "parent_file_id1")
        XCTAssertEqual(json["limit"] as! Int, 300)
        XCTAssertEqual(json["marker"] as! String, "next_marker")
        XCTAssertEqual(json["order_by"] as! String, "created_at")
        XCTAssertEqual(json["order_direction"] as! String, "DESC")
    }
    
    func testHTTPBody2() throws {
        let request = HTTPRequest(
            command: AliyunpanScope.File.GetStarredList(
                .init(
                    drive_id: "drive_id1",
                    limit: 300,
                    marker: "next_marker",
                    order_by: .created_at,
                    order_direction: .desc)))
        let urlRequest = try request.asURLRequest()
        XCTAssertEqual(urlRequest.httpMethod?.lowercased(), "post")

        let json = try JSONSerialization.jsonObject(with: urlRequest.httpBody!) as! [String: Any]
        XCTAssertEqual(json["drive_id"] as! String, "drive_id1")
        XCTAssertEqual(json["limit"] as! Int, 300)
        XCTAssertEqual(json["marker"] as! String, "next_marker")
        XCTAssertEqual(json["order_by"] as! String, "created_at")
        XCTAssertEqual(json["order_direction"] as! String, "DESC")
    }
    
    func testHTTPParams() throws {
        let request = HTTPRequest(
            command: AliyunpanScope.Internal.Authorize(
                .init(
                    client_id: "client_id1",
                    redirect_uri: "redirect_uri1",
                    scope: "scope1",
                    response_type: "response_type1",
                    relogin: true)))
        let urlRequest = try request.asURLRequest()
        XCTAssertEqual(urlRequest.httpMethod?.lowercased(), "get")
        
        let queryItem = urlRequest.url!.queryItems
        
        XCTAssertEqual(queryItem["client_id"], "client_id1")
        XCTAssertEqual(queryItem["redirect_uri"], "redirect_uri1")
        XCTAssertEqual(queryItem["scope"], "scope1")
        XCTAssertEqual(queryItem["response_type"], "response_type1")
        XCTAssertEqual(queryItem["relogin"], "1")
    }
}
