//
//  LimitedTextfield.swift
//  LimitedInput
//
//  Created by jun on 2022/01/29.
//

import UIKit

public protocol LimitedTextfieldDelegate: NSObjectProtocol {
    func textFieldShouldBeginEditing(_ textField: LimitedTextfield) -> Bool
    
    func textFieldDidBeginEditing(_ textField: LimitedTextfield)
    
    func textFieldShouldEndEditing(_ textField: LimitedTextfield) -> Bool
    
    func textFieldDidEndEditing(_ textField: LimitedTextfield)
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: LimitedTextfield, reason: UITextField.DidEndEditingReason)
    
    @available(iOS 13.0, *)
    func textFieldDidChangeSelection(_ textField: LimitedTextfield)
    
    func textFieldShouldClear(_ textField: LimitedTextfield) -> Bool
    
    func textFieldShouldReturn(_ textField: LimitedTextfield) -> Bool
    
    func textField(_ textField: LimitedTextfield, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}

extension LimitedTextfieldDelegate {
    func textFieldShouldBeginEditing(_ textField: LimitedTextfield) -> Bool { return true }
    
    func textFieldDidBeginEditing(_ textField: LimitedTextfield) { }
    
    func textFieldShouldEndEditing(_ textField: LimitedTextfield) -> Bool { return true }
    
    func textFieldDidEndEditing(_ textField: LimitedTextfield) { }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: LimitedTextfield, reason: UITextField.DidEndEditingReason) { }
    
    @available(iOS 13.0, *)
    func textFieldDidChangeSelection(_ textField: LimitedTextfield) { }
    
    func textFieldShouldClear(_ textField: LimitedTextfield) -> Bool { return true }
    
    func textFieldShouldReturn(_ textField: LimitedTextfield) -> Bool { return true }
    
    func textField(_ textField: LimitedTextfield, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { return true }
}



public final class LimitedTextfield: UITextField {
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    /// 代理。在外界请使用`LimitedTextfieldDelegate`代理
    public weak var limitedTextfield: LimitedTextfieldDelegate?
    
    /// 最大长度。默认为0，表示不限制长度
    public var maxLength: Int = 0 {
        didSet {
            update()
        }
    }
    
    public var generalPolicy: LimitedPolicy = .containsAll {
        didSet {
            
        }
    }
    
    public var decimalPolicy: LimitedDecimalPolicy? {
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
        return self.limitedTextfield?.textFieldShouldBeginEditing(self) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.limitedTextfield?.textFieldDidBeginEditing(self)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.limitedTextfield?.textFieldShouldEndEditing(self) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.limitedTextfield?.textFieldDidEndEditing(self)
    }
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.limitedTextfield?.textFieldDidEndEditing(self, reason: reason)
    }
    
    @available(iOS 13.0, *)
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        self.limitedTextfield?.textFieldDidChangeSelection(self)
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self.limitedTextfield?.textFieldShouldClear(self) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.limitedTextfield?.textFieldShouldReturn(self) ?? true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let limitedTextfield = limitedTextfield {
            return limitedTextfield.textField(self, shouldChangeCharactersIn: range, replacementString: string)
        }
        
        if let decimalPolicy = decimalPolicy {
            switch decimalPolicy {
                case .policy1(let integerPartLength, let decimalPartLength, let unsigned):
                    print(1)
                case .policy2(let totalLength, let unsigned):
                    print("2")
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
