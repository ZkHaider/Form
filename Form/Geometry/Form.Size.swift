//
//  Form.Size.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation
import simd

public struct Size<T> {
    public let width: T
    public let height: T
    public init(width: T,
                height: T) {
        self.width = width
        self.height = height
    }
}

extension Size {
    public func map<A>(_ f: @escaping (T) -> A) -> Size<A> {
        return Size<A>(
            width: f(self.width),
            height: f(self.height)
        )
    }
}

extension Size: Monoid, Semigroup, Magma where T: Monoid {
    
    public static var identity: Size<T> {
        return Size<T>(width: T.identity, height: T.identity)
    }
    
    public func ops(other: Size<T>) -> Size<T> {
        return Size<T>(
            width: [self.width, other.width].joined(),
            height: [self.height, other.height].joined()
        )
    }
    
}

extension Size where T == Void {
    public func undefined() -> Size<Number> {
        return Size<Number>(width: .undefined, height: .undefined)
    }
}

extension float2 {
    public var size: Size<Float> {
        return Size(width: self.x, height: self.y)
    }
}

extension Size where T == Float {
    public var float2Value: float2 {
        return float2(self.width, self.height)
    }
}

extension Size where T == Float {
    public static var zero: Size<Float> {
        return Size(width: 0, height: 0)
    }
}

extension Size: Equatable where T: Equatable {
    public static func ==(lhs: Size,
                          rhs: Size) -> Bool {
        if lhs.width != rhs.width {
            return false
        }
        if lhs.height != rhs.height {
            return false
        }
        return true
    }
}
