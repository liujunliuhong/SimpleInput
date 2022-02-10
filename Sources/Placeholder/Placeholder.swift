//
//  Placeholder.swift
//  SimpleInput
//
//  Created by jun on 2022/02/10.
//

import Foundation
import UIKit

private struct AssociatedKeys {
    static var placeholder = "com.galaxy.placeholder.key"
}

extension UITextInput {
    public var placeholders: PlaceholderInput {
        if let p = objc_getAssociatedObject(self, &AssociatedKeys.placeholder) as? PlaceholderInput {
            return p
        } else {
            let p = PlaceholderInput(currentInput: self)
            objc_setAssociatedObject(self, &AssociatedKeys.placeholder, p, .OBJC_ASSOCIATION_RETAIN)
            return p
        }
    }
}
