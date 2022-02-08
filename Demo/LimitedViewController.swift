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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(label)
        view.addSubview(textField)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(150)
        }
        textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(label.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        textField.limitedInput.processChangeClosure { text in
            print("实时文本:\(text ?? "")")
        }
        textField.limitedInput.processRealChangeClosure { text in
            print("真实文本:\(text ?? "")")
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
