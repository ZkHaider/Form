//
//  Form.OrElse.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct OrElse<A, Other> {
    public let orElse: (A, Other) -> Other
}

extension OrElse where A == Number, Other == Float32 {
    public static var orElse: OrElse<A, Other> {
        return OrElse<A, Other>(orElse: { (number, other) -> Float32 in
            switch number {
            case .defined(let float): return float
            case .undefined: return other
            }
        })
    }
}

extension OrElse where A == Number, Other == Number {
    public static var orElse: OrElse<A, Other> {
        return OrElse<A, Other>(orElse: { (number, other) -> Number in
            switch number {
            case .defined: return number
            case .undefined: return other
            }
        })
    }
}

extension OrElse where A == Float32, Other == Number {
    public static var orElse: OrElse<A, Other> {
        return OrElse<A, Other>(orElse: { (value, number) -> Number in
            switch value {
            case .nan:
                switch number {
                case .defined(let float): return .defined(float)
                case .undefined: return .undefined
                }
            default: return .defined(value)
            }
        })
    }
}

extension OrElse where A == Float32, Other == Float32 {
    public static var orElse: OrElse<A, Other> {
        return OrElse<A, Other>(orElse: { lhs, rhs -> Float32 in
            switch lhs {
            case .nan: return rhs
            default: return lhs 
            }
        })
    }
}
