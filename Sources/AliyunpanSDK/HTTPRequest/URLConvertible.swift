//
//  URLConvertible.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/23.
//

import Foundation

protocol URLConvertible {
    func asURL() throws -> URL
}

extension String: URLConvertible {
    func asURL() throws -> URL {
        guard let url = URL(string: self) else {
            throw AliyunpanError.NetworkSystemError.invalidURL
        }
        return url
    }
}

extension URL: URLConvertible {
    func asURL() throws -> URL { self }
}

struct AliyunpanURL: URLConvertible {
    var host: String = Aliyunpan.env.host
    let uri: String
    
    func asURL() throws -> URL {
        try "\(host)\(uri)".asURL()
    }
}
