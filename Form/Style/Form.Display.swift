//
//  Form.Display.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public enum Display {
    case flex
    case none
}

extension Display: WithDefaultValue {
    public static var defaultValue: Display {
        return .flex
    }
}

extension Display: Equatable {
    public static func ==(lhs: Display,
                          rhs: Display) -> Bool {
        switch lhs {
        case .flex:
            switch rhs {
            case .flex: return true
            default: return false
            }
        case .none:
            switch rhs {
            case .none: return true
            default: return false
            }
        }
    }
}
