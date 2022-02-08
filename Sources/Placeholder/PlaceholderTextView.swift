//
//  PlaceholderTextView.swift
//  LimitedInput
//
//  Created by jun on 2022/02/08.
//

import UIKit

open class PlaceholderTextView: UITextView {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = .clear
        placeholderLabel.isHidden = true
        placeholderLabel.lineBreakMode = .byWordWrapping
        return placeholderLabel
    }()
    
    
    private var _placeholder: String?
    /// 占位文本
    open var placeholder: String? {
        set {
            _placeholder = newValue
            refreshPlaceholder()
        }
        get {
            return _placeholder
        }
    }
    
    
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
            } else if textColor != nil {
                color = textColor!.withAlphaComponent(0.3)
            }
            return color
        }
    }
    
    
    private var _placeholderFont: UIFont?
    /// 占位字体
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
    
    
    private var _attributedPlaceholder: NSAttributedString?
    /// 属性占位符，优先级高于`placeholder`
    open var attributedPlaceholder: NSAttributedString? {
        set {
            _attributedPlaceholder = newValue
            refreshPlaceholder()
        }
        get {
            return _attributedPlaceholder
        }
    }
    
    open override var font: UIFont? {
        didSet {
            refreshPlaceholder()
        }
    }
    
    open override var textAlignment: NSTextAlignment {
        didSet {
            refreshPlaceholder()
        }
    }
    
    open override var textColor: UIColor? {
        didSet {
            refreshPlaceholder()
        }
    }
    
    open override var text: String! {
        didSet {
            refreshPlaceholder()
        }
    }
    
    open override var attributedText: NSAttributedString! {
        didSet {
            refreshPlaceholder()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let insets = UIEdgeInsets(top: textContainerInset.top,
                                  left: textContainerInset.left + textContainer.lineFragmentPadding,
                                  bottom: textContainerInset.bottom,
                                  right: textContainerInset.right + textContainer.lineFragmentPadding)
        let maxWidth = bounds.size.width - insets.left - insets.right
        let maxHeight = bounds.size.height - insets.top - insets.bottom
        let expectedSize = placeholderLabel.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
        placeholderLabel.frame = CGRect(x: insets.left,
                                        y: insets.top,
                                        width: expectedSize.width,
                                        height: expectedSize.height)
    }
    
    public init() {
        super.init(frame: .zero, textContainer: nil)
        initUI()
        setupUI()
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initUI()
        setupUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlaceholderTextView {
    private func initUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(noti:)), name: UITextView.textDidChangeNotification, object: self)
        addObserver(self, forKeyPath: "text", options: [.new, .old, .initial], context: nil)
        addObserver(self, forKeyPath: "attributedText", options: [.new, .old, .initial], context: nil)
    }
    
    private func setupUI() {
        addSubview(placeholderLabel)
    }
}

extension PlaceholderTextView {
    @objc private func textDidChange(noti: Notification) {
        guard let s = noti.object as? UITextView, s == self else { return }
        refreshPlaceholder()
    }
    
    private func refreshPlaceholder() {
        if attributedPlaceholder != nil {
            placeholderLabel.attributedText = attributedPlaceholder
        } else {
            //
            placeholderLabel.text = placeholder
            placeholderLabel.font = placeholderFont
            placeholderLabel.textColor = placeholderTextColor
            placeholderLabel.textAlignment = self.textAlignment
        }
        
        if (self.text != nil && self.text!.count > 0) || (self.attributedText != nil && self.attributedText!.length > 0) {
            placeholderLabel.isHidden = true
        } else {
            placeholderLabel.isHidden = false
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" || keyPath == "attributedText" {
            refreshPlaceholder()
        }
    }
}
