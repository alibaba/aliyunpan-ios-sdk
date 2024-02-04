//
//  Example.swift
//  Demo-MacOS
//
//  Created by zhaixian on 2023/12/15.
//

import Foundation

enum Example: String, CaseIterable {
    case getUserInfo = "获取用户信息"
    case getDriveInfo = "获取 Drive 信息"
    case getSpaceInfo = "获取空间信息"
    case getVIPInfo = "获取会员信息"
    case getVipFeatureList = "获取付费墙"
    case fetchFileList = "获取文件列表"
    case uploadFileToRoot = "上传文件到根目录"
    case createFolderOnRoot = "在根目录创建文件夹"
}
