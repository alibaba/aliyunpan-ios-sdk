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
    
    func testProofCode() throws {
        let url = Bundle(for: self.classForCoder).url(forResource: "TestFile1", withExtension: "txt")!

        XCTAssertEqual(
            AliyunpanCrypto.getProofCode(
                accessToken: "Bearer eyJraWQiOiJLcU8iLCJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwZWJkMjUyY2EyNTg0MmY0OTBmYmJhYWJlZTkwOGE5YyIsImF1ZCI6IjQ2NWJjNzMzZmQ2MTQxNDJiZmQ1Y2MxNGYzZjk1NWFlIiwicyI6ImNkYSIsImQiOiIxMDE4NDAsMTAyOTM0MjAiLCJpc3MiOiJhbGlwYW4iLCJleHAiOjE3MTQwMzg0NDYsImwiOjIsImlhdCI6MTcxMTQ0NjQ0MywianRpIjoiODM2ZmVkZDExMjhkNDU2MTg0NjA4OTgwMzBlZGM5NTkifQ.yZJFeeUriWOcPhg-CHHO1XyotwuFR0v",
                fileURL: url),
            "bG8gV29ybGQ="
        )
    }
    
    func testSHA1() throws {
        let url = Bundle(for: self.classForCoder).url(forResource: "TestFile1", withExtension: "txt")!

        XCTAssertEqual(
            AliyunpanCrypto.sha1AndHex(url),
            "2EF7BDE608CE5404E97D5F042F95F89F1C232871"
        )
        
        XCTAssertEqual(
            AliyunpanCrypto.sha1AndHex(try Data(contentsOf: url)),
            "2EF7BDE608CE5404E97D5F042F95F89F1C232871"
        )
    }
}
