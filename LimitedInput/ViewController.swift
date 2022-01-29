//
//  ViewController.swift
//  LimitedInput
//
//  Created by jun on 2022/01/29.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        
        let textField = LimitedTextfield()
        textField.maxLength = 10
        textField.backgroundColor = .orange
        view.addSubview(textField)
        
        textField.frame = CGRect(x: 20, y: 100, width: 300, height: 40)
    }


}


//extension ViewController: LimitedTextfieldDelegate {
//
//
//
//}
