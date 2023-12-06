//
//  CryptoTests.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/24.
//

import XCTest
@testable import AliyunpanSDK

class CryptoTests: XCTestCase {
    func testSHA256() throws {
        XCTAssertEqual(AliyunpanCrypto.sha256AndBase64("1"), "a4ayc_80_OGda4BO_1o_V0etpOqiLx1JwB5S3beHW0s=")
        
        XCTAssertEqual(AliyunpanCrypto.sha256AndBase64("82"), "pG43Yy-mylGhP-OaVns8I7KML0fYr2vpvWPgMOIUujg=")
        
        XCTAssertEqual(AliyunpanCrypto.sha256AndBase64("123"), "pmWkWSBCL51Bfkhn79xPuKBKHz__H6B-mY6G9_eieuM=")
        
        XCTAssertEqual(AliyunpanCrypto.sha256AndBase64("1234"), "A6xnQhbz4Vx2HuGl4lXwZ5U2I8iziLRFnhP5eNfIRvQ=")
    }
}
