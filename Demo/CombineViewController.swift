//
//  CombineViewController.swift
//  SimpleInput
//
//  Created by jun on 2022/02/10.
//

import UIKit
import SnapKit

public class CombineViewController: UIViewController {

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholders.text = "我是占位(最大长度：10，通用策略：只能输入中文)"
        textField.placeholders.color = UIColor.cyan
        textField.textColor = UIColor.red
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.limitedInput.maxLength = 10
        textField.limitedInput.generalPolicy = .chinese
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.placeholders.text = "我是占位(最大长度：15，小数策略：整数部分2位，小数部分3位，不能输入符号)"
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = UIColor.orange
        textView.limitedInput.maxLength = 15
        textView.limitedInput.decimalPolicy = .policy1(integerPartLength: 2, decimalPartLength: 3, allowSigned: false)
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.black.cgColor
        return textView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.top.equalToSuperview().offset(100)
            make.height.equalTo(55)
        }
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.top.equalTo(textField.snp.bottom).offset(25)
            make.height.equalTo(300)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
