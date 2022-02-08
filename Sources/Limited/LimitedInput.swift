//
//  LimitedInput.swift
//  LimitedInput
//
//  Created by jun on 2022/02/07.
//

import Foundation
import UIKit

public class LimitedInput {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var changeClosures:[(String?)->()] = []
    private var realChangeClosures:[(String?)->()] = []
    private var hasAddObserver = false
    private var _object: _Object?
    
    /// 实现`UITextInput`协议的控件，此处特指`UITextField`和`UITextView`
    public weak var currentInput: UITextInput?
    
    public init(currentInput: UITextInput) {
        self.currentInput = currentInput
        self._object = _Object(input: self)
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
    public var decimalPolicy: DecimalPolicy? {
        didSet {
            startObserver()
        }
    }
    
    /// 获取输入框的内容(已对小数策略做了处理)
    public var text: String? {
        guard var sText = getText() else { return nil }
        // 针对小数策略，做特殊处理
        if let _ = decimalPolicy {
            // 去除尾部的0和小数点，比如输入框的内容为`0.120`或者`5.`
            let groups = sText.components(separatedBy: String.dot)
            if groups.count == 2 {
                var s = groups[1]
                while true {
                    if s.hasSuffix(String.zero) {
                        s = String(s.prefix(s.count - 1))
                    } else {
                        break
                    }
                }
                if s.count <= 0 {
                    sText = groups[0]
                } else {
                    sText = groups[0] + String.dot + s
                }
            }
            if sText.hasSignedPrefix {
                // 针对输入框只有`+`或者`-`的情况
                let after = String(sText.suffix(sText.count - 1))
                if after.count <= 0 {
                    return nil
                }
            }
        }
        return sText
    }
    
    /// 获取真实文本内容(针对小数策略做了特殊处理)
    public var realText: String? {
        guard let sText = text else { return nil }
        // 针对小数策略，做特殊处理
        if let decimalPolicy = decimalPolicy {
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
            before = before.numberString
            after = after.numberString
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
        return sText
    }
    
    public func updateInput() {
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
        DispatchQueue.main.async {
            for f in self.changeClosures {
                f(self.text)
            }
            for f in self.realChangeClosures {
                f(self.realText)
            }
        }
    }
    
    public func processChangeClosure(_ closure:((String?)->())?) {
        if closure != nil {
            changeClosures.append(closure!)
        }
    }
    
    public func processRealChangeClosure(_ closure:((String?)->())?) {
        if closure != nil {
            realChangeClosures.append(closure!)
        }
    }
}

extension LimitedInput {
    private func startObserver() {
        updateInput()
        guard let _object = self._object else { return }
        if hasAddObserver { return }
        // 将整个见天代码放在一个Block里面，这样设置，即使text赋值在之前，也能完美监听
        if let tf = self.currentInput as? UITextField {
            DispatchQueue.main.async {
                // 监控text属性值变化
                tf.addObserver(_object, forKeyPath: "text", options: [.new, .old, .initial], context: nil)
                // 监控输入框文本变化
                NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldDidChange(noti:)), name: UITextField.textDidChangeNotification, object: nil)
            }
            hasAddObserver = true
        } else if let tv = self.currentInput as? UITextView {
            DispatchQueue.main.async {
                // 监控text属性值变化
                tv.addObserver(_object, forKeyPath: "text", options: [.new, .old, .initial], context: nil)
                // 监控输入框文本变化
                NotificationCenter.default.addObserver(self, selector: #selector(self.textViewDidChange(noti:)), name: UITextView.textDidChangeNotification, object: nil)
            }
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
}

extension LimitedInput {
    private func checkGeneral(generalPolicy: LimitedPolicy) {
        guard let currentInput = currentInput else { return }
        guard var sText = getText() else { return }
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
    
    
    private func checkDecimal(decimalPolicy: DecimalPolicy) {
        guard let _ = currentInput else { return }
        guard let sText = getText(), sText.count > 0 else { return }
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
            case .policy3(let integerPartLength, let decimalReservedValidDigitLength, let maximumDecimalPartLength, _):
                if before.count > integerPartLength {
                    if integerPartLength <= 0 {
                        after = ""
                        hasDot = false
                    } else {
                        before = String(before[before.startIndex..<before.index(before.startIndex, offsetBy: Int(integerPartLength))])
                    }
                }
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
                    if maximumDecimalPartLength <= 0 {
                        after = ""
                        hasDot = false
                    } else {
                        after = String(after.prefix(Int(maximumDecimalPartLength)))
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
            case .policy3(let integerPartLength, let decimalReservedValidDigitLength, let maximumDecimalPartLength, _):
                if integerPartLength <= 0 {
                    setText(text: nil)
                } else {
                    if decimalReservedValidDigitLength > 0 && maximumDecimalPartLength > 0 && hasDot {
                        setText(text: prefix + before + String.dot + after)
                    } else {
                        setText(text: prefix + before)
                    }
                }
        }
    }
}

extension LimitedInput {
    // 获取输入控件文本
    private func getText() -> String? {
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
    private func setText(text: String?) {
        guard let currentInput = currentInput else { return }
        if let textField = currentInput as? UITextField {
            textField.text = text
        } else if let textView = currentInput as? UITextView {
            textView.text = text
        }
    }
}


fileprivate class _Object: NSObject {
    private weak var input: LimitedInput?
    init(input: LimitedInput) {
        self.input = input
        super.init()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let new = (change?[.newKey] as? String) ?? ""
        let old = (change?[.oldKey] as? String) ?? ""
        //print("new: \(new) -- old: \(old)")
        if old != new {
            // 只有当新值和旧值不相等才更新
            self.input?.updateInput()
            //print("update")
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


