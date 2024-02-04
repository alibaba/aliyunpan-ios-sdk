//
//  URL+AliyunpanSDK.swift
//  
//
//  Created by zhaixian on 2023/11/27.
//

import Foundation

extension URL {
    var queryItems: [URLQueryItem] {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return []
        }
        return urlComponents.queryItems ?? []
    }
}
