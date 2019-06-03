//
//  Form.MeasureFunc.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public typealias MeasureFunc = Function<Size<Number>, Size<Float32>>

public struct Measuring<T, In, Out> {
    public let measure: (T) -> Function<Size<In>, Size<Out>>
}

extension Measuring where T == InternalNode, In == Number, Out == Float32 {
    static var node: Measuring<T, In, Out> {
        return Measuring { target in
            return Function { changeTo -> Size<Out> in
                return Size<Out>(width: 0.0, height: 0.0)
            }
        }
    }
}
