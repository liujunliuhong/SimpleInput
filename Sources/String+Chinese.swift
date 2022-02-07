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
    
    /// 筛选出字符串中中文，并组成一个新的字符串
    internal var chineseString: String {
        return chineses.map { String($0) }.reduce("", +)
    }
    
    /// 筛选出字符串中中文集合
    internal var chineses: [Character] {
        return filter { $0.isChinese }
    }
}

extension Character {
    internal var isChinese: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.value >= 0x4E00 && firstScalar.value <= 0x9FA5
    }
}
