//
//  Form.Compute.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public func compute(on root: InternalNode,
                    size: Size<Number>) -> Result<Layout> {
    
    let hasRootMinMax = root.style.minSize.width.isDefined
        || root.style.minSize.height.isDefined
        || root.style.maxSize.width.isDefined
        || root.style.maxSize.height.isDefined
    
    let result: Result<ComputeResult>
    if hasRootMinMax {
        let firstPass = computeInternal(
            on: root,
            nodeSize: Size<Number>(
                width: root.style.size.width.resolve(withParentWidth: size.width),
                height: root.style.size.height.resolve(withParentWidth: size.height)
            ),
            parentSize: size,
            performLayout: false
        )
        
        switch firstPass {
        case .success(let computeResult):
            
            let resolvedMinWidth = root.style.minSize.width.resolve(withParentWidth: size.width)
            let resolvedMinHeight = root.style.minSize.height.resolve(withParentWidth: size.height)
            let resolvedMaxWidth = root.style.maxSize.width.resolve(withParentWidth: size.width)
            let resolvedMaxHeight = root.style.maxSize.height.resolve(withParentWidth: size.height)
            
            let maybeMaxWidth = MinMax.minMax.maybeMax(
                computeResult.size.width,
                resolvedMinWidth
            )
            let maybeMinWidth = MinMax.minMax.maybeMin(
                maybeMaxWidth,
                resolvedMaxWidth
            )
            
            let width = Numbered.default.convert(maybeMinWidth)
            
            let maybeMaxHeight = MinMax.minMax.maybeMax(
                computeResult.size.height,
                resolvedMinHeight
            )
            let maybeMinHeight = MinMax.minMax.maybeMin(
                maybeMaxHeight,
                resolvedMaxHeight
            )
            
            let height = Numbered.default.convert(maybeMinHeight)
            
            result = computeInternal(
                on: root,
                nodeSize: Size<Number>(
                    width: width,
                    height: height
                ),
                parentSize: size,
                performLayout: true
            )
        case .failure(let error):
            result = .failure(error)
        }
        
    } else {
        result = computeInternal(
            on: root,
            nodeSize: Size<Number>(
                width: root.style.size.width.resolve(withParentWidth: size.width),
                height: root.style.size.height.resolve(withParentWidth: size.height)
            ),
            parentSize: size,
            performLayout: true
        )
    }
    
    switch result {
    case .success(let computeResult):
        
        let layout = Layout(
            order: 0,
            size: Size(
                width: computeResult.size.width,
                height: computeResult.size.height
            ),
            location: Point(x: 0.0, y: 0.0),
            children: computeResult.children
        )
        
        return .success(layout)
        
    case .failure(let error):
        return .failure(error)
    }
}

internal func computeInternal(on node: InternalNode,
                              nodeSize: Size<Number>,
                              parentSize: Size<Number>,
                              performLayout: Bool) -> Result<ComputeResult> {
    node.isDirty = false
    
    return .failure(NSError(domain: "", code: 0, userInfo: [:]))
}
