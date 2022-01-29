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
}



@objc public final class LimitedTextfield: UITextField {
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    /// 代理。在外界请使用`LimitedTextfieldDelegate`代理
    @objc public weak var limitedTextfield: LimitedTextfieldDelegate?
    
    /// 最大长度。默认为0，表示不限制长度
    @objc public var maxLength: Int = 0 {
        didSet {
            update()
        }
    }
    
    @objc public init() {
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
        
        guard let text = text else { return }
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
        return self.limitedTextfield?.textFieldShouldBeginEditing?(self) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.limitedTextfield?.textFieldDidBeginEditing?(self)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.limitedTextfield?.textFieldShouldEndEditing?(self) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.limitedTextfield?.textFieldDidEndEditing?(self)
    }
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.limitedTextfield?.textFieldDidEndEditing?(self, reason: reason)
    }
    
    @available(iOS 13.0, *)
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        self.limitedTextfield?.textFieldDidChangeSelection?(self)
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self.limitedTextfield?.textFieldShouldClear?(self) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.limitedTextfield?.textFieldShouldReturn?(self) ?? true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
