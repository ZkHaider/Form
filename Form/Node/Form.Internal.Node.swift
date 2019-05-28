//
//  Form.Internal.Node.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public class InternalNode {
    
    var style: Style<Dimension>
    var parents: [Weak<InternalNode>]
    var children: [Weak<InternalNode>]
    var measureFunction: MeasureFunc? = nil
    var layoutCache: Cache? = nil
    var isDirty: Bool
    
    init(style: Style<Dimension>,
                parents: [Weak<InternalNode>],
                children: [Weak<InternalNode>],
                measureFunction: MeasureFunc? = nil,
                layoutCache: Cache? = nil,
                isDirty: Bool) {
        self.style = style
        self.parents = parents
        self.children = children
        self.measureFunction = measureFunction
        self.layoutCache = layoutCache
        self.isDirty = isDirty
    }
    
}

extension InternalNode: Equatable {
    
    public static func ==(lhs: InternalNode,
                          rhs: InternalNode) -> Bool {
        if lhs.isDirty != rhs.isDirty {
            return false
        }
        if lhs.style != rhs.style {
            return false
        }
//        if lhs.measureFunction != rhs.measureFunction {
//            return false
//        }
        if lhs.layoutCache != rhs.layoutCache {
            return false
        }
        if lhs.children != rhs.children {
            return false
        }
        if lhs.parents != rhs.parents {
            return false
        }
        return true 
    }
    
}
