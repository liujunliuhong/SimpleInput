//
//  PlaceholderTextField.swift
//  LimitedInput
//
//  Created by jun on 2022/02/08.
//

import UIKit

open class PlaceholderTextField: UITextField {
    
    private var _placeholderTextColor: UIColor?
    /// 占位文本颜色
    open var placeholderTextColor: UIColor {
        set {
            _placeholderTextColor = newValue
            refreshPlaceholder()
        }
        get {
            var color = UIColor.gray.withAlphaComponent(0.3)
            if _placeholderTextColor != nil {
                color = _placeholderTextColor!
            } else if self.textColor != nil {
                color = self.textColor!.withAlphaComponent(0.3)
            }
            return color
        }
    }
    
    private var _placeholderFont: UIFont?
    /// 占位文本字体
    open var placeholderFont: UIFont {
        set {
            _placeholderFont = newValue
            refreshPlaceholder()
        }
        get {
            var font = UIFont.systemFont(ofSize: 12)
            if _placeholderFont != nil {
                font = _placeholderFont!
            } else if self.font != nil {
                font = self.font!
            }
            return font
        }
    }
    
    
    open override var font: UIFont? {
        didSet {
            refreshPlaceholder()
        }
    }
    
    open override var textColor: UIColor? {
        didSet {
            refreshPlaceholder()
        }
    }
    
    open override var placeholder: String? {
        didSet {
            refreshPlaceholder()
        }
    }
    
    // 测试发现，只要设置了`placeholder`，那么`attributedPlaceholder`就有值，即使外界没有设置`attributedPlaceholder`
    private var _attributedPlaceholder: NSAttributedString?
    open override var attributedPlaceholder: NSAttributedString? {
        set {
            _attributedPlaceholder = newValue
            refreshPlaceholder()
        }
        get {
            return _attributedPlaceholder
        }
    }
    
    public init() {
        super.init(frame: .zero)
        initUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlaceholderTextField {
    private func initUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(noti:)), name: UITextField.textDidChangeNotification, object: self)
        addObserver(self, forKeyPath: "text", options: [.new, .old, .initial], context: nil)
        addObserver(self, forKeyPath: "attributedText", options: [.new, .old, .initial], context: nil)
    }
}

extension PlaceholderTextField {
    private func refreshPlaceholder() {
        if attributedPlaceholder != nil {
            super.attributedPlaceholder = attributedPlaceholder
        } else {
            let text = placeholder ?? ""
            let range = NSRange(location: 0, length: text.count)
            let atr = NSMutableAttributedString(string: placeholder ?? "")
            atr.removeAttribute(.foregroundColor, range: range)
            atr.removeAttribute(.font, range: range)
            atr.addAttribute(.foregroundColor, value: placeholderTextColor, range: range)
            atr.addAttribute(.font, value: placeholderFont, range: range)
            super.attributedPlaceholder = atr
        }
    }
}


extension PlaceholderTextField {
    @objc private func textDidChange(noti: Notification) {
        guard let s = noti.object as? UITextField, s == self else { return }
        refreshPlaceholder()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" || keyPath == "attributedText" {
            refreshPlaceholder()
        }
    }
}
