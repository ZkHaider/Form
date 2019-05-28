//
//  Form.Dimension+Rect.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

extension Rect: WithDefaultValue where T == Dimension {
    public static var defaultValue: Rect<Dimension> {
        return Rect(
            start: Dimension.defaultValue,
            end: Dimension.defaultValue,
            top: Dimension.defaultValue,
            bottom: Dimension.defaultValue
        )
    }
}
