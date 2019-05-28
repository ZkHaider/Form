//
//  Form.Direction.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum Direction {
    case inherited
    case leftToRight
    case rightToLeft
}

extension Direction: WithDefaultValue {
    public static var defaultValue: Direction {
        return .inherited
    }
}

extension Direction: Equatable {
    public static func ==(lhs: Direction,
                          rhs: Direction) -> Bool {
        switch lhs {
        case .inherited:
            switch rhs {
            case .inherited: return true
            default: return false
            }
        case .leftToRight:
            switch rhs {
            case .leftToRight: return true
            default: return false
            }
        case .rightToLeft:
            switch rhs {
            case .rightToLeft: return true
            default: return false
            }
        }
    }
}
