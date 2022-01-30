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
        
        
        //let string = "哈哈😏🤲👨‍👨‍👧‍👦👩‍👩‍👧‍👦👩‍👩‍👧👨‍👩‍👧‍👦😄☺️☁️abcd1234"
//        let string = "☁️"
//        let string = "3️⃣"
//        let string = "➒"
//        let string = "3"
        let string = "☺️"
        
//        let count = string.count
//        let length = (string as NSString).length
//        print("count:\(count)")    // 12
//        print("length:\(length)")  // 14（😄是一个组合字符，占了2个字符）
//
//        let subString = String(string[string.startIndex..<string.index(string.startIndex, offsetBy: 3)])
//        print("subString: \(subString)") // 哈哈😄
//
//        let subString1 = (string as NSString).substring(with: NSRange(location: 0, length: 3))
//        print("subString1: \(subString1)") // 哈哈�（😄表情被截断）
        
        
        
//        let index = string.index(string.startIndex, offsetBy: 1)
//        let range = string.rangeOfComposedCharacterSequence(at: index)
//        print(range.lowerBound)
//        print(range.upperBound)
        
        
        // OC版本的
        // 将emoji表情视为一个连续的字符串，如果index处于连续的字符串之间，就会返回这个字符串的range
//        let range = (string as NSString).rangeOfComposedCharacterSequence(at: 8)
//        print(range)
        
        /*
         如果指定的index位置是一个组合字符，那么返回给定组合字符的range，range的length大于2
         如果指定的index位置不是一个组合字符，仍然返回一个range，只不过range的length等于1
         open func rangeOfComposedCharacterSequence(at index: Int) -> NSRange
         
         
         如果指定的range内部包含组合字符，那么返回包含组合字符的真实range
         如果指定的range内部不包含组合字符，那么返回的range和传入的range是相等的
         open func rangeOfComposedCharacterSequences(for range: NSRange) -> NSRange
         */
//        let range = (string as NSString).rangeOfComposedCharacterSequences(for: NSRange(location: 0, length: 5))
//        print(range)
        
        
        print("------------------------------------")
        for scalar in string.unicodeScalars {
            print("value:\(scalar.value) - isEmoji:\(scalar.properties.isEmoji) - isEmojiPresentation:\(scalar.properties.isEmojiPresentation) - isEmojiModifier:\(scalar.properties.isEmojiModifier) - isEmojiModifierBase:\(scalar.properties.isEmojiModifierBase) - isJoinControl:\(scalar.properties.isJoinControl) - isVariationSelector:\(scalar.properties.isVariationSelector) - description:\(scalar.description)")
        }
        print(string.containsEmoji)
        print(string.emojis)
        
        
        print("------------------------------------")
        //let numberString = "0123456789"
//        let numberString = "劉"
        let numberString = "軍"
        
        print(numberString.containsChinese)
        
        
        
        
    }


}


//extension ViewController: LimitedTextfieldDelegate {
//
//
//
//}

