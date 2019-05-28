//
//  Form.MeasureFunc.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public typealias MeasureFunc = Function<Size<Float32?>, Size<Float32>>

public struct Measuring<T, In, Out> {
    public let measure: (T) -> Function<Size<In>, Size<Out>>
}
