//
//  LimitedViewController.swift
//  LimitedInput
//
//  Created by jun on 2022/02/08.
//

import UIKit
import SnapKit

public class LimitedViewController: UIViewController {
    
    public private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    public private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()
    
    public private(set) lazy var textView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.black.cgColor
        return textView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(label)
        view.addSubview(textField)
        view.addSubview(textView)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(100)
        }
        textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(label.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.height.equalTo(100)
        }
        textField.limitedInput.processChangeClosure { text in
            print("[UITextField] 实时文本:\(text ?? "")")
        }
        textField.limitedInput.processRealChangeClosure { text in
            print("[UITextField] 真实文本:\(text ?? "")")
        }
        textField.limitedInput.processRealDecimalChangeClosure { text in
            print("[UITextField] 真实小数文本:\(text ?? "")")
        }
        textView.limitedInput.processChangeClosure { text in
            print("[UITextView] 实时文本:\(text ?? "")")
        }
        textView.limitedInput.processRealChangeClosure { text in
            print("[UITextView] 真实文本:\(text ?? "")")
        }
        textView.limitedInput.processRealDecimalChangeClosure { text in
            print("[UITextView] 真实小数文本:\(text ?? "")")
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
