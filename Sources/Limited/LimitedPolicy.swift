//
//  LimitedPolicy.swift
//  LimitedInput
//
//  Created by jun on 2022/01/30.
//

import Foundation

/// 限制策略
public struct LimitedPolicy: OptionSet {
    public let rawValue: UInt
    
    /// 包含所有
    public static let containsAll = LimitedPolicy(rawValue: 1 << 0)
    /// 数字(0-9)
    public static let number = LimitedPolicy(rawValue: 1 << 1)
    /// 小写字母(a-z)
    public static let lowercaseAlphabet = LimitedPolicy(rawValue: 1 << 2)
    /// 大写字母(A-Z)
    public static let uppercaseAlphabet = LimitedPolicy(rawValue: 1 << 3)
    /// 中文
    public static let chinese = LimitedPolicy(rawValue: 1 << 4)
    /// 表情
    public static let emoji = LimitedPolicy(rawValue: 1 << 5)
    
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let all: LimitedPolicy = [.containsAll]
}


/// 小数策略
public enum DecimalPolicy {
    /// 策略1
    /// integerPartLength: 整数部分长度
    /// decimalPartLength: 小数部分长度
    /// allowSigned: 是否允许出现符号(`+`或者`-`)
    case policy1(integerPartLength: UInt, decimalPartLength: UInt, allowSigned: Bool)
    
    /// 策略2
    /// totalLength: 总长度(整数部分长度+小数部分长度)
    /// allowSigned: 是否允许出现符号(`+`或者`-`)
    case policy2(totalLength: UInt, allowSigned: Bool)
    
    /// 策略3
    /// integerPartLength: 整数部分长度
    /// decimalReservedValidDigitLength: 小数部分有效位数长度
    /// maximumDecimalPartLength: 小数位数的最大长度
    /// `10.00001245`保留`5`为有效位数，最多保留`2`位小数 => 10.00`
    /// `19.12`保留`5`为有效位数，最多保留`1`位小数 => `19.1`
    /// `19.12`保留`2`为有效位数，最多保留`1`位小数 => `19.1`
    /// `10.123456`保留`5`为有效位数，最多保留`2`位小数 => `10.23`
    /// `10.123456`保留`2`为有效位数，最多保留`5`位小数 => `10.12`
    /// `10.00001245`保留`2`为有效位数，最多保留`6`位小数 => `10.000012`
    /// `10`保留`2`为有效位数，最多保留`6`位小数 => `10.00`
    case policy3(integerPartLength: UInt, decimalReservedValidDigitLength: UInt, maximumDecimalPartLength: UInt, allowSigned: Bool)
}
