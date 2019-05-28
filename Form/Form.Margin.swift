//
//  Form.Margin.swift
//  Form
//
//  Created by Haider Khan on 5/23/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation
import simd

public struct Margin<T> {
    public let top: T
    public let right: T
    public let bottom: T
    public let left: T
}

extension float4 {
    public var margin: Margin<Float> {
        return Margin(top: self.x,
                      right: self.y,
                      bottom: self.z,
                      left: self.w)
    }
}

extension Margin where T == Float {
    public var float4Value: float4 {
        return float4(self.top, self.right, self.bottom, self.left)
    }
}

extension Margin where T == Float {
    public static var zero: Margin<T> {
        return Margin(top: 0, right: 0, bottom: 0, left: 0)
    }
}
