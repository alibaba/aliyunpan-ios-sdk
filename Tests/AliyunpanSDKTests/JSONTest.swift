//
//  JSONTest.swift
//  AliyunpanSDKTests
//
//  Created by zhaixian on 2023/12/5.
//

import XCTest
@testable import AliyunpanSDK

class JSONTests: XCTestCase {
    func testToken() throws {
        let json = """
{
    "token_type": "Bearer",
    "refresh_token": "refresh_token1",
    "access_token": "access_token1",
    "expires_in": 1701760970
}
"""
        
        let token = try JSONParameterDecoder().decode(AliyunpanToken.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(token.token_type, "Bearer")
        XCTAssertEqual(token.access_token, "access_token1")
        XCTAssertEqual(token.refresh_token, "refresh_token1")
        XCTAssertEqual(token.expires_in, 1701760970)
        XCTAssertEqual(token.isExpired, Date().timeIntervalSince1970 > 1701760970)
    }
    
    func testFile() throws {
        let json = """
{
      "trashed": null,
      "name": "music.mp3",
      "thumbnail": null,
      "type": "file",
      "category": "audio",
      "hidden": false,
      "status": "available",
      "description": null,
      "meta": null,
      "url": "https://stg111-enet.cn-shanghai.data.alicloudccp.com",
      "size": 561701,
      "starred": false,
      "location": null,
      "deleted": null,
      "channel": null,
      "user_tags": null,
      "mime_type": "audio/mpeg",
      "parent_file_id": "root",
      "drive_id": "drive_id1",
      "file_id": "file_id1",
      "file_extension": "mp3",
      "revision_id": null,
      "content_hash": "content_hash1",
      "content_hash_name": "sha1",
      "encrypt_mode": "none",
      "domain_id": "stg111",
      "user_meta": null,
      "content_type": null,
      "created_at": "2023-06-28T10:00:20.022Z",
      "updated_at": "2023-06-28T12:00:20.022Z",
      "local_created_at": null,
      "local_modified_at": null,
      "trashed_at": null,
      "punish_flag": 0,
      "video_media_metadata": null,
      "image_media_metadata": null,
      "play_cursor": null,
      "video_preview_metadata": null,
      "streams_info": null
}
"""
        
        let file = try JSONParameterDecoder().decode(AliyunpanFile.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(file.name, "music.mp3")
        XCTAssertEqual(file.url, URL(string: "https://stg111-enet.cn-shanghai.data.alicloudccp.com"))
        XCTAssertEqual(file.drive_id, "drive_id1")
        XCTAssertEqual(file.file_id, "file_id1")
        XCTAssertEqual(file.parent_file_id, "root")
        XCTAssertEqual(file.category, .audio)
        XCTAssertEqual(file.file_extension, "mp3")
        XCTAssertEqual(file.type, .file)
        XCTAssertEqual(file.size, 561701)
        XCTAssertEqual(file.created_at?.timeIntervalSince1970, 1687946420.022)
        XCTAssertEqual(file.updated_at?.timeIntervalSince1970, 1687953620.022)
        
        let description = """
[AliyunpanFile]
    name: music.mp3
    drive_id: drive_id1
    file_id: file_id1
    parent_file_id: root
    size: 561701
    file_extension: mp3
    content_hash: content_hash1
    category: audio
    type: file
    thumbnail: nil
    url: https://stg111-enet.cn-shanghai.data.alicloudccp.com
    created_at: 1687946420.022
    updated_at: 1687953620.022
    play_cursor: nil
    image_media_metadata: nil
    video_media_metadata: nil
    video_preview_metadata: nil
"""
        XCTAssertEqual(file.description, description)
    }
    
    func testJSONEncoder() throws {
        struct Foo: Codable {
            let created_at: Date?
            let updated_at: Date?
        }
        
        let bar = Foo(
            created_at: Date(timeIntervalSince1970: 1687946420.022),
            updated_at: Date(timeIntervalSince1970: 1687953620.022))
        
        let data = try JSONParameterEncoder().encode(bar)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: String]
        
        XCTAssertEqual(json["created_at"], "2023-06-28T18:00:20.022+08:00")
        XCTAssertEqual(json["updated_at"], "2023-06-28T20:00:20.022+08:00")
    }
}
