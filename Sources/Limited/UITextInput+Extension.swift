//
//  UITextInput+Extension.swift
//  LimitedInput
//
//  Created by galaxy on 2022/2/7.
//

import Foundation
import UIKit

extension UITextInput {
//    internal var markedTextNSRange: NSRange? {
//        guard let markedTextRange = markedTextRange else { return nil }
//        let markedTextRangeLocation = offset(from: beginningOfDocument, to: markedTextRange.start)
//        let markedTextRangeLength = offset(from: markedTextRange.start, to: markedTextRange.end)
//        return NSRange(location: markedTextRangeLocation, length: markedTextRangeLength)
//    }
    
    internal var hasMarkedText: Bool {
        if let m = markedTextRange,
           let _ = position(from: m.start, offset: 0) {
            return true
        }
        return false
    }
}
