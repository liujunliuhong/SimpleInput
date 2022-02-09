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
    private var realDecimalChangeClosures:[(String?)->()] = []
    
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
    
    /// 正则表达式，需要匹配的内容(优先级最高)
    /// 当设置了该属性，那么`generalPolicy`、`decimalPolicy`将失效，`maxLength`仍将有效
    public var regex: String? {
        didSet {
            startObserver()
        }
    }
    
    /// 获取输入框的内容
    public var text: String? {
        return getText()
    }
    
    /// 获取输入框的内容(已对小数策略做了处理)
    /// 0.120 => 0.12
    /// 5. => 5
    /// +0. => +0
    /// + => nil
    public var realText: String? {
        return LimitedInput.getRealText(decimalPolicy: decimalPolicy, text: text)
    }
    
    /// 获取真实小数文本内容(针对小数策略做了特殊处理)
    /// 比如`decimalPolicy`设置为`.policy1(integerPartLength: 2, decimalPartLength: 3, allowSigned: false)`
    /// 输入框的值为`2.3`，那么`realDecimalText`将返回`2.300`
    public var realDecimalText: String? {
        return LimitedInput.getRealDecimalText(decimalPolicy: decimalPolicy, text: text)
    }
    
    /// 原始文本实时回调
    public func processChangeClosure(_ closure:((String?)->())?) {
        if closure != nil {
            changeClosures.append(closure!)
        }
    }
    
    /// 真实文本回调(对decimalPolicy做了处理)
    public func processRealChangeClosure(_ closure:((String?)->())?) {
        if closure != nil {
            realChangeClosures.append(closure!)
        }
    }
    
    /// 真实小数策略文本回调(对decimalPolicy做了处理)
    public func processRealDecimalChangeClosure(_ closure:((String?)->())?) {
        if closure != nil {
            realDecimalChangeClosures.append(closure!)
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
    
    /// 更新输入
    /// 当设置了maxLength，且此时输入已达到最大长度，再次输入，该方法将会调用2次
    /// 第一次：textDidChangeNotification监听输入
    /// 第二次：KVO监听输入
    public func updateInput() {
        guard let currentInput = currentInput else { return }
        if currentInput.hasMarkedText {
            // 有高亮文字的存在的时候，不做截取
            return
        }
        if let regex = regex {
            checkRegex(regex: regex)
        } else {
            if let decimalPolicy = decimalPolicy {
                checkDecimal(decimalPolicy: decimalPolicy)
            } else if let generalPolicy = generalPolicy {
                checkGeneral(generalPolicy: generalPolicy)
            }
        }
        DispatchQueue.main.async {
            for f in self.changeClosures {
                f(self.text)
            }
            for f in self.realChangeClosures {
                f(self.realText)
            }
            for f in self.realDecimalChangeClosures {
                f(self.realDecimalText)
            }
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


