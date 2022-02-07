//
//  ViewController.swift
//  LimitedInput
//
//  Created by jun on 2022/01/29.
//

import UIKit

class ViewController: UIViewController {

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        let textField = UITextField()
        textField.limitedInput.maxLength = 5
        textField.limitedInput.generalPolicy = [.chinese, .emoji]
        //textField.limitedInput.decimalPolicy = .policy1(integerPartLength: 3, decimalPartLength: 5, allowSigned: true)
        //textField.limitedInput.decimalPolicy = .policy2(totalLength: 0, allowSigned: false)
        textField.backgroundColor = .orange
        view.addSubview(textField)
        
        textField.frame = CGRect(x: 20, y: 100, width: 300, height: 40)
        
    }
}
