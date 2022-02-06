//
//  Limited.swift
//  LimitedInput
//
//  Created by galaxy on 2022/2/6.
//

import Foundation
import UIKit

public struct LimitedWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol LimitedCompatible {}

extension LimitedCompatible {
    public var limited: LimitedWrapper<Self> {
        get { return LimitedWrapper(self) }
        set { }
    }
}

extension UITextField: LimitedCompatible { }
