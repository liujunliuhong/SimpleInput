//
//  UITextField+Limited.swift
//  LimitedInput
//
//  Created by galaxy on 2022/2/6.
//

import Foundation
import UIKit

private struct AssociatedKeys {
    static var maxLength = "com.galaxy.limitedInput.maxLength.key"
    static var decimalPolicy = "com.galaxy.limitedInput.decimalPolicy.key"
    static var generalPolicy = "com.galaxy.limitedInput.generalPolicy.key"
}

extension LimitedWrapper where Base == UITextField {
    /// 最大长度
    /// 默认为0，表示不限制长度
    public var maxLength: Int {
        get {
            return (objc_getAssociatedObject(self.base, &AssociatedKeys.maxLength) as? Int) ?? 0
        }
        set {
            objc_setAssociatedObject(self.base, &AssociatedKeys.maxLength, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 通用策略
    /// 与`decimalPolicy`属性互斥
    public var generalPolicy: LimitedPolicy {
        get {
            return (objc_getAssociatedObject(self.base, &AssociatedKeys.generalPolicy) as? LimitedPolicy) ?? .all
        }
        set {
            objc_setAssociatedObject(self.base, &AssociatedKeys.generalPolicy, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 小数策略
    /// 如果该属性不为空，则`maxLength`和`generalPolicy`将失效
    public var decimalPolicy: LimitedDecimalPolicy? {
        get {
            return objc_getAssociatedObject(self.base, &AssociatedKeys.decimalPolicy) as? LimitedDecimalPolicy
        }
        set {
            objc_setAssociatedObject(self.base, &AssociatedKeys.decimalPolicy, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

extension LimitedWrapper where Base == UITextField {
    public func check(shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let decimalPolicy = decimalPolicy {
            return checkDecimal(decimalPolicy: decimalPolicy, shouldChangeCharactersRange: range, replacementString: string)
        } else {
            return checkGeneral(generalPolicy: generalPolicy, shouldChangeCharactersRange: range, replacementString: string)
        }
    }
}


extension LimitedWrapper where Base == UITextField {
    private func checkDecimal(decimalPolicy: LimitedDecimalPolicy,
                              shouldChangeCharactersRange: NSRange,
                              replacementString: String) -> Bool {
        var allowSigned: Bool
        switch decimalPolicy {
            case .policy1(_, _, let _allowSigned):
                allowSigned = _allowSigned
            case .policy2(_, let _allowSigned):
                allowSigned = _allowSigned
        }
        
        if let markedTextRange = base.markedTextRange, let _ = base.position(from: markedTextRange.start, offset: 0) {
            // 有高亮文字的存在的时候，不做处理
            return true
        }
        if !allowSigned && !replacementString.containsOnlyNumber {
            return false
        } else if allowSigned && !(replacementString.containsOnlyNumber || replacementString.containsSigned) {
            return false
        }
        //
        var shouldChangeCharactersRange = shouldChangeCharactersRange
        //
        var sText = base.text ?? ""
        if sText.isEmpty && replacementString.isDot {
            // 当文本不存在，且只输入一个小数点时
            sText = "0" + String.dot
            shouldChangeCharactersRange = NSRange(location: sText.count, length: 0)
        }
        if allowSigned && !sText.hasSignedPrefix {
            return false // 符号只能出现在首位
        }
        if sText.containsDot && replacementString.containsDot {
            return false // 只能有一个小数点
        } else if allowSigned && sText.hasSignedPrefix && replacementString.containsSigned {
            return false // 只能有一个符号
        }
        //print("之前的文本:\(sText)")
        // 获取新的文本
        if shouldChangeCharactersRange.location > sText.count {
            shouldChangeCharactersRange = NSRange(location: sText.count, length: 0)
        }
        let r = Range<String.Index>.init(shouldChangeCharactersRange, in: sText)!
        sText.replaceSubrange(r, with: replacementString)
        //print("新的文本:\(sText)")
        //
        var prefix = "" // 符号
        var afterText = sText
        if sText.hasSignedPrefix {
            prefix = String(sText[sText.startIndex...sText.index(sText.startIndex, offsetBy: 1)])
            afterText = String(sText[sText.index(sText.startIndex, offsetBy: 1)...])
        }
        var integerPartString = afterText // 整数部分
        var decimalPartString = "" // 小数部分
        if sText.containsDot {
            let groups = sText.components(separatedBy: String.dot)
            integerPartString = groups[0]
            decimalPartString = groups[1]
        }
        if !integerPartString.containsOnlyNumber || !decimalPartString.containsOnlyNumber {
            return false
        }
        // 去除整数部分多余的0
        if let v = UInt64(integerPartString) {
            integerPartString = "\(v)"
        }
        
        switch decimalPolicy {
            case .policy1(let integerPartLength, let decimalPartLength, _):
                if integerPartString.count > integerPartLength || decimalPartString.count > decimalPartLength {
                    return false
                }
            case .policy2(let totalLength, _):
                if integerPartString.count + decimalPartString.count > totalLength {
                    return false
                }
        }
        
        base.text = prefix + afterText
        
        return true
    }
    
    private func checkGeneral(generalPolicy: LimitedPolicy,
                              shouldChangeCharactersRange: NSRange,
                              replacementString: String) -> Bool {
        if let markedTextRange = base.markedTextRange, let _ = base.position(from: markedTextRange.start, offset: 0) {
            // 有高亮文字的存在的时候，不做处理
            return true
        }
        var result = true
        if generalPolicy.contains(.number) {
            result = result && replacementString.containsOnlyNumber
        }
        if generalPolicy.contains(.lowercaseAlphabet) {
            result = result && replacementString.containsOnlyLowercaseAlphabet
        }
        if generalPolicy.contains(.uppercaseAlphabet) {
            result = result && replacementString.containsOnlyUppercaseAlphabet
        }
        if generalPolicy.contains(.chinese) {
            result = result && replacementString.containsOnlyChinese
        }
        if generalPolicy.contains(.emoji) {
            result = result && replacementString.containsOnlyEmoji
        }
        if !result {
            return false
        }
        var sText = base.text ?? ""
//        var shouldChangeCharactersRange = shouldChangeCharactersRange
//        if shouldChangeCharactersRange.location > sText.count {
//            shouldChangeCharactersRange = NSRange(location: sText.count, length: 0)
//        }
//        let r = Range<String.Index>.init(shouldChangeCharactersRange, in: sText)!
//        sText.replaceSubrange(r, with: replacementString)
        let maxLength = maxLength
        print(maxLength)
        if maxLength > 0 && sText.count > maxLength {
            sText = String(sText[sText.startIndex..<sText.index(sText.startIndex, offsetBy: maxLength)])
        }
        print(sText)
        base.text = "1"
        
        return true
    }
}
