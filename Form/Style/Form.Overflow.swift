//
//  Form.Overflow.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum Overflow {
    case visible
    case hidden
    case scroll
}

extension Overflow: WithDefaultValue {
    public static var defaultValue: Overflow {
        return .visible
    }
}

extension Overflow: Equatable {
    public static func ==(lhs: Overflow,
                          rhs: Overflow) -> Bool {
        switch lhs {
        case .visible:
            switch rhs {
            case .visible: return true
            default: return false
            }
        case .hidden:
            switch rhs {
            case .hidden: return true
            default: return false
            }
        case .scroll:
            switch rhs {
            case .scroll: return true
            default: return false
            }
        }
    }
}
