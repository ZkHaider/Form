//
//  Form.PositionType.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum PositionType {
    case relative
    case absolute
}

extension PositionType: WithDefaultValue {
    public static var defaultValue: PositionType {
        return .relative
    }
}

extension PositionType: Equatable {
    public static func ==(lhs: PositionType,
                          rhs: PositionType) -> Bool {
        switch lhs {
        case .relative:
            switch rhs {
            case .relative: return true
            default: return false
            }
        case .absolute:
            switch rhs {
            case .absolute: return true
            default: return false
            }
        }
    }
}
