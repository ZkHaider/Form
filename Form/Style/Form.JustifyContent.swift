//
//  Form.JustifyContent.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum JustifyContent {
    case flexStart
    case flexEnd
    case center
    case spaceBetween
    case spaceAround
    case spaceEvenly
}

extension JustifyContent: WithDefaultValue {
    public static var defaultValue: JustifyContent {
        return .flexStart
    }
}

extension JustifyContent: Equatable {
    public static func ==(lhs: JustifyContent,
                          rhs: JustifyContent) -> Bool {
        switch lhs {
        case .flexStart:
            switch rhs {
            case .flexStart: return true
            default: return false
            }
        case .flexEnd:
            switch rhs {
            case .flexEnd: return true
            default: return false
            }
        case .center:
            switch rhs {
            case .center: return true
            default: return false
            }
        case .spaceBetween:
            switch rhs {
            case .spaceBetween: return true
            default: return false
            }
        case .spaceAround:
            switch rhs {
            case .spaceAround: return true
            default: return false
            }
        case .spaceEvenly:
            switch rhs {
            case .spaceEvenly: return true
            default: return false
            }
        }
    }
}
