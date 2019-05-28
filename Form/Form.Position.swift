//
//  Form.Position.swift
//  Form
//
//  Created by Haider Khan on 5/23/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation
import simd

public struct Position<T> {
    public let x: T
    public let y: T
    public let width: T
    public let height: T
}

extension float4 {
    public var position: Position<Float> {
        return Position<Float>(x: self.x,
                               y: self.y,
                               width: self.z,
                               height: self.w)
    }
}

extension Position where T == Float {
    public var float4Value: float4 {
        return float4(self.x, self.y, self.width, self.height)
    }
}

extension Position where T == Float {
    public static var zero: Position<T> {
        return Position(x: 0, y: 0, width: 0, height: 0)
    }
}
