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
    let margin: Rect<Float32>
    let padding: Rect<Float32>
    let border: Rect<Float32>
    
    let innerFlexBases: Float32
    var flexBasis: Float32 {
        return innerFlexBases
    }
    
    let violation: Float32
    let frozen: Bool
    
    let hypotheticalInnerSize: Size<Float32>
    let hypotheticalOuterSize: Size<Float32>
    let targetSize: Size<Float32>
    let outerTargetSize: Size<Float32>
    
    let baseline: Float32
    
    // temporary values for holding offset in the main / cross direction.
    // offset is the relative position from the item's natural flow position based on
    // relative position values, alignment, and justification. Does not include margin/padding/border.
    let offsetMain: Float32
    let offsetCross: Float32
}
