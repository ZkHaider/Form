//
//  Form.AlignContent.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum AlignContent {
    case flexStart
    case flexEnd
    case center
    case stretch
    case spaceBetween
    case spaceAround
}

extension AlignContent: WithDefaultValue {
    public static var defaultValue: AlignContent {
        return .stretch
    }
}

extension AlignContent: Equatable {
    public static func ==(lhs: AlignContent,
                          rhs: AlignContent) -> Bool {
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
        case .stretch:
            switch rhs {
            case .stretch: return true
            default: return false
            }
        }
    }
}

