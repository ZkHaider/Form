//
//  Form.ToNumbered.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Numbered<A> {
    public let convert: (A) -> Number
}

extension Numbered where A == Float32 {
    public static var `default`: Numbered<A> {
        return Numbered<A> { float in
            return .defined(float)
        }
    }
}

public struct Floating<A> {
    public let convert: (A) -> Float32
}

extension Floating where A == Number {
    public static var `default`: Floating<A> {
        return Floating<A> { number in
            switch number {
            case .defined(let value): return value
            case .undefined: return .nan
            }
        }
    }
}
