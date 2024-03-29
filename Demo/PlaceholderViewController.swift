//
//  PlaceholderViewController.swift
//  LimitedInput
//
//  Created by jun on 2022/02/08.
//

import UIKit
import SnapKit


public class PlaceholderViewController: UIViewController {

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholders.text = "请输入文本"
        textField.placeholders.color = UIColor.cyan
        textField.placeholders.font = UIFont.systemFont(ofSize: 30)
        textField.textColor = UIColor.red
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.placeholders.text = "请输入文本请输入文本请输入文本请输入文本请输入文本请输入文本请输入文本请输入文本请输入文本请输入文本请输入文本请输入文本请输入文本"
        textView.placeholders.color = UIColor.brown.withAlphaComponent(0.3)
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = UIColor.orange
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
