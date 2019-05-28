//
//  Form.Geometry.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Point<T> {
    public let x: T
    public let y: T
}

extension Point {
    public func map<A>(_ f: @escaping (T) -> A) -> Point<A> {
        return Point<A>(
            x: f(self.x),
            y: f(self.y)
        )
    }
}

extension Point: Equatable where T: Equatable {
    public static func ==(lhs: Point,
                          rhs: Point) -> Bool {
        if lhs.x != rhs.x {
            return false
        }
        if lhs.y != rhs.y {
            return false
        }
        return true 
    }
}