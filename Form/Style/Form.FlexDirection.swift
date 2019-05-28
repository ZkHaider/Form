//
//  Form.FlexDirection.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum FlexDirection {
    case row
    case column
    case rowReverse
    case columnReverse
}

extension FlexDirection: WithDefaultValue {
    public static var defaultValue: FlexDirection {
        return .row
    }
    
    public var isRow: Bool {
        switch self {
        case .row, .rowReverse: return true
        default: return false
        }
    }
    
    public var isColumn: Bool {
        switch self {
        case .column, .columnReverse: return true
        default: return false
        }
    }
    
    public var isReversed: Bool {
        switch self {
        case .rowReverse, .columnReverse: return true
        default: return false
        }
    }
    
}

extension FlexDirection: Equatable {
    public static func ==(lhs: FlexDirection,
                          rhs: FlexDirection) -> Bool {
        switch lhs {
        case .row:
            switch rhs {
            case .row: return true
            default: return false
            }
        case .rowReverse:
            switch rhs {
            case .rowReverse: return true
            default: return false
            }
        case .column:
            switch rhs {
            case .column: return true
            default: return false
            }
        case .columnReverse:
            switch rhs {
            case .columnReverse: return true
            default: return false
            }
        }
    }
}
