//
//  LimitedInput+Check.swift
//  SimpleInput
//
//  Created by jun on 2022/02/09.
//

import Foundation

extension LimitedInput {
    internal func checkRegex(regex: String) {
        guard let currentInput = currentInput else { return }
        guard let sText = text else { return }
        guard let regularExpression = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) else { return }
        var resultString: String = ""
        let results = regularExpression.matches(in: sText, options: .reportCompletion, range: NSRange(location: 0, length: (sText as NSString).length))
        for r in results {
            if r.range.location + r.range.length <= (sText as NSString).length {
                resultString = resultString.appending((sText as NSString).substring(with: r.range))
            }
        }
        //
        if maxLength <= 0 {
            // 如果长度不做限制
            setText(text: resultString)
        } else {
            if resultString.count > maxLength {
                // 如果文本长度超过做大限制
                let oldSelectedTextRange = currentInput.selectedTextRange
                resultString = String(resultString.prefix(Int(maxLength)))
                setText(text: resultString)
                currentInput.selectedTextRange = oldSelectedTextRange
            } else {
                // 如果文本长度小于最大限制
                setText(text: resultString)
            }
        }
    }
    
    internal func checkGeneral(generalPolicy: LimitedPolicy) {
        guard let currentInput = currentInput else { return }
        guard var sText = text else { return }
        // 筛选出符合条件的文本
        if !generalPolicy.contains(.containsAll) {
            sText = sText.filter { c -> Bool in
                var res = false
                if generalPolicy.contains(.number) {
                    res = res || c.isNumber
                }
                if generalPolicy.contains(.lowercaseAlphabet) {
                    res = res || c.isLowercaseAlphabet
                }
                if generalPolicy.contains(.uppercaseAlphabet) {
                    res = res || c.isUppercaseAlphabet
                }
                if generalPolicy.contains(.emoji) {
                    res = res || c.isEmoji
                }
                if generalPolicy.contains(.chinese) {
                    res = res || c.isChinese
                }
                return res
            }
        }
        //
        if maxLength <= 0 {
            // 如果长度不做限制
            setText(text: sText)
        } else {
            if sText.count > maxLength {
                // 如果文本长度超过做大限制
                let oldSelectedTextRange = currentInput.selectedTextRange
                sText = String(sText[sText.startIndex..<sText.index(sText.startIndex, offsetBy: Int(maxLength))])
                setText(text: sText)
                currentInput.selectedTextRange = oldSelectedTextRange
            } else {
                // 如果文本长度小于最大限制
                setText(text: sText)
            }
        }
    }
    
    
    internal func checkDecimal(decimalPolicy: DecimalPolicy) {
        guard let _ = currentInput else { return }
        guard let sText = text, sText.count > 0 else { return }
        //
        var allowSigned: Bool
        switch decimalPolicy {
            case .policy1(_, _, let _allowSigned):
                allowSigned = _allowSigned
            case .policy2(_, let _allowSigned):
                allowSigned = _allowSigned
            case .policy3(_, _, _, let _allowSigned):
                allowSigned = _allowSigned
        }
        // 获取符号以及后续文本
        var prefix = "" // 符号
        var afterText = sText
        if sText.hasSignedPrefix && allowSigned {
            prefix = String(sText[sText.startIndex..<sText.index(sText.startIndex, offsetBy: 1)])
            afterText = String(sText[sText.index(sText.startIndex, offsetBy: 1)...])
        }
        // 针对小数点做处理
        if afterText == String.dot {
            switch decimalPolicy {
                case .policy1(_, let decimalPartLength, _):
                    if decimalPartLength > 0 {
                        afterText = String.zero + String.dot
                    }
                case .policy2(let totalLength, _):
                    if totalLength >= 2 {
                        afterText = String.zero + String.dot
                    }
                case .policy3(_, let decimalReservedValidDigitLength, let maximumDecimalPartLength, _):
                    if decimalReservedValidDigitLength > 0 && maximumDecimalPartLength > 0 {
                        afterText = String.zero + String.dot
                    }
            }
        }
        // 对后续文本做拆分
        var before = afterText
        var after = ""
        var hasDot = false // 是否有小数点
        if let dotIndex = afterText.firstIndex(of: Character(String.dot)) {
            before = String(afterText[afterText.startIndex..<dotIndex])
            after = String(afterText[afterText.index(dotIndex, offsetBy: 1)...])
            hasDot = true
        }
        before = before.numberString
        after = after.numberString
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
        
        
        if let v = UInt64(before) {
            before = "\(v)"
        }
        //
        switch decimalPolicy {
            case .policy1(let integerPartLength, let decimalPartLength, _):
                if integerPartLength <= 0 {
                    before = ""
                    after = ""
                    hasDot = false
                } else {
                    if before.count > integerPartLength {
                        before = String(before.prefix(Int(integerPartLength)))
                    }
                    if after.count > decimalPartLength {
                        after = String(after.prefix(Int(decimalPartLength)))
                    }
                }
            case .policy2(let totalLength, _):
                if totalLength <= 0 {
                    before = ""
                    after = ""
                    hasDot = false
                } else {
                    if before.count + after.count >= totalLength {
                        if before.count < totalLength {
                            let remain = Int(totalLength) - before.count
                            after = String(after.prefix(remain))
                        } else {
                            before = String(before.prefix(Int(totalLength)))
                            after = ""
                            hasDot = false
                        }
                    }
                }
            case .policy3(let integerPartLength, let decimalReservedValidDigitLength, let maximumDecimalPartLength, _):
                if integerPartLength <= 0 {
                    before = ""
                    after = ""
                    hasDot = false
                } else {
                    before = String(before.prefix(Int(integerPartLength)))
                    
                    if decimalReservedValidDigitLength <= 0 {
                        after = ""
                        hasDot = false
                    } else if maximumDecimalPartLength <= 0 {
                        after = ""
                        hasDot = false
                    } else {
                        var leadingZeroCount: Int = 0
                        var newAfter = after
                        while newAfter.hasPrefix(String.zero) {
                            newAfter = String(newAfter.suffix(newAfter.count - 1))
                            leadingZeroCount += 1
                        }
                        
                        let s1 = String(after.prefix(leadingZeroCount)) // s1是有效数字前面的0
                        var s2 = String(after.suffix(after.count - leadingZeroCount)) // s2是有效数字
                        if s2.count > decimalReservedValidDigitLength {
                            s2 = String(s2.prefix(Int(decimalReservedValidDigitLength)))
                        }
                        after = s1 + s2 // 把0和有效数字组合
                        if after.count > maximumDecimalPartLength {
                            after = String(after.prefix(Int(maximumDecimalPartLength)))
                        }
                    }
                }
        }
        // end
        if before.count <= 0 {
            if prefix.count > 0 {
                setText(text: prefix)
            } else {
                setText(text: nil)
            }
        } else {
            if after.count <= 0 {
                if hasDot {
                    setText(text: prefix + before + String.dot)
                } else {
                    setText(text: prefix + before)
                }
            } else {
                setText(text: prefix + before + String.dot + after)
            }
        }
    }
}
