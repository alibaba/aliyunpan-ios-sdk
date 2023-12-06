//
//  AliyunpanScope.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/21.
//

import Foundation

public struct AliyunpanScope {
    public typealias User = AliyunpanUserScope
    public typealias VIP = AliyunpanVIPScope
    public typealias File = AliyunpanFileScope
    public typealias Video = AliyunpanVideoScope
    typealias Internal = AliyunpanInternalScope
}

public class AliyunpanUserScope {}

public class AliyunpanVIPScope {}

public class AliyunpanFileScope {
    public enum OrderBy: String, Codable {
        case created_at
        case updated_at
        case name
        case size
        case name_enhanced
    }

    public enum OrderDirection: String, Codable {
        case desc = "DESC"
        case asc = "ASC"
    }
}

public class AliyunpanVideoScope {}

class AliyunpanInternalScope {}
