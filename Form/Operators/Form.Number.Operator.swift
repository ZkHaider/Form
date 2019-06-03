//
//  Form.Number.Operator.swift
//  Form
//
//  Created by Haider Khan on 6/1/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

extension Number {
    
    static func +(lhs: Number, rhs: Number) -> Number {
        return Operation.add.operate(lhs, rhs)
    }
    
    static func +(lhs: Number, rhs: Float32) -> Number {
        return Operation.add.operate(lhs, rhs)
    }
    
    static func -(lhs: Number, rhs: Float32) -> Number {
        return Operation.subtract.operate(lhs, rhs)
    }
    
    static func -(lhs: Number, rhs: Number) -> Number {
        return Operation.subtract.operate(lhs, rhs)
    }
    
    static func ||(lhs: Number, rhs: Number) -> Number {
        return OrElse.orElse.orElse(lhs, rhs)
    }
    
    static func ||(lhs: Number, rhs: Float32) -> Float32 {
        return OrElse.orElse.orElse(lhs, rhs)
    }
}
