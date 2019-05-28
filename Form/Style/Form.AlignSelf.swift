//
//  Form.AlignSelf.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum AlignSelf {
    case auto
    case flexStart
    case flexEnd
    case center
    case baseline
    case stretch
}

extension AlignSelf: WithDefaultValue {
    public static var defaultValue: AlignSelf {
        return .auto
    }
}

extension AlignSelf: Equatable {
    public static func ==(lhs: AlignSelf,
                          rhs: AlignSelf) -> Bool {
        switch lhs {
        case .auto:
            switch rhs {
            case .auto: return true
            default: return false 
            }
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

