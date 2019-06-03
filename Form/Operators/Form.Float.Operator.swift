//
//  Form.Float.Operator.swift
//  Form
//
//  Created by Haider Khan on 6/2/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

extension Float32 {
    
    static func ||(lhs: Float32, rhs: Float32) -> Float32 {
        return OrElse.orElse.orElse(lhs, rhs)
    }
    
    static func ||(lhs: Float32, rhs: Number) -> Number {
        return OrElse.orElse.orElse(lhs, rhs)
    }
    
}
