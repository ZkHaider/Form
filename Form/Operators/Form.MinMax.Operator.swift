//
//  Form.MinMax.Operator.swift
//  Form
//
//  Created by Haider Khan on 6/1/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

precedencegroup MinimumPrecedence {
    associativity: left
}

infix operator △: MinimumPrecedence
infix operator ▽: MinimumPrecedence

extension Float32 {
    static func △(lhs: Float32, rhs: Number) -> Float32 {
        return MinMax.minMax.maybeMin(lhs, rhs)
    }
    static func ▽(lhs: Float32, rhs: Number) -> Float32 {
        return MinMax.minMax.maybeMax(lhs, rhs)
    }
}

extension Number {
    static func △(lhs: Number, rhs: Float32) -> Number {
        return MinMax.minMax.maybeMin(lhs, rhs)
    }
    static func ▽(lhs: Number, rhs: Float32) -> Number {
        return MinMax.minMax.maybeMax(lhs, rhs)
    }
    static func △(lhs: Number, rhs: Number) -> Number {
        return MinMax.minMax.maybeMin(lhs, rhs)
    }
    static func ▽(lhs: Number, rhs: Number) -> Number {
        return MinMax.minMax.maybeMax(lhs, rhs)
    }
}
