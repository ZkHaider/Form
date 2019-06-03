//
//  Form.API.swift
//  Form
//
//  Created by Haider Khan on 5/28/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public protocol NodeLayout {
    static func node(style: Style<Dimension>,
                     measureFunction: MeasureFunc) -> Self
    static func node(style: Style<Dimension>,
                     children: Self...) -> Self
    static func node(style: Style<Dimension>,
                     children: [Self]) -> Self
}
