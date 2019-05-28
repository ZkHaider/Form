//
//  Form.FlexWrap.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum FlexWrap {
    case noWrap
    case wrap
    case wrapReverse
}

extension FlexWrap: WithDefaultValue {
    public static var defaultValue: FlexWrap {
        return .noWrap
    }
}

extension FlexWrap: Equatable {
    public static func ==(lhs: FlexWrap,
                          rhs: FlexWrap) -> Bool {
        switch lhs {
        case .noWrap:
            switch rhs {
            case .noWrap: return true
            default: return false
            }
        case .wrap:
            switch rhs {
            case .wrap: return true
            default: return false
            }
        case .wrapReverse:
            switch rhs {
            case .wrapReverse: return true
            default: return false
            }
        }
    }
}
