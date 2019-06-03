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
    public let operate: (Left, Right) -> Output
}

extension Operation where Left == Float32, Right == Float32, Output == Float32 {
    public static var add: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            operate: { (lhs, rhs) -> Float32 in
                return lhs + rhs
            }
        )
    }
}

extension Operation where Left == Number, Right == Float32, Output == Number {
    public static var add: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            operate: { (number, float) -> Number in
                switch number {
                case .defined(let value): return .defined(value + float)
                case .undefined: return .undefined
                }
            }
        )
    }
    
    public static var subtract: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            operate: { (number, float) -> Number in
                switch number {
                case .defined(let value): return .defined(value - float)
                case .undefined: return .undefined
                }
        }
        )
    }
    
    public static var multiply: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            operate: { (number, float) -> Number in
                switch number {
                case .defined(let value): return .defined(value * float)
                case .undefined: return .undefined
                }
        }
        )
    }
    
    public static var divide: Operation<Left, Right, Output> {
        return Operation<L, R, O>(
            operate: { (number, float) -> Number in
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
        return Operation<L, R, O>(operate: { (lhs, rhs) -> Number in
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
        return Operation<L, R, O>(operate: { (lhs, rhs) -> Number in
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
        return Operation<L, R, O>(operate: { (lhs, rhs) -> Number in
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
        return Operation<L, R, O>(operate: { (lhs, rhs) -> Number in
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

extension Operation where Left == Number, Right == Number, Output == Float32 {
    public static var add: Operation<Left, Right, Output> {
        return Operation<L, R, O>(operate: { (lhs, rhs) -> Float32 in
            switch lhs {
            case .defined(let lhsValue):
                switch rhs {
                case .defined(let rhsValue): return lhsValue + rhsValue
                case .undefined:
                    switch lhs {
                    case .defined(let lhsValue): return lhsValue
                    case .undefined: return .nan
                    }
                }
            case .undefined: return .nan
            }
        })
    }
    
    public static var subtract: Operation<Left, Right, Output> {
        return Operation<L, R, O>(operate: { (lhs, rhs) -> Float32 in
            switch lhs {
            case .defined(let lhsValue):
                switch rhs {
                case .defined(let rhsValue): return lhsValue - rhsValue
                case .undefined:
                    switch lhs {
                    case .defined(let lhsValue): return lhsValue
                    case .undefined: return .nan
                    }
                }
            case .undefined: return .nan
            }
        })
    }
    
    public static var multiply: Operation<Left, Right, Output> {
        return Operation<L, R, O>(operate: { (lhs, rhs) -> Float32 in
            switch lhs {
            case .defined(let lhsValue):
                switch rhs {
                case .defined(let rhsValue): return lhsValue * rhsValue
                case .undefined:
                    switch lhs {
                    case .defined(let lhsValue): return lhsValue
                    case .undefined: return .nan
                    }
                }
            case .undefined: return .nan
            }
        })
    }
    
    public static var divide: Operation<Left, Right, Output> {
        return Operation<L, R, O>(operate: { (lhs, rhs) -> Float32 in
            switch lhs {
            case .defined(let lhsValue):
                switch rhs {
                case .defined(let rhsValue): return lhsValue / rhsValue
                case .undefined:
                    switch lhs {
                    case .defined(let lhsValue): return lhsValue
                    case .undefined: return .nan
                    }
                }
            case .undefined: return .nan
            }
        })
    }
}

extension Operation where Left == InternalNode, Right == Size<Number>, Output == Number {
    static var resolvedMinWidth: Operation {
        return Operation { $0.style.minSize.width.resolve(withValue: $1.width) }
    }
    static var resolvedMinHeight: Operation {
        return Operation { $0.style.minSize.height.resolve(withValue: $1.height) }
    }
    static var resolvedMaxWidth: Operation {
        return Operation { $0.style.maxSize.width.resolve(withValue: $1.width) }
    }
    static var resolvedMaxHeight: Operation {
        return Operation { $0.style.maxSize.height.resolve(withValue: $1.height) }
    }
}

extension Operation where Left == Float32, Right == Number, Output == Float32 {
    static var maxPass: Operation {
        return Operation { MinMax.minMax.maybeMax($0, $1) }
    }
    static var minPass: Operation {
        return Operation { MinMax.minMax.maybeMin($0, $1) }
    }
}

extension Operation: Monoid, Semigroup, Magma
                where Left: Monoid,
                      Right: Monoid,
                      Output: Monoid {
    
    public static var identity: Operation<L, R, O> {
        return Operation { _,_ in O.identity }
    }
    
    public func ops(other: Operation<L, R, O>) -> Operation<L, R, O> {
        return Operation<L, R, O> { left, right -> Output in
            return [self.operate(left, right), other.operate(left, right)].joined()
        }
    }
    
}
