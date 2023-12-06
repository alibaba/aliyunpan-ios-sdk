//
//  AliyunpanCommand.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/21.
//

import Foundation

public protocol AliyunpanCommand {
    associatedtype Request
    associatedtype Response: Decodable
    
    var httpMethod: HTTPMethod { get }
    var uri: String { get }
    
    var request: Request? { get }
    var requestData: Data? { get }
}

public extension AliyunpanCommand where Request == Void {
    var request: Request? { nil }
    var requestData: Data? { nil }
}

public extension AliyunpanCommand where Request: Encodable {
    var requestData: Data? {
        if let request {
            return try? JSONParameterEncoder().encode(request)
        } else {
            return nil
        }
    }
}
