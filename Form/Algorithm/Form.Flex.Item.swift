//
//  Form.Flex.Item.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

struct FlexItem {
    
    var node: InternalNode
    
    let size: Size<Number>
    let minSize: Size<Number>
    let maxSize: Size<Number>
    
    let position: Rect<Number>
    var margin: Rect<Float32>
    var padding: Rect<Float32>
    var border: Rect<Float32>
    
    var innerFlexBasis: Float32
    var flexBasis: Float32 {
        get { return innerFlexBasis }
        set(newValue) {
            self.innerFlexBasis = newValue
        }
    }
    
    var violation: Float32
    var frozen: Bool
    
    var hypotheticalInnerSize: Size<Float32>
    var hypotheticalOuterSize: Size<Float32>
    var targetSize: Size<Float32>
    var outerTargetSize: Size<Float32>
    
    var baseline: Float32
    
    // temporary values for holding offset in the main / cross direction.
    // offset is the relative position from the item's natural flow position based on
    // relative position values, alignment, and justification. Does not include margin/padding/border.
    var offsetMain: Float32
    var offsetCross: Float32
}

extension FlexItem: Equatable {
    
    public static func ==(lhs: FlexItem,
                          rhs: FlexItem) -> Bool {
        if lhs.node != rhs.node {
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
        if lhs.innerFlexBasis != rhs.innerFlexBasis {
            return false
        }
        if lhs.violation != rhs.violation {
            return false 
        }
        if lhs.hypotheticalInnerSize != rhs.hypotheticalInnerSize {
            return false
        }
        if lhs.hypotheticalOuterSize != rhs.hypotheticalOuterSize {
            return false 
        }
        if lhs.targetSize != rhs.targetSize {
            return false
        }
        if lhs.outerTargetSize != rhs.outerTargetSize {
            return false
        }
        if lhs.baseline != rhs.baseline {
            return false
        }
        if lhs.offsetMain != rhs.offsetMain {
            return false
        }
        if lhs.offsetCross != rhs.offsetCross {
            return false
        }
        return true 
    }
    
}
