//
//  Weak.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/18.
//

import Foundation

class Weak<T: AnyObject> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}
