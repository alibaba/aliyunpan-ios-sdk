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

extension AliyunpanCommand where Request == Void {
    public var request: Request? { nil }
    public var requestData: Data? { nil }
}

extension AliyunpanCommand where Request: Encodable {
    public var requestData: Data? {
        if let request {
            return try? JSONParameterEncoder().encode(request)
        } else {
            return nil
        }
    }
}
