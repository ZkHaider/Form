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
    public var width: T
    public var height: T
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

extension Size {
    public mutating func setMain(for direction: FlexDirection,
                                 with value: T) {
        switch direction {
        case .row, .rowReverse: self.width = value
        case .column, .columnReverse: self.height = value
        }
    }
    
    public mutating func setCross(for direction: FlexDirection,
                                  with value: T) {
        switch direction {
        case .row, .rowReverse: self.height = value
        case .column, .columnReverse: self.width = value
        }
    }
    
    public func main(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.width
        case .column, .columnReverse: return self.height
        }
    }
    
    public func cross(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.height
        case .column, .columnReverse: return self.width
        }
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

extension Size where T == Number {
    public static var zero: Size<T> {
        return Size<T>(width: .undefined, height: .undefined)
    }
}

extension Size where T == Dimension {
    public static var zero: Size<T> {
        return Size<T>(width: .undefined, height: .undefined)
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

extension Size: Codable where T: Codable {
    
    private enum RootKeys: String, CodingKey {
        case width
        case height
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        self.width = try container.decode(T.self, forKey: .width)
        self.height = try container.decode(T.self, forKey: .height)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKeys.self)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
    }
    
}
