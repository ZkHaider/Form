//
//  Form.Dimension+Size.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

extension Size: WithDefaultValue where T == Dimension{
    public static var defaultValue: Size<Dimension> {
        return Size<Dimension>(
            width: .auto,
            height: .auto
        )
    }
}
