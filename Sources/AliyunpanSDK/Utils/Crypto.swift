//
//  Encryption.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/22.
//

import Foundation
import CryptoKit

class AliyunpanCrypto {
    static func sha256AndBase64(_ message: String) -> String {
        let inputData = Data(message.utf8)
        let hashedData = SHA256.hash(data: inputData)
        var string = Data(hashedData).base64EncodedString() as NSString
        string = string.replacingOccurrences(of: "+", with: "-") as NSString
        string = string.replacingOccurrences(of: "/", with: "_") as NSString
        return string as String
    }
}
