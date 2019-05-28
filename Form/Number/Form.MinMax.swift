//
//  Form.MinMax.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct MinMax<A, In, Out> {
    let maybeMin: (A, In) -> Out
    let maybeMax: (A, In) -> Out
}

extension MinMax {
    
    public func map<B>(_ f: @escaping (B) -> A) -> MinMax<B, In, Out> {
        return MinMax<B, In, Out>(
            maybeMin: { (value, input) -> Out in
                self.maybeMin(f(value), input)
            },
            maybeMax: { (value, input) -> Out in
                self.maybeMax(f(value), input)
            }
        )
    }
    
}

extension MinMax where A == Number, In == Number, Out == Number {
    public static var minMax: MinMax<A, In, Out> {
        return MinMax<A, In, Out>(
            maybeMin: { (number, other) -> Number in
                switch number {
                case .defined(let lhsValue):
                    switch other {
                    case .defined(let rhsValue): return .defined(min(lhsValue, rhsValue))
                    case .undefined: return number
                    }
                case .undefined: return .undefined
                }
            },
            maybeMax: { (number, other) -> Number in
                switch number {
                case .defined(let lhsValue):
                    switch other {
                    case .defined(let rhsValue): return .defined(max(lhsValue, rhsValue))
                    case .undefined: return number
                    }
                case .undefined: return .undefined
                }
            }
        )
    }
}

extension MinMax: Monoid, Semigroup, Magma where A == Number, In == Number, Out == Number {
    
    public static var identity: MinMax<Number, Number, Number> {
        return MinMax(
            maybeMin: { value, _ in value },
            maybeMax: { value, _ in value}
        )
    }
    
    public func ops(other: MinMax<Number, Number, Number>) -> MinMax<Number, Number, Number> {
        return MinMax<Number, Number, Number>(
            maybeMin: { value, input -> Number in
                return other.maybeMin(self.maybeMin(value, input), input)
            },
            maybeMax: { value, input -> Number in
                return other.maybeMax(self.maybeMax(value, input), input)
            }
        )
    }
}

extension MinMax where A == Number, In == Float32, Out == Number {
    public static var minMax: MinMax<A, In, Out> {
        return MinMax<A, In, Out>(
            maybeMin: { (number, float) -> Number in
                switch number {
                case .defined(let other): return .defined(min(other, float))
                case .undefined: return .undefined
                }
            },
            maybeMax: { (number, float) -> Number in
                switch number {
                case .defined(let other): return .defined(max(other, float))
                case .undefined: return .undefined
                }
            }
        )
    }
}

extension MinMax where A== Float32, In == Number, Out == Float32 {
    public static var minMax: MinMax<A, In, Out> {
        return MinMax<A, In, Out>(
            maybeMin: { (float, number) -> Float32 in
                switch number {
                case .defined(let other): return min(float, other)
                case .undefined: return float
                }
            },
            maybeMax: { (float, number) -> Float32 in
                switch number {
                case .defined(let other): return max(float, other)
                case .undefined: return float 
                }
            }
        )
    }
}
