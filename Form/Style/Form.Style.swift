//
//  Form.Style.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Style<T> {
    public let display: Display
    public let positionType: PositionType
    public let direction: Direction
    public let flexDirection: FlexDirection
    public let flexWrap: FlexWrap
    public let overflow: Overflow
    public let alignItems: AlignItems
    public let alignSelf: AlignSelf
    public let alignContent: AlignContent
    public let justifyContent: JustifyContent
    public let position: Rect<T>
    public let margin: Rect<T>
    public let padding: Rect<T>
    public let border: Rect<T>
    public let flexGrow: Float32
    public let flexShrink: Float32
    public let flexBasis: T
    public let size: Size<T>
    public let minSize: Size<T>
    public let maxSize: Size<T>
    public let aspectRatio: Number
}

extension Style: WithDefaultValue where T == Dimension {
    public static var defaultValue: Style<Dimension> {
        return Style<Dimension>(
            display: .defaultValue,
            positionType: .defaultValue,
            direction: .defaultValue,
            flexDirection: .defaultValue,
            flexWrap: .defaultValue,
            overflow: .defaultValue,
            alignItems: .defaultValue,
            alignSelf: .defaultValue,
            alignContent: .defaultValue,
            justifyContent: .defaultValue,
            position: .defaultValue,
            margin: .defaultValue,
            padding: .defaultValue,
            border: .defaultValue,
            flexGrow: 0.0,
            flexShrink: 1.0,
            flexBasis: .auto,
            size: .defaultValue,
            minSize: .defaultValue,
            maxSize: .defaultValue,
            aspectRatio: .defaultValue
        )
    }
}

extension Style where T == Dimension {
    
    public func minMainSize(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.minSize.width
        case .column, .columnReverse: return self.minSize.height
        }
    }
    
    public func maxMainSize(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.maxSize.width
        case .column, .columnReverse: return self.maxSize.height
        }
    }
    
    public func mainMarginStart(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.margin.start
        case .column, .columnReverse: return self.margin.top
        }
    }
    
    public func mainMarginEnd(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.margin.end
        case .column, .columnReverse: return self.margin.bottom
        }
    }
    
    public func crossSize(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.size.height
        case .column, .columnReverse: return self.size.width
        }
    }
    
    public func minCrossSize(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.minSize.height
        case .column, .columnReverse: return self.minSize.width
        }
    }
    
    public func maxCrossSize(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.maxSize.height
        case .column, .columnReverse: return self.maxSize.width
        }
    }
    
    public func crossMarginStart(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.margin.top
        case .column, .columnReverse: return self.margin.start
        }
    }
    
    public func crossMarginEnd(for direction: FlexDirection) -> T {
        switch direction {
        case .row, .rowReverse: return self.margin.bottom
        case .column, .columnReverse: return self.margin.end
        }
    }
    
    public func alignSelf(with parent: Style) -> AlignSelf {
        guard
            self.alignSelf == .auto
            else {
                return self.alignSelf
        }
        switch parent.alignItems {
        case .flexStart: return .flexStart
        case .flexEnd: return .flexEnd
        case .center: return .center
        case .baseline: return .baseline
        case .stretch: return .stretch
        }
    }
    
}

extension Style: Equatable where T: Equatable {
    public static func ==(lhs: Style<T>,
                          rhs: Style<T>) -> Bool {
        if lhs.display != rhs.display {
            return false
        }
        if lhs.positionType != rhs.positionType {
            return false
        }
        if lhs.direction != rhs.direction {
            return false
        }
        if lhs.flexDirection != rhs.flexDirection {
            return false
        }
        if lhs.flexWrap != rhs.flexWrap {
            return false
        }
        if lhs.overflow != rhs.overflow {
            return false
        }
        if lhs.alignItems != rhs.alignItems {
            return false
        }
        if lhs.alignSelf != rhs.alignSelf {
            return false
        }
        if lhs.alignContent != rhs.alignContent {
            return false
        }
        if lhs.justifyContent != rhs.justifyContent {
            return false
        }
        if lhs.position != rhs.position {
            return false
        }
        if lhs.margin != rhs.margin {
            return false
        }
        if lhs.padding != rhs.padding {
            return false
        }
        if lhs.border != rhs.border {
            return false
        }
        if lhs.flexGrow != rhs.flexGrow {
            return false
        }
        if lhs.flexShrink != rhs.flexShrink {
            return false
        }
        if lhs.flexBasis != rhs.flexBasis {
            return false
        }
        if lhs.size != rhs.size {
            return false
        }
        if lhs.minSize != rhs.minSize {
            return false
        }
        if lhs.maxSize != rhs.maxSize {
            return false
        }
        if lhs.aspectRatio != rhs.aspectRatio {
            return false
        }
        return true
    }
}
