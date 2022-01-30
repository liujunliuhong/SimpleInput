//
//  LimitedPolicy.swift
//  LimitedInput
//
//  Created by jun on 2022/01/30.
//

import Foundation

public struct LimitedPolicy: OptionSet {
    public let rawValue: UInt
    
    public static let containsAll = LimitedPolicy(rawValue: 1 << 0)
    public static let number = LimitedPolicy(rawValue: 1 << 1)
    public static let lowercaseAlphabet = LimitedPolicy(rawValue: 1 << 2)
    public static let uppercaseAlphabet = LimitedPolicy(rawValue: 1 << 3)
    public static let chinese = LimitedPolicy(rawValue: 1 << 4)
    public static let emoji = LimitedPolicy(rawValue: 1 << 5)
    
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    static let all: LimitedPolicy = [.number]
}


public enum LimitedDecimalPolicy {
    case policy1(integerPartLength: UInt, decimalPartLength: UInt, unsigned: Bool)
    case policy2(totalLength: UInt, unsigned: Bool)
}
