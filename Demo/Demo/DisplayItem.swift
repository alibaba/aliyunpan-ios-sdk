//
//  DisplayItem.swift
//  Demo
//
//  Created by zhaixian on 2023/12/12.
//

import Foundation
import AliyunpanSDK

extension AliyunpanFile: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public static func == (lhs: AliyunpanFile, rhs: AliyunpanFile) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension AliyunpanDownloadResult: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(progress)
        hasher.combine(url)
    }
    
    public static func == (lhs: AliyunpanDownloadResult, rhs: AliyunpanDownloadResult) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct DisplayItem: Hashable {
    let file: AliyunpanFile
    let downloadResult: AliyunpanDownloadResult?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(downloadResult)
    }
    
    public static func == (lhs: DisplayItem, rhs: DisplayItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    init(file: AliyunpanFile, downloadResult: AliyunpanDownloadResult?) {
        self.file = file
        self.downloadResult = downloadResult
    }
    
    init(_ file: AliyunpanFile) {
        self.init(file: file, downloadResult: nil)
    }
}
