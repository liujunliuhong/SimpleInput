//
//  String+Number.swift
//  LimitedInput
//
//  Created by jun on 2022/01/30.
//

import Foundation

extension String {
    
    /// 字符串中是否包含数字
    internal var containsNumber: Bool {
        return contains { $0.isNumber }
    }
    
    /// 字符串是否只有数字
    internal var containsOnlyNumber: Bool {
        return !isEmpty && !contains { !$0.isNumber }
    }
    
    /// 筛选出字符串中数字，并组成一个新的字符串
    internal var numberString: String {
        return numbers.map { String($0) }.reduce("", +)
    }
    
    /// 筛选出字符串中数字集合
    internal var numbers: [Character] {
        return filter { $0.isNumber }
    }
}

extension Character {
    internal var isNumber: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.value >= 48 && firstScalar.value <= 57
    }
}
