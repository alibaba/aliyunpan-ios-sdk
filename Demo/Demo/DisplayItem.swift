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

extension AliyunpanDownloadTask.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .waiting:
            hasher.combine("waiting")
        case .downloading(let progress):
            hasher.combine("downloading")
            hasher.combine(progress)
        case .pause(let progress):
            hasher.combine("pause")
            hasher.combine(progress)
        case .finished(let url):
            hasher.combine("finished")
            hasher.combine(url)
        case .failed:
            hasher.combine("failed")
        }
    }
    
    public static func == (lhs: AliyunpanSDK.AliyunpanDownloadTask.State, rhs: AliyunpanSDK.AliyunpanDownloadTask.State) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct DisplayItem: Hashable {
    let file: AliyunpanFile
    let downloadState: AliyunpanDownloadTask.State?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(downloadState)
    }
    
    public static func == (lhs: DisplayItem, rhs: DisplayItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    init(file: AliyunpanFile, downloadState: AliyunpanDownloadTask.State?) {
        self.file = file
        self.downloadState = downloadState
    }
    
    init(_ file: AliyunpanFile) {
        self.init(file: file, downloadState: nil)
    }
}
