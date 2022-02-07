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
    
    /// 筛选出字符串中小写字母，并组成一个新的字符串
    internal var lowercaseAlphabetString: String {
        return lowercaseAlphabets.map { String($0) }.reduce("", +)
    }
    
    /// 筛选出字符串中小写集合
    internal var lowercaseAlphabets: [Character] {
        return filter { $0.isLowercaseAlphabet }
    }
    
    /// 筛选出字符串中大写字母，并组成一个新的字符串
    internal var uppercaseAlphabetString: String {
        return uppercaseAlphabets.map { String($0) }.reduce("", +)
    }
    
    /// 筛选出字符串中大写集合
    internal var uppercaseAlphabets: [Character] {
        return filter { $0.isUppercaseAlphabet }
    }
}

extension Character {
    internal var isLowercaseAlphabet: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.value >= 97 && firstScalar.value <= 122
    }
    
    internal var isUppercaseAlphabet: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.value >= 65 && firstScalar.value <= 90
    }
}
