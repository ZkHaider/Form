//
//  Form.MeasureFunc.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public typealias MeasureFunc = Function<Size<Dimension>, Result<Size<Float32>>>

public struct Measuring<T, In, Out> {
    public let measure: Function<Size<In>, Result<Size<Out>>>
}
