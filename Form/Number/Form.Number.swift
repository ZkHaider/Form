//
//  Form.Number.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum Number {
    case defined(Float32)
    case undefined
}

extension Number {
    public var isDefined: Bool {
        switch self {
        case .defined: return true
        case .undefined: return false
        }
    }
    
    public var isUndefined: Bool {
        switch self {
        case .defined: return false
        case .undefined: return true
        }
    }
}

extension Number: WithDefaultValue {
    public static var defaultValue: Number {
        return .undefined
    }
}

extension Number: Equatable {
    public static func ==(lhs: Number,
                          rhs: Number) -> Bool {
        switch lhs {
        case .defined(let lhsValue):
            switch rhs {
            case .defined(let rhsValue): return lhsValue == rhsValue
            default: return false
            }
        case .undefined:
            switch rhs {
            case .undefined: return true
            default: return false 
            }
        }
    }
}

extension Number: Monoid {
    
    public static var identity: Number { return .undefined }
    
    public func ops(other: Number) -> Number {
        switch self {
        case .defined(let value):
            switch other {
            case .defined(let otherValue): return .defined(value + otherValue)
            case .undefined: return .defined(value)
            }
        case .undefined:
            switch other {
            case .defined(let otherValue): return .defined(otherValue)
            case .undefined: return .undefined
            }
        }
    }
    
}

