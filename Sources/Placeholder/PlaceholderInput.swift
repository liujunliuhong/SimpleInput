//
//  PlaceholderInput.swift
//  SimpleInput
//
//  Created by jun on 2022/02/10.
//

import Foundation
import UIKit

public class PlaceholderInput {
    
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
    
    private var hasAddObserver = false
    private var _object: _Object?
    
    /// 实现`UITextInput`协议的控件，此处特指`UITextField`和`UITextView`
    public weak var currentInput: UITextInput?
    
    public init(currentInput: UITextInput) {
        self.currentInput = currentInput
        self._object = _Object(placeholder: self)
    }
    
    /// 占位文本
    public var text: String? {
        didSet {
            startObserver()
        }
    }
    
    /// 占位文本颜色
    public var color: UIColor? {
        didSet {
            startObserver()
        }
    }
    
    /// 占位字体
    public var font: UIFont? {
        didSet {
            startObserver()
        }
    }
    
    /// 属性占位符，优先级高于`text`
    public var attributedText: NSAttributedString? {
        didSet {
            startObserver()
        }
    }
}

extension PlaceholderInput {
    private func startObserver() {
        guard let _object = self._object else { return }
        // 将整个代码放在一个Block里面，这样设置，即使text赋值在之前，也能完美监听
        if let tf = self.currentInput as? UITextField {
            updateTextFieldPlaholder()
            if hasAddObserver { return }
            DispatchQueue.main.async {
                // 监控text属性值变化
                tf.addObserver(_object, forKeyPath: "font", options: [.new, .old, .initial], context: nil)
                tf.addObserver(_object, forKeyPath: "textColor", options: [.new, .old, .initial], context: nil)
                tf.addObserver(_object, forKeyPath: "textAlignment", options: [.new, .old, .initial], context: nil)
                tf.addObserver(_object, forKeyPath: "attributedText", options: [.new, .old, .initial], context: nil)
                // 监控输入框文本变化
                NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldDidChange(noti:)), name: UITextField.textDidChangeNotification, object: nil)
            }
            hasAddObserver = true
        } else if let tv = self.currentInput as? UITextView {
            updateTextViewPlaholder()
            if hasAddObserver { return }
            DispatchQueue.main.async {
                // 监控text属性值变化
                tv.addObserver(_object, forKeyPath: "text", options: [.new, .old, .initial], context: nil)
                tv.addObserver(_object, forKeyPath: "font", options: [.new, .old, .initial], context: nil)
                tv.addObserver(_object, forKeyPath: "textColor", options: [.new, .old, .initial], context: nil)
                tv.addObserver(_object, forKeyPath: "textAlignment", options: [.new, .old, .initial], context: nil)
                tv.addObserver(_object, forKeyPath: "frame", options: [.new, .old, .initial], context: nil)
                tv.addObserver(_object, forKeyPath: "attributedText", options: [.new, .old, .initial], context: nil)
                tv.addObserver(_object, forKeyPath: "textContainerInset", options: [.new, .old, .initial], context: nil)
                tv.addObserver(_object, forKeyPath: "textContainer.lineFragmentPadding", options: [.new, .old, .initial], context: nil)
                // 监控输入框文本变化
                NotificationCenter.default.addObserver(self, selector: #selector(self.textViewDidChange(noti:)), name: UITextView.textDidChangeNotification, object: nil)
            }
            hasAddObserver = true
        }
    }
}

extension PlaceholderInput {
    @objc private func textFieldDidChange(noti: Notification) {
        guard let textField = currentInput as? UITextField else { return }
        guard let s = noti.object as? UITextField, s == textField else { return }
        updateTextFieldPlaholder()
    }
    
    @objc private func textViewDidChange(noti: Notification) {
        guard let textView = currentInput as? UITextView else { return }
        guard let s = noti.object as? UITextView, s == textView else { return }
        updateTextViewPlaholder()
    }
}

extension PlaceholderInput {
    internal func updateTextFieldPlaholder() {
        guard let textField = currentInput as? UITextField else { return }
        if attributedText != nil {
            textField.attributedPlaceholder = attributedText
        } else {
            guard let text = self.text else {
                textField.attributedPlaceholder = nil
                return
            }
            var color = UIColor.gray.withAlphaComponent(0.3)
            if self.color != nil {
                color = self.color!
            } else if textField.textColor != nil {
                color = textField.textColor!.withAlphaComponent(0.3)
            }
            
            var font = UIFont.systemFont(ofSize: 12)
            if self.font != nil {
                font = self.font!
            } else if textField.font != nil {
                font = textField.font!
            }
            
            let p = NSMutableParagraphStyle()
            p.alignment = textField.textAlignment
            
            let range = NSRange(location: 0, length: text.count)
            let atr = NSMutableAttributedString(string: text)
            atr.removeAttribute(.foregroundColor, range: range)
            atr.removeAttribute(.font, range: range)
            atr.removeAttribute(.paragraphStyle, range: range)
            atr.addAttribute(.foregroundColor, value: color, range: range)
            atr.addAttribute(.font, value: font, range: range)
            atr.addAttribute(.paragraphStyle, value: p, range: range)
            textField.attributedPlaceholder = atr
        }
    }
    
    internal func updateTextViewPlaholder() {
        guard let textView = currentInput as? UITextView else { return }
        if textView.frame.size.width.isLessThanOrEqualTo(.zero) || textView.frame.size.height.isLessThanOrEqualTo(.zero) {
            placeholderLabel.isHidden = true
            return
        }
        
        if placeholderLabel.superview == nil {
            textView.addSubview(placeholderLabel)
        }
        
        if attributedText != nil {
            placeholderLabel.attributedText = attributedText
        } else {
            placeholderLabel.text = text
            
            var font = UIFont.systemFont(ofSize: 12)
            if self.font != nil {
                font = self.font!
            } else if textView.font != nil {
                font = textView.font!
            }
            placeholderLabel.font = font
            
            var color = UIColor.gray.withAlphaComponent(0.3)
            if self.color != nil {
                color = self.color!
            } else if textView.textColor != nil {
                color = textView.textColor!.withAlphaComponent(0.3)
            }
            placeholderLabel.textColor = color
            
            placeholderLabel.textAlignment = textView.textAlignment
        }
        
        if (textView.text != nil && textView.text!.count > 0) || (textView.attributedText != nil && textView.attributedText!.length > 0) {
            placeholderLabel.isHidden = true
        } else {
            placeholderLabel.isHidden = false
        }
        
        
        let insets = UIEdgeInsets(top: textView.textContainerInset.top,
                                  left: textView.textContainerInset.left + textView.textContainer.lineFragmentPadding,
                                  bottom: textView.textContainerInset.bottom,
                                  right: textView.textContainerInset.right + textView.textContainer.lineFragmentPadding)
        let maxWidth = textView.frame.size.width - insets.left - insets.right
        let maxHeight = textView.frame.size.height - insets.top - insets.bottom
        let expectedSize = placeholderLabel.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
        placeholderLabel.frame = CGRect(x: insets.left,
                                        y: insets.top,
                                        width: expectedSize.width,
                                        height: expectedSize.height)
    }
}

fileprivate class _Object: NSObject {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private weak var placeholder: PlaceholderInput?
    init(placeholder: PlaceholderInput) {
        self.placeholder = placeholder
        super.init()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? UITextView {
            if keyPath == "frame" ||
                keyPath == "text" ||
                keyPath == "font" ||
                keyPath == "textColor" ||
                keyPath == "textAlignment" ||
                keyPath == "attributedText" ||
                keyPath == "textContainerInset" ||
                keyPath == "textContainer.lineFragmentPadding" {
                self.placeholder?.updateTextViewPlaholder()
            }
        } else if let _ = object as? UITextField {
            if keyPath == "font" ||
                keyPath == "textColor" ||
                keyPath == "textAlignment" ||
                keyPath == "attributedText" {
                self.placeholder?.updateTextFieldPlaholder()
            }
        }
    }
}
