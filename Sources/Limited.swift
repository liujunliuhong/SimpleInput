//
//  Limited.swift
//  LimitedInput
//
//  Created by galaxy on 2022/2/6.
//

import Foundation
import UIKit


private struct AssociatedKeys {
    static var limitedInput = "com.galaxy.limitedInput.key"
}

extension UITextInput {
    public var limitedInput: LimitedInput {
        if let l = objc_getAssociatedObject(self, &AssociatedKeys.limitedInput) as? LimitedInput {
            return l
        } else {
            let l = LimitedInput(currentInput: self)
            objc_setAssociatedObject(self, &AssociatedKeys.limitedInput, l, .OBJC_ASSOCIATION_RETAIN)
            return l
        }
    }
}
