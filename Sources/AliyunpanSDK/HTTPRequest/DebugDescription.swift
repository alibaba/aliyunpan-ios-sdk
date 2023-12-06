//
//  DebugDescription.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/28.
//

import Foundation

class DebugDescription {
    static func description(of request: URLRequest) -> String {
        let requestSummary = "\(request.httpMethod ?? "Unknown") \(request)"
        let requestHeadersDescription = DebugDescription.description(for: request.headers)
        let requestBodyDescription = DebugDescription.description(for: request.httpBody)

        return """
        [Request]: \(requestSummary)
            \(requestHeadersDescription.indentingNewlines())
            \(requestBodyDescription.indentingNewlines())
        """
    }

    static func description(of response: URLResponse, data: Data) -> String {
        guard let response = response as? HTTPURLResponse else {
            return ""
        }
        
        let responseBodyDescription = DebugDescription.description(for: data)

        return """
        [Response]:
            [Status Code]: \(response.statusCode)
            \(DebugDescription.description(for: response.headers).indentingNewlines())
            \(responseBodyDescription.indentingNewlines())
        """
    }
    
    static func description(for headers: HTTPHeaders) -> String {
        guard !headers.isEmpty else { return "[Headers]: None" }

        let headerDescription = "\(headers.sorted().description)".indentingNewlines()
        return """
        [Headers]:
            \(headerDescription)
        """
    }
    
    static func description(for data: Data?,
                            maximumLength: Int = 10000) -> String {
        guard let data, !data.isEmpty else {
            return "[Body]: None"
        }

        guard data.count <= maximumLength else {
            return "[Body]: \(data.count) bytes"
        }

        return """
        [Body]:
            \(String(decoding: data, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .indentingNewlines())
        """
    }
}

extension String {
    fileprivate func indentingNewlines(by spaceCount: Int = 4) -> String {
        let spaces = String(repeating: " ", count: spaceCount)
        return replacingOccurrences(of: "\n", with: "\n\(spaces)")
    }
}
