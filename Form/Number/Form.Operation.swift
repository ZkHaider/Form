//
//  Form.Add.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Operation<L, R, O> {
    public typealias Left = L
    public typealias Right = R
    public typealias Output = O
    public let ops: (Left, Right) -> Output
}

extension Operation where Left == Float32, Right == Float32, Output == Float32 {
    public static var add: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            ops: { (lhs, rhs) -> Float32 in
                return lhs + rhs
            }
        )
    }
}

extension Operation where Left == Number, Right == Float32, Output == Number {
    public static var add: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            ops: { (number, float) -> Number in
                switch number {
                case .defined(let value): return .defined(value + float)
                case .undefined: return .undefined
                }
            }
        )
    }
    
    public static var subtract: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            ops: { (number, float) -> Number in
                switch number {
                case .defined(let value): return .defined(value - float)
                case .undefined: return .undefined
                }
        }
        )
    }
    
    public static var multiply: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            ops: { (number, float) -> Number in
                switch number {
                case .defined(let value): return .defined(value * float)
                case .undefined: return .undefined
                }
        }
        )
    }
    
    public static var divide: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            ops: { (number, float) -> Number in
                switch number {
                case .defined(let value): return .defined(value / float)
                case .undefined: return .undefined
                }
        }
        )
    }
}

extension Operation where Left == Number, Right == Number, Output == Number {
    public static var add: Operation<Left, Right, Output> {
        return Operation<L, R, O>(ops: { (lhs, rhs) -> Number in
            switch lhs {
            case .defined(let lhsValue):
                switch rhs {
                case .defined(let rhsValue): return .defined(lhsValue + rhsValue)
                case .undefined: return lhs
                }
            case .undefined: return .undefined
            }
        })
    }
    
    public static var subtract: Operation<Left, Right, Output> {
        return Operation<L, R, O>(ops: { (lhs, rhs) -> Number in
            switch lhs {
            case .defined(let lhsValue):
                switch rhs {
                case .defined(let rhsValue): return .defined(lhsValue - rhsValue)
                case .undefined: return lhs
                }
            case .undefined: return .undefined
            }
        })
    }
    
    public static var multiply: Operation<Left, Right, Output> {
        return Operation<L, R, O>(ops: { (lhs, rhs) -> Number in
            switch lhs {
            case .defined(let lhsValue):
                switch rhs {
                case .defined(let rhsValue): return .defined(lhsValue * rhsValue)
                case .undefined: return lhs
                }
            case .undefined: return .undefined
            }
        })
    }
    
    public static var divide: Operation<Left, Right, Output> {
        return Operation<L, R, O>(ops: { (lhs, rhs) -> Number in
            switch lhs {
            case .defined(let lhsValue):
                switch rhs {
                case .defined(let rhsValue): return .defined(lhsValue / rhsValue)
                case .undefined: return lhs
                }
            case .undefined: return .undefined
            }
        })
    }
}
