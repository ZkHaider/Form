//
//  Form.AlignItems.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum AlignItems {
    case flexStart
    case flexEnd
    case center
    case baseline
    case stretch
}

extension AlignItems: WithDefaultValue {
    public static var defaultValue: AlignItems {
        return .stretch
    }
}

extension AlignItems: Equatable {
    public static func ==(lhs: AlignItems,
                          rhs: AlignItems) -> Bool {
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
        case .baseline:
            switch rhs {
            case .baseline: return true
            default: return false
            }
        case .stretch:
            switch rhs {
            case .stretch: return true
            default: return false
            }
        }
    }
}
