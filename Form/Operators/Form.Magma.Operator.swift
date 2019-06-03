//
//  Form.Magma.Operator.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

precedencegroup MultiplicativePrecedence {
    associativity: left
}

infix operator <>: MultiplicationPrecedence

public func <><M: Magma>(lhs: M, rhs: M) -> M {
    return lhs.ops(other: rhs)
}

extension Sequence where Element: Monoid {
    public func joined() -> Element {
        return concat(Array(self))
    }
}
