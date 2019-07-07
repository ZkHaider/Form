//
//  Form.Dimension.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation
import simd

public enum Dimension {
    case undefined
    case auto
    case points(Float32)
    case percent(Float32)
}

extension Dimension: WithDefaultValue {
    public static var defaultValue: Dimension {
        return .undefined
    }
}

extension Dimension {
    
    public func resolve(withValue value: Number) -> Number {
        switch self {
        case .points(let points): return .defined(points)
        case .percent(let percent): return Operation.multiply.operate(value, percent)
        default: return .undefined
        }
    }
    
    public var isDefined: Bool {
        switch self {
        case .points, .percent: return true
        default: return false
        }
    }
    
}

extension Dimension: Equatable {
    public static func ==(lhs: Dimension,
                          rhs: Dimension) -> Bool {
        switch lhs {
        case .undefined:
            switch rhs {
            case .undefined: return true
            default: return false
            }
        case .auto:
            switch rhs {
            case .auto: return true
            default: return false
            }
        case .points(let lhsValue):
            switch rhs {
            case .points(let rhsValue): return lhsValue == rhsValue
            default: return false
            }
        case .percent(let lhsValue):
            switch rhs {
            case .percent(let rhsValue): return lhsValue == rhsValue
            default: return false
            }
        }
    }
}

extension Dimension: Codable {
    
    private enum RawValues: String, Codable {
        case auto
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            if let rawValue = RawValues(rawValue: stringValue) {
                switch rawValue {
                case .auto: self = .auto
                }
            } else {
                
                // Try to parse out percentage
            }
        } else if let numberValue = try? container.decode(Number.self) {
            self = .points(numberValue.resolve)
        } else {
            self = .undefined
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
    }
    
}
