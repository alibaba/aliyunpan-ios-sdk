//
//  AliyunpanSpaceInfo.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/30.
//

import Foundation

public struct AliyunpanSpaceInfo: Codable {
    public let used_size: Int64
    public let total_size: Int64
}

extension AliyunpanSpaceInfo: CustomStringConvertible {
    public var description: String {
        """
[AliyunpanSpaceInfo]
    used_size: \(used_size)
    total_size: \(total_size)
"""
    }
}
