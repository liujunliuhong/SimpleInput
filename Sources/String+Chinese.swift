//
//  String+Chinese.swift
//  LimitedInput
//
//  Created by jun on 2022/01/30.
//

import Foundation


extension String {
    /// 字符串中是否包含中文
    internal var containsChinese: Bool {
        return contains { $0.isChinese }
    }
    
    /// 字符串是否只有中文
    internal var containsOnlyChinese: Bool {
        return !isEmpty && !contains { !$0.isChinese }
    }
}

extension Character {
    fileprivate var isChinese: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.value >= 0x4E00 && firstScalar.value <= 0x9FA5
    }
}
