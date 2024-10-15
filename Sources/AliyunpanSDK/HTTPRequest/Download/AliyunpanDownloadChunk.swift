//
//  AliyunpanDownloadChunk.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/19.
//

import Foundation

public struct AliyunpanDownloadChunk: Equatable, CustomStringConvertible {
    public let start: Int64
    public let end: Int64
    public let index: Int
    
    init(start: Int64, end: Int64) {
        self.start = start
        self.end = end
        self.index = -1
    }
    
    init(start: Int64, end: Int64, index: Int) {
        self.start = start
        self.end = end
        self.index = index
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
        self = Self(start: start, end: end, index: -1)
    }
    
    public var description: String {
        "[chunk-\(index)]: \(start)-\(end)"
    }
}
