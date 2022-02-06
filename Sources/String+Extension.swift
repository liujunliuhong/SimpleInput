//
//  String+Extension.swift
//  LimitedInput
//
//  Created by galaxy on 2022/2/6.
//

import Foundation

extension String {
    internal static let dot = "."
    
    internal var containsSigned: Bool {
        return contains("+") || contains("-")
    }
    
    internal var hasSignedPrefix: Bool {
        return hasPrefix("+") || hasPrefix("-")
    }
    
    internal var containsDot: Bool {
        return contains(String.dot)
    }
    
    internal var isDot: Bool {
        return self == String.dot
    }
}
