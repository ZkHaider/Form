//
//  Form.Rect.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Rect<T> {
    public var start: T
    public var end: T
    public var top: T
    public var bottom: T
}

extension Rect where T == Number {
    
    public func horizontal() -> T {
        return Operation.add.operate(self.start, self.end)
    }
    
    public func vertical() -> T {
        return Operation.add.operate(self.top, self.bottom)
    }
    
    public func main(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.start + self.end
        case .column, .columnReverse: return self.top + self.bottom
        }
    }
    
    public func mainStart(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.start
        case .column, .columnReverse: return self.top
        }
    }
    
    public func mainEnd(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.end
        case .column, .columnReverse: return self.bottom
        }
    }
    
    public func cross(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.top + self.bottom
        case .column, .columnReverse: return self.start + self.end
        }
    }
    
    public func crossStart(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.top
        case .column, .columnReverse: return self.start
        }
    }
    
    public func crossEnd(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.bottom
        case .column, .columnReverse: return self.end
        }
    }
    
}


extension Rect where T == Float32 {
    
    public func horizontal() -> T {
        return Operation.add.operate(self.start, self.end)
    }
    
    public func vertical() -> T {
        return Operation.add.operate(self.top, self.bottom)
    }
    
    public func main(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.start + self.end
        case .column, .columnReverse: return self.top + self.bottom
        }
    }
    
    public func mainStart(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.start
        case .column, .columnReverse: return self.top
        }
    }
    
    public func mainEnd(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.end
        case .column, .columnReverse: return self.bottom
        }
    }
    
    public func cross(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.top + self.bottom
        case .column, .columnReverse: return self.start + self.end
        }
    }
    
    public func crossStart(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.top
        case .column, .columnReverse: return self.start
        }
    }
    
    public func crossEnd(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.bottom
        case .column, .columnReverse: return self.end
        }
    }
    
}

extension Rect {
    public func map<A>(_ f: @escaping (T) -> A) -> Rect<A> {
        return Rect<A>(
            start: f(self.start),
            end: f(self.end),
            top: f(self.top),
            bottom: f(self.bottom)
        )
    }
}

extension Rect: Monoid, Semigroup, Magma where T: Monoid {
    
    public static var identity: Rect<T> {
        return Rect<T>(start: T.identity,
                       end: T.identity,
                       top: T.identity,
                       bottom: T.identity)
    }
    
    public func ops(other: Rect<T>) -> Rect<T> {
        return Rect<T>(start: [self.start, other.start].joined(),
                       end: [self.end, other.end].joined(),
                       top: [self.top, other.top].joined(),
                       bottom: [self.bottom, other.bottom].joined())
    }
    
}

extension Rect: Equatable where T: Equatable {
    public static func ==(lhs: Rect,
                          rhs: Rect) -> Bool {
        if lhs.start != rhs.start {
            return false
        }
        if lhs.end != rhs.end {
            return false
        }
        if lhs.top != rhs.top {
            return false
        }
        if lhs.bottom != rhs.bottom {
            return false
        }
        return true
    }
}
