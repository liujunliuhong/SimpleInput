//
//  LimitedInput.swift
//  LimitedInput
//
//  Created by jun on 2022/02/07.
//

import Foundation
import UIKit

private var hasAddObserver = false

public class LimitedInput {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public weak var currentInput: UITextInput?
    public init(currentInput: UITextInput) {
        self.currentInput = currentInput
    }
    
    /// 最大长度
    /// 默认为0，表示不限制长度
    public var maxLength: UInt = 0 {
        didSet {
            startObserver()
        }
    }
    
    /// 通用策略
    /// 与`decimalPolicy`属性互斥
    public var generalPolicy: LimitedPolicy? {
        didSet {
            startObserver()
        }
    }
    
    /// 小数策略
    /// 如果该属性不为空，则`maxLength`和`generalPolicy`将失效
    public var decimalPolicy: LimitedDecimalPolicy? {
        didSet {
            startObserver()
        }
    }
    
    private var _placeholder: String?
    public var placeholder: String? {
        set {
            _placeholder = newValue
        }
        get {
            return _placeholder
        }
    }
    
    public var placeholderFont: UIFont {
        get {
            
        }
        set {
            
        }
    }
    
    public var placeholderColor: UIColor? {
        get {
            
        }
        set {
            
        }
    }
    
    /// 获取输入框的内容
    public var text: String? {
        guard var sText = getText() else { return nil }
        if let _ = decimalPolicy {
            while true {
                if sText.contains(String.dot) {
                    if sText.hasSuffix(String.zero) {
                        sText = String(sText[sText.startIndex..<sText.index(sText.startIndex, offsetBy: sText.count - 1)])
                    }
                    if sText.hasSuffix(String.dot) {
                        sText = String(sText[sText.startIndex..<sText.index(sText.startIndex, offsetBy: sText.count - 1)])
                    }
                } else {
                    break
                }
            }
        }
        return sText
    }
}

extension LimitedInput {
    private func startObserver() {
        updateInput()
        if hasAddObserver { return }
        if let _ = currentInput as? UITextField {
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(noti:)), name: UITextField.textDidChangeNotification, object: nil)
            hasAddObserver = true
        } else if let _ = currentInput as? UITextView {
            NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange(noti:)), name: UITextView.textDidChangeNotification, object: nil)
            hasAddObserver = true
        }
    }
}

extension LimitedInput {
    @objc private func textFieldDidChange(noti: Notification) {
        guard let textField = currentInput as? UITextField else { return }
        guard let s = noti.object as? UITextField, s == textField else { return }
        updateInput()
    }
    
    @objc private func textViewDidChange(noti: Notification) {
        guard let textView = currentInput as? UITextView else { return }
        guard let s = noti.object as? UITextView, s == textView else { return }
        updateInput()
    }
    
    private func updateInput() {
        guard let currentInput = currentInput else { return }
        if currentInput.hasMarkedText {
            // 有高亮文字的存在的时候，不做截取
            return
        }
        if let decimalPolicy = decimalPolicy {
            checkDecimal(decimalPolicy: decimalPolicy)
        } else if let generalPolicy = generalPolicy {
            checkGeneral(generalPolicy: generalPolicy)
        }
    }
}

extension LimitedInput {
    func checkGeneral(generalPolicy: LimitedPolicy) {
        guard let currentInput = currentInput else { return }
        guard var sText = getText() else { return }
        if generalPolicy.contains(.containsAll) { return }
        
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
        setText(text: sText)
        guard var sText = getText() else { return }
        
        if maxLength <= 0 { return }
        guard sText.count > maxLength else { return }
        
        sText = String(sText[sText.startIndex..<sText.index(sText.startIndex, offsetBy: Int(maxLength))])
        
        let oldSelectedTextRange = currentInput.selectedTextRange
        
        if let textField = currentInput as? UITextField {
            textField.text = sText
        } else if let textView = currentInput as? UITextView {
            textView.text = sText
        }
        
        currentInput.selectedTextRange = oldSelectedTextRange
    }
    
    
    private func checkDecimal(decimalPolicy: LimitedDecimalPolicy) {
        guard let _ = currentInput else { return }
        guard let sText = getText(), sText.count > 0 else { return }
        //
        var allowSigned: Bool
        switch decimalPolicy {
            case .policy1(_, _, let _allowSigned):
                allowSigned = _allowSigned
            case .policy2(_, let _allowSigned):
                allowSigned = _allowSigned
        }
        //
        var prefix = "" // 符号
        var afterText = sText
        if sText.hasSignedPrefix && allowSigned {
            prefix = String(sText[sText.startIndex..<sText.index(sText.startIndex, offsetBy: 1)])
            afterText = String(sText[sText.index(sText.startIndex, offsetBy: 1)...])
        }
        //
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
            }
        }
        //
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
        if let v = UInt64(before) {
            before = "\(v)"
        }
        //
        switch decimalPolicy {
            case .policy1(let integerPartLength, let decimalPartLength, _):
                if before.count > integerPartLength {
                    before = String(before[before.startIndex..<before.index(before.startIndex, offsetBy: Int(integerPartLength))])
                }
                if after.count > decimalPartLength {
                    after = String(after[after.startIndex..<after.index(after.startIndex, offsetBy: Int(decimalPartLength))])
                }
            case .policy2(let totalLength, _):
                if before.count + after.count >= totalLength {
                    if before.count < totalLength {
                        let remain = Int(totalLength) - before.count
                        after = String(after[after.startIndex..<after.index(after.startIndex, offsetBy: remain)])
                    } else {
                        before = String(before[before.startIndex..<before.index(before.startIndex, offsetBy: Int(totalLength))])
                        after = ""
                        hasDot = false
                    }
                }
        }
        // end
        switch decimalPolicy {
            case .policy1(let integerPartLength, let decimalPartLength, _):
                if integerPartLength <= 0 {
                    setText(text: nil)
                } else {
                    if decimalPartLength > 0 && hasDot {
                        setText(text: prefix + before + String.dot + after)
                    } else {
                        setText(text: prefix + before)
                    }
                }
            case .policy2(_, _):
                if hasDot {
                    setText(text: prefix + before + String.dot + after)
                } else {
                    setText(text: prefix + before)
                }
        }
    }
}

extension LimitedInput {
    private func getText() -> String? {
        var currentText: String?
        if let textField = currentInput as? UITextField {
            currentText = textField.text
        } else if let textView = currentInput as? UITextView {
            currentText = textView.text
        }
        return currentText
    }
    
    private func setText(text: String?) {
        if let textField = currentInput as? UITextField {
            textField.text = text
        } else if let textView = currentInput as? UITextView {
            textView.text = text
        }
    }
}

/*
 * 将emoji表情视为一个连续的字符串，如果index处于连续的字符串之间，就会返回这个字符串的range
 * let range = (string as NSString).rangeOfComposedCharacterSequence(at: 8)
 *
 *
 * 如果指定的index位置是一个组合字符，那么返回给定组合字符的range，range的length大于2
 * 如果指定的index位置不是一个组合字符，仍然返回一个range，只不过range的length等于1
 * open func rangeOfComposedCharacterSequence(at index: Int) -> NSRange
 */
