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
            
            // Composed functions:
            // ResolvedWidth -> MaxPass -> MinPass
            // ResolvedHeight -> MaxPass -> MinPass
            let width = Function.computeWidthPass.f((root, size, computeResult.size))
            let height = Function.computeHeightPass.f((root, size, computeResult.size))
            
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

private func roundLayout(on layout: Layout,
                         absX: Float32,
                         absY: Float32) -> Layout {
    let _absX = absX + layout.location.x
    let _absY = absY + layout.location.y
    
    return Layout(
        order: layout.order,
        size: Size(
            width: (_absX + layout.size.width).rounded() - _absX.rounded(),
            height: (_absY + layout.size.height).rounded() - _absY.rounded()
        ),
        location: Point(
            x: layout.location.x.rounded(),
            y: layout.location.y.rounded()
        ),
        children: layout.children.compactMap({ roundLayout(on: $0,
                                                           absX: _absX,
                                                           absY: _absY) })
    )
}

internal func computeInternal(on node: InternalNode,
                              nodeSize: Size<Number>,
                              parentSize: Size<Number>,
                              performLayout: Bool) -> Result<ComputeResult> {
    node.isDirty = false
    
    // First we check if we have a result for the given input
    if let cache = node.layoutCache,
        cache.performLayout || !performLayout {
        
    }
    
    return .failure(NSError(domain: "", code: 0, userInfo: [:]))
}
