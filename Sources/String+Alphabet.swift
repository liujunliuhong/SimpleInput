//
//  String+Alphabet.swift
//  LimitedInput
//
//  Created by jun on 2022/01/30.
//

import Foundation

extension String {
    
    /// 字符串中是否包含小写字母
    internal var containsLowercaseAlphabet: Bool {
        return contains { $0.isLowercaseAlphabet }
    }
    
    /// 字符串是否只有小写字母
    internal var containsOnlyLowercaseAlphabet: Bool {
        return !isEmpty && !contains { !$0.isLowercaseAlphabet }
    }
    
    /// 字符串中是否包含大写字母
    internal var containsUppercaseAlphabet: Bool {
        return contains { $0.isUppercaseAlphabet }
    }
    
    /// 字符串是否只有大写字母
    internal var containsOnlyUppercaseAlphabet: Bool {
        return !isEmpty && !contains { !$0.isUppercaseAlphabet }
    }
}

extension Character {
    fileprivate var isLowercaseAlphabet: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.value >= 97 && firstScalar.value <= 122
    }
    
    fileprivate var isUppercaseAlphabet: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.value >= 65 && firstScalar.value <= 90
    }
}
