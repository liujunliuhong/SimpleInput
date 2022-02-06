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
public enum LimitedDecimalPolicy {
    /// 策略1
    /// integerPartLength: 整数部分长度
    /// decimalPartLength: 小数部分长度
    /// allowSigned: 是否允许出现符号(`+`或者`-`)
    case policy1(integerPartLength: UInt, decimalPartLength: UInt, allowSigned: Bool)
    
    /// 策略2
    /// totalLength: 总长度(整数部分长度+小数部分长度)
    /// allowSigned: 是否允许出现符号(`+`或者`-`)
    case policy2(totalLength: UInt, allowSigned: Bool)
}
