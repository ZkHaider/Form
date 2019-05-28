//
//  Form.Function.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Function<A, B> {
    let f: (A) -> B
}

extension Function {
    
    public func map<C>(_ f: @escaping (A) -> C) -> Function<A, C> {
        return Function<A, C> { f($0) }
    }

}

extension Function: Monoid, Semigroup, Magma where A: Monoid, B: Monoid {
    
    public static var identity: Function<A, B> {
        return Function<A, B>(f: { _ in B.identity })
    }
    
    public func ops(other: Function<A, B>) -> Function<A, B> {
        return Function(f: { (value) -> B in
            return [self.f(value), other.f(value)].joined()
        })
    }
    
}

extension Function
            where A == (InternalNode, Size<Number>),
                  B == Number {
    
    static var minWidthPass: Function<A, B> {
        return Function { (data: (InternalNode, Size<Number>)) in
            return Operation.resolvedMinWidth.operate(data.0, data.1)
        }
    }
    
}

extension Function
            where A == (InternalNode, Size<Number>, Size<Float32>),
                  B == Number {
    
    static var computeWidthPass: Function<A, B> {
        return Function { (data: (InternalNode, Size<Number>, Size<Float32>)) in
            let resolvedMinWidth = Operation.resolvedMinWidth.operate(data.0, data.1)
            let resolvedMaxWidth = Operation.resolvedMaxWidth.operate(data.0, data.1)
            let maybeMaxWidth = Operation.maxPass.operate(data.2.width, resolvedMinWidth)
            let maybeMinWidth = Operation.minPass.operate(maybeMaxWidth, resolvedMaxWidth)
            return Numbered.default.convert(maybeMinWidth)
        }
    }
    
    static var computeHeightPass: Function<A, B> {
        return Function { (data: (InternalNode, Size<Number>, Size<Float32>)) in
            let resolvedMinHeight = Operation.resolvedMinHeight.operate(data.0, data.1)
            let resolvedMaxHeight = Operation.resolvedMaxHeight.operate(data.0, data.1)
            let maybeMaxHeight = Operation.maxPass.operate(data.2.width, resolvedMinHeight)
            let maybeMinHeight = Operation.minPass.operate(maybeMaxHeight, resolvedMaxHeight)
            return Numbered.default.convert(maybeMinHeight)
        }
    }
    
}
