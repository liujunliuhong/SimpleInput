//
//  LimitedTextfield.swift
//  LimitedInput
//
//  Created by jun on 2022/01/29.
//

import UIKit

@objc public protocol LimitedTextfieldDelegate: NSObjectProtocol {
    @objc optional func textFieldShouldBeginEditing(_ textField: LimitedTextfield) -> Bool
    
    @objc optional func textFieldDidBeginEditing(_ textField: LimitedTextfield)
    
    @objc optional func textFieldShouldEndEditing(_ textField: LimitedTextfield) -> Bool
    
    @objc optional func textFieldDidEndEditing(_ textField: LimitedTextfield)
    
    @available(iOS 10.0, *)
    @objc optional func textFieldDidEndEditing(_ textField: LimitedTextfield, reason: UITextField.DidEndEditingReason)
    
    @available(iOS 13.0, *)
    @objc optional func textFieldDidChangeSelection(_ textField: LimitedTextfield)
    
    @objc optional func textFieldShouldClear(_ textField: LimitedTextfield) -> Bool
    
    @objc optional func textFieldShouldReturn(_ textField: LimitedTextfield) -> Bool
    
    @objc optional func textField(_ textField: LimitedTextfield, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}

open class LimitedTextfield: UITextField {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 代理。在外界请使用`limitedTextfieldDelegate`代理
    open weak var limitedTextfieldDelegate: LimitedTextfieldDelegate?
    
    /// 最大长度。默认为0，表示不限制长度
    open var maxLength: Int = 0 {
        didSet {
            update()
        }
    }
    
    /// 通用策略
    /// 与`decimalPolicy`属性互斥
    open var generalPolicy: LimitedPolicy = .containsAll {
        didSet {
            
        }
    }
    
    /// 小数点策略
    /// 如果该属性不为空，则`maxLength`和`generalPolicy`将失效
    open var decimalPolicy: LimitedDecimalPolicy? {
        didSet {
            
        }
    }
    
    public init() {
        super.init(frame: .zero)
        initUI()
        setupUI()
        addNotification()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        setupUI()
        addNotification()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension LimitedTextfield {
    private func initUI() {
        delegate = self
    }
    
    private func setupUI() {
        
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(textfieldDidChange), name: UITextField.textDidChangeNotification, object: nil)
    }
}

extension LimitedTextfield {
    public func update() {
        textfieldDidChange()
    }
}

extension LimitedTextfield {
    @objc private func textfieldDidChange() {
        
        var canStrip = true
        if let markedTextRange = markedTextRange,
           let _ = position(from: markedTextRange.start, offset: 0) {
            // 有高亮文字的存在的时候，不做截取
            canStrip = false
        }
        
        if !canStrip {
            return
        }
        
        if maxLength <= 0 {
            return
        }
        
        guard var text = text else { return }
        guard text.count > maxLength else { return }
        
        
        
        
        
        var sText = text as NSString
        if text.count <= maxLength {
            return
        }
        let oldSelectedTextRange = selectedTextRange
        let range = sText.rangeOfComposedCharacterSequence(at: maxLength)
        if range.length == 1 {
            // 普通字符串，不包含表情
            let s = sText as String
            sText = s[s.startIndex..<(s.index(s.startIndex, offsetBy: maxLength))] as NSString
            //sText = sText.substring(to: maxLength) as NSString
        } else {
            // 包含表情
            let r = sText.rangeOfComposedCharacterSequences(for: NSRange(location: 0, length: maxLength))
            let s = sText as String
            sText = s[(s.index(s.startIndex, offsetBy: r.location))..<(s.index(s.startIndex, offsetBy: r.location+r.length))] as NSString
            //sText = sText.substring(with: r) as NSString
        }
        
        self.text = sText as String
        
        selectedTextRange = oldSelectedTextRange
    }
}

extension LimitedTextfield: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.limitedTextfieldDelegate?.textFieldShouldBeginEditing?(self) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.limitedTextfieldDelegate?.textFieldDidBeginEditing?(self)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.limitedTextfieldDelegate?.textFieldShouldEndEditing?(self) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.limitedTextfieldDelegate?.textFieldDidEndEditing?(self)
    }
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.limitedTextfieldDelegate?.textFieldDidEndEditing?(self, reason: reason)
    }
    
    @available(iOS 13.0, *)
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        self.limitedTextfieldDelegate?.textFieldDidChangeSelection?(self)
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self.limitedTextfieldDelegate?.textFieldShouldClear?(self) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.limitedTextfieldDelegate?.textFieldShouldReturn?(self) ?? true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let result = self.limitedTextfieldDelegate?.textField?(self, shouldChangeCharactersIn: range, replacementString: string) {
            // 如果外界实现了该协议，则以外界为准
            return result
        }
        
        if let decimalPolicy = decimalPolicy {
            switch decimalPolicy {
                case .policy1(let integerPartLength, let decimalPartLength, let allowSigned):
                    return checkPolicy1(integerPartLength: integerPartLength, decimalPartLength: decimalPartLength, allowSigned: allowSigned, replacementString: string)
                case .policy2(let totalLength, let allowSigned):
                    return checkPolicy2(totalLength: totalLength, allowSigned: allowSigned, replacementString: string)
            }
        } else {
            if generalPolicy.contains(.containsAll) {
                
            } else {
                if generalPolicy.contains(.chinese) {
                    
                }
                
            }
        }
        return true
    }
}

extension LimitedTextfield {
    
}

extension LimitedTextfield {
    private func checkPolicy1(integerPartLength: UInt, decimalPartLength: UInt, allowSigned: Bool, replacementString: String) -> Bool {
        if !replacementString.containsOnlyNumber {
            return false
        }
        //
        var sText = text ?? ""
        if sText.isEmpty && replacementString == "." {
            sText = "0."
        }
        //
        var prefix = ""
        var afterText = sText
        if sText.hasPrefix("+") || sText.hasPrefix("-") {
            prefix = String(sText[sText.startIndex..<sText.index(sText.startIndex, offsetBy: 1)])
            afterText = String(sText[sText.index(sText.startIndex, offsetBy: 1)...])
        }
        if prefix.count > 0 && !allowSigned {
            return false
        }
        if afterText.contains(".") && replacementString.contains(".") {
            return false
        }
        var integerPartString = sText
        var decimalPartString = ""
        if sText.contains(".") {
            let groups = sText.components(separatedBy: ".")
            integerPartString = groups[0]
            decimalPartString = groups[1]
        }
        if !integerPartString.containsOnlyNumber || !decimalPartString.containsOnlyNumber {
            return false
        }
        
        if integerPartString.count > integerPartLength || decimalPartString.count > decimalPartLength {
            return false
        }
        
        text = prefix + afterText
        
        return true
    }
    
    private func checkPolicy2(totalLength: UInt, allowSigned: Bool, replacementString: String) -> Bool {
        if !replacementString.containsOnlyNumber {
            return false
        }
        //
        var sText = text ?? ""
        if sText.isEmpty && replacementString == "." {
            sText = "0."
        }
        //
        var prefix = ""
        var afterText = sText
        if sText.hasPrefix("+") || sText.hasPrefix("-") {
            prefix = String(sText[sText.startIndex..<sText.index(sText.startIndex, offsetBy: 1)])
            afterText = String(sText[sText.index(sText.startIndex, offsetBy: 1)...])
        }
        if prefix.count > 0 && !allowSigned {
            return false
        }
        if afterText.contains(".") && replacementString.contains(".") {
            return false
        }
        var integerPartString = sText
        var decimalPartString = ""
        if sText.contains(".") {
            let groups = sText.components(separatedBy: ".")
            integerPartString = groups[0]
            decimalPartString = groups[1]
        }
        if !integerPartString.containsOnlyNumber || !decimalPartString.containsOnlyNumber {
            return false
        }
        
        if integerPartString.count + decimalPartString.count > totalLength {
            return false
        }
        
        text = prefix + afterText
        
        return true
    }
}
