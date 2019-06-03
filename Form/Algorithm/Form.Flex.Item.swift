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
