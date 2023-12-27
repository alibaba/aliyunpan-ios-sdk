//
//  AliyunpanDownloadChunk.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/19.
//

import Foundation

/// 
public struct AliyunpanDownloadChunk: Equatable {
    public let start: Int64
    public let end: Int64
    
    init(start: Int64, end: Int64) {
        self.start = start
        self.end = end
    }
    
    init?(rangeString: String, fileSize: Int64) {
        let rangeValue = rangeString.split(separator: "=").last ?? ""
        let array = rangeValue.split(separator: "-")
        guard array.count >= 1,
              let start = Int64(array[0]) else {
            return nil
        }
        let end: Int64
        if array.count == 2, let value = Int64(array[1]) {
            end = value + 1
        } else {
            end = fileSize
        }
        self = Self(start: start, end: end)
    }
}
