//
//  Crypto.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/22.
//

import Foundation
import CryptoKit

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    
    var hexString: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}

public class AliyunpanCrypto {
    /// 大数据量 sha1 and hex
    public static func sha1AndHex(_ fileURL: URL) -> String? {
        guard let inputStream = InputStream(url: fileURL) else {
            return nil
        }
        
        defer {
            inputStream.close()
        }
        
        // 10M 缓冲区
        let bufferSize = 10 * 1024 * 1024
        var buffer = [UInt8](repeating: 0, count: bufferSize)

        var sha1 = Insecure.SHA1()

        inputStream.open()
        var error: Error?
        while inputStream.hasBytesAvailable {
            let read = inputStream.read(&buffer, maxLength: bufferSize)
            if read == 0 {
                break
            } else if read < 0 {
                error = inputStream.streamError
                break
            }
            let data = Data(buffer.prefix(read))
            sha1.update(data: data)
        }
        
        if error != nil {
            return nil
        }
        
        let hashedData = sha1.finalize()
        return hashedData.hexString
    }

    /// 低数据量 sha1 and hex
    public static func sha1AndHex(_ data: Data) -> String {
        Insecure.SHA1.hash(data: data).hexString
    }
    
    public static func sha256AndBase64(_ message: String) -> String {
        let inputData = Data(message.utf8)
        let hashedData = SHA256.hash(data: inputData)
        var string = Data(hashedData).base64EncodedString() as NSString
        string = string.replacingOccurrences(of: "+", with: "-") as NSString
        string = string.replacingOccurrences(of: "/", with: "_") as NSString
        return string as String
    }
    
    public static func md5(_ message: String) -> String {
        Insecure.MD5.hash(data: Data(message.utf8))
            .hexString
    }
    
    /// 获取秒传值
    /// - Parameters:
    ///   - accessToken: access_token
    ///   - fileSize: 文件 size
    /// - Returns: 秒传值
    public static func getProofCode(accessToken: String, fileURL: URL) -> String? {
        do {
            let fileSize = try FileManager.default.fileSizeOfItem(at: fileURL)
            
            let string = String(md5(accessToken).prefix(16))
            let value = strtoul(string, nil, 16)
            
            let index = UInt64(value) % UInt64(fileSize)
            
            let data = try FileManager.default.dataChunk(
                at: fileURL,
                in: Int(index)..<Int(index + 8)
            )
            return data.base64EncodedString()
        } catch {
            return nil
        }
    }
}
