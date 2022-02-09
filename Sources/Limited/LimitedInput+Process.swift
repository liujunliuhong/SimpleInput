//
//  LimitedInput+Process.swift
//  SimpleInput
//
//  Created by jun on 2022/02/09.
//

import Foundation
import UIKit

extension LimitedInput {
    public static func getRealText(decimalPolicy: DecimalPolicy?, text: String?) -> String? {
        guard let sText = text else { return nil }
        guard let _ = decimalPolicy else { return sText }
        // 去除尾部的0和小数点，比如输入框的内容为`0.120`或者`5.`
        let group = getComponents(string: sText)
        let prefix = group.prefix
        var before = group.before.numberString
        var after = group.after.numberString
        // 去除整数部分多余的0
        while true {
            if before.hasPrefix(String.zero) {
                if before == String.zero {
                    break
                } else {
                    before = String(before.suffix(before.count - 1))
                }
            } else {
                break
            }
        }
        // 去除小数部分尾部多余的0
        while true {
            if after.hasSuffix(String.zero) {
                after = String(after.prefix(after.count - 1))
            } else {
                break
            }
        }
        
        if before.count <= 0 {
            return nil
        }
        if after.count <= 0 {
            return prefix + before
        } else {
            return prefix + before + String.dot + after
        }
    }
    
    public static func getRealDecimalText(decimalPolicy: DecimalPolicy?, text: String?) -> String? {
        guard let sText = getRealText(decimalPolicy: decimalPolicy, text: text) else { return nil }
        guard let decimalPolicy = decimalPolicy else { return sText }
        // 拆分单元
        let group = getComponents(string: sText)
        let prefix = group.prefix
        var before = group.before.numberString
        var after = group.after.numberString
        // 具体处理
        switch decimalPolicy {
            case .policy1(let integerPartLength, let decimalPartLength, _):
                if integerPartLength <= 0 {
                    // 如果整数部分长度小于0
                    before = ""
                    after = ""
                } else {
                    // 补齐after尾部的0
                    if decimalPartLength > after.count {
                        after += String(repeating: String.zero, count: Int(decimalPartLength) - after.count)
                    }
                }
            case .policy2(let totalLength, _):
                if totalLength <= 0 {
                    // 如果总长度小于0
                    before = ""
                    after = ""
                } else {
                    if before.count + after.count > totalLength {
                        if before.count < totalLength {
                            // 补齐after尾部的0
                            let remain = Int(totalLength) - before.count
                            after += String(repeating: String.zero, count: remain)
                        } else {
                            // 截取before，同时after置空
                            before = String(before.prefix(Int(totalLength)))
                            after = ""
                        }
                    } else {
                        // 补齐after尾部的0
                        let remain = Int(totalLength) - before.count - after.count
                        after += String(repeating: String.zero, count: remain)
                    }
                }
            case .policy3(let integerPartLength, let decimalReservedValidDigitLength, let maximumDecimalPartLength, _):
                if integerPartLength <= 0 {
                    // 如果整数部分长度小于0
                    before = ""
                    after = ""
                } else {
                    if decimalReservedValidDigitLength > 0 && maximumDecimalPartLength > 0 {
                        // 有效位数长度大于0，且小数位数长度大于0
                        var leadingZeroCount: Int = 0
                        var newAfter = after
                        while newAfter.hasPrefix(String.zero) {
                            newAfter = String(newAfter.suffix(newAfter.count - 1))
                            leadingZeroCount += 1
                        }
                        //
                        let s1 = String(after.prefix(leadingZeroCount)) // s1是有效数字前面的0
                        var s2 = String(after.suffix(after.count - leadingZeroCount)) // s2是有效数字
                        if s2.count >= decimalReservedValidDigitLength {
                            // 如果有效数字长度大于规定的长度，做截取
                            s2 = String(s2.prefix(Int(decimalReservedValidDigitLength)))
                        } else {
                            // 如果有效数字长度小于规定的长度，在有效数字尾部拼接0
                            s2 += String(repeating: String.zero, count: Int(decimalReservedValidDigitLength) - s2.count)
                        }
                        after = s1 + s2 // 获取完整的after
                        
                        if after.count > maximumDecimalPartLength {
                            // 如果after的长度大于规定的小数位数长度，做截取
                            after = String(after.prefix(Int(maximumDecimalPartLength)))
                        }
                    } else {
                        // after置空
                        after = ""
                    }
                }
        }
        
        if before.count <= 0 {
            return nil
        } else {
            if after.count > 0 {
                return prefix + before + String.dot + after
            } else {
                return prefix + before
            }
        }
    }
    
    /// 以符号以及第一个小数点做拆分
    public static func getComponents(string: String?) -> (`prefix`: String, before: String, after: String) {
        guard let sText = string else { return ("", "", "") }
        // 拆分单元
        var prefix = ""
        var afterText = sText
        if sText.hasSignedPrefix {
            prefix = String(sText.prefix(1))
            afterText = String(sText.suffix(sText.count - 1))
        }
        var before = afterText
        var after = ""
        if let dotIndex = afterText.firstIndex(of: Character(String.dot)) {
            before = String(afterText[afterText.startIndex..<dotIndex])
            after = String(afterText[afterText.index(dotIndex, offsetBy: 1)...])
        }
        return (prefix, before, after)
    }
}

extension LimitedInput {
    // 获取输入控件文本
    internal func getText() -> String? {
        guard let currentInput = currentInput else { return nil }
        var currentText: String?
        if let textField = currentInput as? UITextField {
            currentText = textField.text
        } else if let textView = currentInput as? UITextView {
            currentText = textView.text
        }
        return currentText
    }
    
    // 设置输入控件文本（会触发KVO）
    internal func setText(text: String?) {
        guard let currentInput = currentInput else { return }
        if let textField = currentInput as? UITextField {
            textField.text = text
        } else if let textView = currentInput as? UITextView {
            textView.text = text
        }
    }
}
