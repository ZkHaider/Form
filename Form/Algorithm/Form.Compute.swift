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
                width: root.style.size.width.resolve(withValue: size.width),
                height: root.style.size.height.resolve(withValue: size.height)
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
                width: root.style.size.width.resolve(withValue: size.width),
                height: root.style.size.height.resolve(withValue: size.height)
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
        
        let widthCompatible: Bool
        switch nodeSize.width {
        case .defined(let width): widthCompatible = abs((width - cache.result.size.width)) < Float32.ulpOfOne
        case .undefined: widthCompatible = false
        }
        
        let heightCompatible: Bool
        switch nodeSize.height {
        case .defined(let height): heightCompatible = abs(height - cache.result.size.height) < Float32.ulpOfOne
        case .undefined: heightCompatible = false
        }
        
        if widthCompatible && heightCompatible { return .success(cache.result) }
        if cache.nodeSize == nodeSize && cache.parentSize == parentSize { return .success(cache.result) }
    }
    
    // Define some general constraints we will need for the remainder of the algorithm
    let direction = node.style.flexDirection
    let isRow = direction.isRow
    let isColumn = direction.isColumn
    let isWrapReversed = node.style.flexWrap == .wrapReverse
    
    let margin = node.style.margin.map({  $0.resolve(withValue: parentSize.width) || 0.0  })
    let padding = node.style.padding.map({ $0.resolve(withValue: parentSize.width) || 0.0 })
    let border = node.style.border.map({ $0.resolve(withValue: parentSize.width) || 0.0 })
    
    let paddingBorder = Rect(start: padding.start + border.start,
                             end: padding.end + border.end,
                             top: padding.top + border.top,
                             bottom: padding.bottom + border.bottom)
    
    let innerNodeSize = Size(width: nodeSize.width - paddingBorder.horizontal(),
                             height: nodeSize.height - paddingBorder.vertical())
    
    var containerSize = Size<Float32>(width: 0.0, height: 0.0)
    var innerContainerSize = Size<Float32>(width: 0.0, height: 0.0)
    
    if node.children.isEmpty {
        if nodeSize.width.isDefined && nodeSize.height.isDefined {
            return .success(
                ComputeResult(size: nodeSize.map({ OrElse.orElse.orElse($0, 0.0) }),
                              children: [])
            )
        }
        
        if let measureFunction = node.measureFunction {
            let result = ComputeResult(size: measureFunction.f(nodeSize),
                                       children: [])
            node.layoutCache = Cache(nodeSize: nodeSize,
                                     parentSize: parentSize,
                                     performLayout: performLayout,
                                     result: result)
            return .success(result)
        }
        
        return .success(
            ComputeResult(
                size: Size(
                    width: (nodeSize.width || 0.0) + paddingBorder.horizontal(),
                    height: (nodeSize.height || 0.0) + paddingBorder.vertical()
                ),
                children: []
            )
        )
    }
    
    // 9.2. Line Length Determination
    
    // 1. Generate anonymous flex items as described in §4 Flex Items.
    
    // 2. Determine the available main and cross space for the flex items.
    //    For each dimension, if that dimension of the flex container’s content box
    //    is a definite size, use that; if that dimension of the flex container is
    //    being sized under a min or max-content constraint, the available space in
    //    that dimension is that constraint; otherwise, subtract the flex container’s
    //    margin, border, and padding from the space available to the flex container
    //    in that dimension and use that value. This might result in an infinite value.
    
    let availableSize = Size(
        width:  (nodeSize.width || parentSize.width) - margin.horizontal() - paddingBorder.horizontal(),
        height: (nodeSize.height || parentSize.height) - margin.vertical() - paddingBorder.vertical()
    )
    
    var flexItems: [FlexItem] = node.children
        .nodeIterator
        .filter({ $0.style.positionType != .absolute })
        .filter({ $0.style.display != .none })
        .compactMap({ child -> FlexItem? in
            
            let resolvedWidth = child.style.size.width.resolve(withValue: innerNodeSize.width)
            let resolvedHeight = child.style.size.height.resolve(withValue: innerNodeSize.height)
            let size = Size(width: resolvedWidth, height: resolvedHeight)
            
            let resolvedMinWidth = child.style.minSize.width.resolve(withValue: innerNodeSize.width)
            let resolvedMinHeight = child.style.minSize.height.resolve(withValue: innerNodeSize.height)
            let minSize = Size(width: resolvedMinWidth, height: resolvedMinHeight)
            
            let resolvedMaxWidth = child.style.maxSize.width.resolve(withValue: innerNodeSize.width)
            let resolvedMaxHeight = child.style.maxSize.height.resolve(withValue: innerNodeSize.height)
            let maxSize = Size(width: resolvedMaxWidth, height: resolvedMaxHeight)
            
            let flexItem = FlexItem(node: child,
                     size: size,
                     minSize: minSize,
                     maxSize: maxSize,
                     position: child.style.position.map({ $0.resolve(withValue: innerNodeSize.width) }),
                     margin: child.style.margin.map({ $0.resolve(withValue: innerNodeSize.width) || 0.0 }),
                     padding: child.style.padding.map({ $0.resolve(withValue: innerNodeSize.width) || 0.0 }),
                     border: child.style.border.map({ $0.resolve(withValue: innerNodeSize.width) || 0.0 }),
                     innerFlexBasis: 0.0,
                     violation: 0.0,
                     frozen: false,
                     hypotheticalInnerSize: Size(width: 0.0, height: 0.0),
                     hypotheticalOuterSize: Size(width: 0.0, height: 0.0),
                     targetSize: Size(width: 0.0, height: 0.0),
                     outerTargetSize: Size(width: 0.0, height: 0.0),
                     baseline: 0.0,
                     offsetMain: 0.0,
                     offsetCross: 0.0
            )
            return flexItem
        })
    
    let hasBaselineChild = flexItems.reduce(into: false, { $0 = $0 || $1.node.style.alignSelf(with: node.style) == .baseline })
    
    // TODO - this does not follow spec. See commented out code below
    // 3. Determine the flex base size and hypothetical main size of each item:
    flexItems.mutateEach { item in
        
        // A. If the item has a definite used flex basis, that’s the flex base size.
        let flexBasis = item.node.style.flexBasis.resolve(withValue: innerNodeSize.main(for: direction))
        if flexBasis.isDefined {
            item.flexBasis = flexBasis || 0.0
            return
        }
        
        // B. If the flex item has an intrinsic aspect ratio,
        //    a used flex basis of content, and a definite cross size,
        //    then the flex base size is calculated from its inner
        //    cross size and the flex item’s intrinsic aspect ratio.
        if case let .defined(ratio) = item.node.style.aspectRatio {
            if case let .defined(cross) = nodeSize.cross(for: direction) {
                if item.node.style.flexBasis == .auto {
                    item.flexBasis = cross * ratio
                    return
                }
            }
        }
        
        // C. If the used flex basis is content or depends on its available space,
        //    and the flex container is being sized under a min-content or max-content
        //    constraint (e.g. when performing automatic table layout [CSS21]),
        //    size the item under that constraint. The flex base size is the item’s
        //    resulting main size.
        
        // TODO - Probably need to cover this case in future
        
        // D. Otherwise, if the used flex basis is content or depends on its
        //    available space, the available main size is infinite, and the flex item’s
        //    inline axis is parallel to the main axis, lay the item out using the rules
        //    for a box in an orthogonal flow [CSS3-WRITING-MODES]. The flex base size
        //    is the item’s max-content main size.
        
        // TODO - Probably need to cover this case in future
        
        // E. Otherwise, size the item into the available space using its used flex basis
        //    in place of its main size, treating a value of content as max-content.
        //    If a cross size is needed to determine the main size (e.g. when the
        //    flex item’s main size is in its block axis) and the flex item’s cross size
        //    is auto and not definite, in this calculation use fit-content as the
        //    flex item’s cross size. The flex base size is the item’s resulting main size.

        let width: Number
        if !item.size.width.isDefined
            && item.node.style.alignSelf(with: node.style) == .stretch
            && isColumn {
            width = availableSize.width
        } else {
            width = item.size.width
        }
        
        let height: Number
        if !item.size.height.isDefined
            && item.node.style.alignSelf(with: node.style) == .stretch
            && isRow {
            height = availableSize.height
        } else {
            height = item.size.height
        }
        
        let result = computeInternal(on: item.node,
                                     nodeSize: Size(
                                        width: item.minSize.width ▽ width,
                                        height: item.minSize.height ▽ height
                                     ),
                                     parentSize: availableSize,
                                     performLayout: false)
        switch result {
        case .success(let computeResult):
            let value = computeResult.size.main(for: direction)
            let max = value ▽ item.minSize.main(for: direction)
            let min = max △ item.maxSize.main(for: direction)
            item.flexBasis = min
        case .failure(_): ()
        }
    }
    
    // The hypothetical main size is the item’s flex base size clamped according to its
    // used min and max main sizes (and flooring the content box size at zero).

    flexItems.mutateEach({ item in
        
        // TODO - not really spec abiding but needs to be done somewhere. probably somewhere else though.
        // The following logic was developed not from the spec but by trail and error looking into how
        // webkit handled various scenarios. Can probably be solved better by passing in
        // min-content max-content constraints from the top
        let result = computeInternal(on: item.node,
                                     nodeSize: Size(width: .undefined,
                                                    height: .undefined),
                                     parentSize: availableSize,
                                     performLayout: false)
        switch result {
        case .success(let computeResult):
            
            let maybeMax = computeResult.size.main(for: direction) ▽ item.minSize.main(for: direction)
            let maybeMin = maybeMax △ item.size.main(for: direction)
            let minMain = Numbered.default.convert(maybeMin)
            
            item.hypotheticalInnerSize.setMain(for: direction, with: (item.flexBasis ▽ minMain) △ item.maxSize.main(for: direction))
            item.hypotheticalOuterSize.setMain(for: direction, with: item.hypotheticalInnerSize.main(for: direction) + item.margin.main(for: direction))
            
        case .failure(_): ()
        }
    })
    
    // 9.3. Main Size Determination
    
    // 5. Collect flex items into flex lines:
    //    - If the flex container is single-line, collect all the flex items into
    //      a single flex line.
    //    - Otherwise, starting from the first uncollected item, collect consecutive
    //      items one by one until the first time that the next collected item would
    //      not fit into the flex container’s inner main size (or until a forced break
    //      is encountered, see §10 Fragmenting Flex Layout). If the very first
    //      uncollected item wouldn’t fit, collect just it into the line.
    //
    //      For this step, the size of a flex item is its outer hypothetical main size. (Note: This can be negative.)
    //      Repeat until all flex items have been collected into flex lines
    //
    //      Note that the "collect as many" line will collect zero-sized flex items onto
    //      the end of the previous line even if the last non-zero item exactly "filled up" the line.

    func collectFlexLines() -> [FlexLine] {
        var lines: [FlexLine] = []
        var lineLength: Float32 = 0.0
        
        if node.style.flexWrap == .noWrap {
            lines.append(FlexLine(items: flexItems, crossSize: 0.0, offsetCross: 0.0))
        } else {
            
            var line = FlexLine(items: [], crossSize: 0.0, offsetCross: 0.0)
            for child in flexItems {
                lineLength += child.hypotheticalOuterSize.main(for: direction)
                
                if case let .defined(main) = availableSize.main(for: direction) {
                    if lineLength > main && !line.items.isEmpty {
                        lineLength = child.hypotheticalOuterSize.main(for: direction)
                        lines.append(line)
                        line = FlexLine(items: [], crossSize: 0.0, offsetCross: 0.0)
                    }
                }
                
                line.items.append(child)
            }
            
            lines.append(line)
        }
        return lines
    }
    
    var flexLines: [FlexLine] = collectFlexLines()
    
    // 6. Resolve the flexible lengths of all the flex items to find their used main size.
    //    See §9.7 Resolving Flexible Lengths.
    //
    // 9.7. Resolving Flexible Lengths
    
    flexLines.mutateEach({ line in
        
        // 1. Determine the used flex factor. Sum the outer hypothetical main sizes of all
        //    items on the line. If the sum is less than the flex container’s inner main size,
        //    use the flex grow factor for the rest of this algorithm; otherwise, use the
        //    flex shrink factor.
        let usedFlexFactor: Float32 = line.items.reduce(into: 0.0, { $0 += ($1.hypotheticalOuterSize.main(for: direction)) })
        let growing = usedFlexFactor < (innerNodeSize.main(for: direction) || 0.0)
        let shrinking = !growing
        
        // 2. Size inflexible items. Freeze, setting its target main size to its hypothetical main size
        //    - Any item that has a flex factor of zero
        //    - If using the flex grow factor: any item that has a flex base size
        //      greater than its hypothetical main size
        //    - If using the flex shrink factor: any item that has a flex base size
        //      smaller than its hypothetical main size
        line.items.mutateEach({ child in
            
            // TODO - This is not found by reading the spec. Maybe this can be done in some other place
            // instead. This was found by trail and error fixing tests to align with webkit output.
            if innerNodeSize.main(for: direction).isUndefined && isRow {
                
                let result = computeInternal(on: child.node,
                                             nodeSize: Size(width: (child.size.width ▽ child.minSize.width) △ child.maxSize.width,
                                                            height: (child.size.height ▽ child.minSize.height) △ child.maxSize.height),
                                             parentSize: availableSize,
                                             performLayout: false)
                
                switch result {
                case .success(let computeResult):
                    child.targetSize.setMain(
                        for: direction,
                        with: (computeResult.size.main(for: direction) ▽ child.minSize.main(for: direction)) △ child.maxSize.main(for: direction)
                    )
                case .failure(_): ()
                }
                
            } else {
                child.targetSize.setMain(for: direction,
                                         with: child.hypotheticalInnerSize.main(for: direction))
            }
            
            // TODO this should really only be set inside the if-statement below but
            // that causes the target_main_size to never be set for some items

            child.outerTargetSize.setMain(for: direction,
                                          with: child.targetSize.main(for: direction) + child.margin.main(for: direction))
            
            if (child.node.style.flexGrow == 0.0 && child.node.style.flexShrink == 0.0)
                || (growing && child.flexBasis > child.hypotheticalInnerSize.main(for: direction))
                || (shrinking && child.flexBasis < child.hypotheticalInnerSize.main(for: direction)) {
                child.frozen = true 
            }
        })
        
        // 3. Calculate initial free space. Sum the outer sizes of all items on the line,
        //    and subtract this from the flex container’s inner main size. For frozen items,
        //    use their outer target main size; for other items, use their outer flex base size.
        
        let usedSpace: Float32 = line.items.reduce(0.0, { $0 + ($1.margin.main(for: direction) + ($1.frozen ? $1.targetSize.main(for: direction) : $1.flexBasis)) })
        let initialFreeSpace = (innerNodeSize.main(for: direction) - usedSpace) || 0.0
        
        // 4. Loop
        
        while true {
            
            var frozen: [FlexItem] = []
            var unfrozen: [FlexItem] = []
            
            line.items.mutateEach({ item in
                if item.frozen {
                    frozen.append(item)
                } else {
                    unfrozen.append(item)
                }
            })
            
            if unfrozen.isEmpty {
                break
            }
            
            // b. Calculate the remaining free space as for initial free space, above.
            //    If the sum of the unfrozen flex items’ flex factors is less than one,
            //    multiply the initial free space by this sum. If the magnitude of this
            //    value is less than the magnitude of the remaining free space, use this
            //    as the remaining free space.
            
            let usedSpace: Float32 = (frozen + unfrozen).reduce(into: 0.0, { (result, item) in
                let increment = (item.margin.main(for: direction)) + (item.frozen ? item.targetSize.main(for: direction) : item.flexBasis)
                result += increment
            })
            
            let sumFlexGrow: Float32 = unfrozen.reduce(0.0, { $0 + $1.node.style.flexGrow })
            let sumFlexShrink: Float32 = unfrozen.reduce(0.0, { $0 + $1.node.style.flexShrink })
            
            let freeSpace: Float32
            if growing && sumFlexGrow < 1.0 {
                freeSpace = ((initialFreeSpace * sumFlexGrow) △ (innerNodeSize.main(for: direction) - usedSpace))
            } else if shrinking && sumFlexShrink < 1.0 {
                freeSpace = ((initialFreeSpace * sumFlexShrink) ▽ (innerNodeSize.main(for: direction) - usedSpace))
            } else {
                freeSpace = (innerNodeSize.main(for: direction) - usedSpace) || 0.0
            }
            
            // c. Distribute free space proportional to the flex factors.
            //    - If the remaining free space is zero
            //        Do Nothing
            //    - If using the flex grow factor
            //        Find the ratio of the item’s flex grow factor to the sum of the
            //        flex grow factors of all unfrozen items on the line. Set the item’s
            //        target main size to its flex base size plus a fraction of the remaining
            //        free space proportional to the ratio.
            //    - If using the flex shrink factor
            //        For every unfrozen item on the line, multiply its flex shrink factor by
            //        its inner flex base size, and note this as its scaled flex shrink factor.
            //        Find the ratio of the item’s scaled flex shrink factor to the sum of the
            //        scaled flex shrink factors of all unfrozen items on the line. Set the item’s
            //        target main size to its flex base size minus a fraction of the absolute value
            //        of the remaining free space proportional to the ratio. Note this may result
            //        in a negative inner main size; it will be corrected in the next step.
            //    - Otherwise
            //        Do Nothing
            
            if freeSpace.isNormal {
                if growing && sumFlexGrow > 0.0 {
                    unfrozen.mutateEach({ item in
                        item.targetSize.setMain(for: direction, with: item.flexBasis + freeSpace * (item.node.style.flexGrow / sumFlexGrow))
                    })
                } else if shrinking && sumFlexShrink > 0.0 {
                    let sumScaledShrinkFactor: Float32 = unfrozen.reduce(0.0, { $0 + ($1.innerFlexBasis * $1.node.style.flexShrink) })
                    
                    if sumScaledShrinkFactor > 0.0 {
                        unfrozen.mutateEach({ item in
                            let scaledShrinkFactor = item.innerFlexBasis * item.node.style.flexShrink
                            item.targetSize.setMain(for: direction, with: item.flexBasis + freeSpace + (scaledShrinkFactor / sumScaledShrinkFactor))
                        })
                    }
                }
            }
            
            // d. Fix min/max violations. Clamp each non-frozen item’s target main size by its
            //    used min and max main sizes and floor its content-box size at zero. If the
            //    item’s target main size was made smaller by this, it’s a max violation.
            //    If the item’s target main size was made larger by this, it’s a min violation.

            let totalViolation: Float32 = unfrozen.mutateReduce(into: 0.0, { (result, item) in
                
                // TODO - not really spec abiding but needs to be done somewhere. probably somewhere else though.
                // The following logic was developed not from the spec but by trail and error looking into how
                // webkit handled various scenarios. Can probably be solved better by passing in
                // min-content max-content constraints from the top. Need to figure out correct thing to do here as
                // just piling on more conditionals.
                let minMain: Number = {
                    if isRow && item.node.measureFunction == nil {
                        let result = computeInternal(on: item.node,
                                                     nodeSize: Size(width: .undefined,
                                                                    height: .undefined),
                                                     parentSize: availableSize,
                                                     performLayout: false)
                        switch result {
                        case .success(let computeResult):
                            return Numbered.default.convert((computeResult.size.width △ item.size.width) ▽ item.minSize.width)
                        case .failure(_):
                            return item.minSize.main(for: direction)
                        }
                    } else {
                        return item.minSize.main(for: direction)
                    }
                }()
                
                let maxMain = item.maxSize.main(for: direction)
                let clamped = max(((item.targetSize.main(for: direction) △ maxMain) ▽ minMain), 0.0)
                item.violation = clamped - item.targetSize.main(for: direction)
                item.targetSize.setMain(for: direction, with: clamped)
                item.outerTargetSize.setMain(for: direction, with: item.targetSize.main(for: direction) + item.margin.main(for: direction))
                
                result += item.violation
            })
            
            // e. Freeze over-flexed items. The total violation is the sum of the adjustments
            //    from the previous step ∑(clamped size - unclamped size). If the total violation is:
            //    - Zero
            //        Freeze all items.
            //    - Positive
            //        Freeze all the items with min violations.
            //    - Negative
            //        Freeze all the items with max violations.
            
            unfrozen.mutateEach({ item in
                switch totalViolation {
                case let value where value > 0.0:
                    item.frozen = item.violation > 0.0
                    
                    // Update item in lines
                    guard
                        let index = line.items.firstIndex(where: { $0.node == item.node })
                        else {
                        // Not found then break
                        break
                    }
                    line.items[index] = item
                    
                case let value where value < 0.0:
                    
                    item.frozen = item.violation < 0.0
                    
                    // Update item in lines
                    guard
                        let index = line.items.firstIndex(where: { $0.node == item.node })
                        else {
                            // Not found then break
                            break
                    }
                    line.items[index] = item
                    
                default:
                    
                    item.frozen = true
                    
                    // Update item in lines
                    guard
                        let index = line.items.firstIndex(where: { $0.node == item.node })
                        else {
                            // Not found then break
                            break
                    }
                    line.items[index] = item 
                }
            })
            
            // Return to the start of the loop
        }
    })
    
    // Not part of the spec from what i can see but seems correct
    func longestLine() -> Float32 {
        let longestLine: Float32 = flexLines.reduce(into: Float32.leastNonzeroMagnitude, { result, line in
            let length: Float32 = line.items.reduce(into: 0.0, { $0 += $1.outerTargetSize.main(for: direction) })
            result = max(result, length)
        })
        return longestLine
    }
    
    func size() -> Float32 {
        let size = longestLine() + paddingBorder.main(for: direction)
        switch availableSize.main(for: direction) {
        case .defined(let value): if flexLines.count > 1 && size < value { return value } else { fallthrough }
        default: return size
        }
    }
    
    containerSize.setMain(for: direction,
                          with: nodeSize.main(for: direction) || size())
    innerContainerSize.setMain(for: direction,
                               with: containerSize.main(for: direction) - paddingBorder.main(for: direction))
    
    
    // 9.4. Cross Size Determination
    
    // 7. Determine the hypothetical cross size of each item by performing layout with the
    //    used main size and the available space, treating auto as fit-content.

    flexLines.mutateEach({ line in
        line.items.mutateEach({ child in
            let childCross = (child.size.cross(for: direction) ▽ child.minSize.cross(for: direction)) △ child.maxSize.cross(for: direction)
            
            let result = computeInternal(on: child.node,
                                         nodeSize: Size(
                                            width: isRow ? Numbered.default.convert(child.targetSize.width) : childCross,
                                            height: isRow ? childCross : Numbered.default.convert(child.targetSize.height)
                                         ),
                                         parentSize: Size(
                                            width: isRow ? Numbered.default.convert(containerSize.main(for: direction)) : availableSize.width,
                                            height: isRow ? availableSize.height : Numbered.default.convert(containerSize.main(for: direction))
                                         ),
                                         performLayout: false)
            switch result {
            case .success(let computeResult):
                
                let cross = computeResult.size.cross(for: direction)
                let maybeMax = cross ▽ child.minSize.cross(for: direction)
                let maybeMin = maybeMax △ child.maxSize.cross(for: direction)
                
                child.hypotheticalInnerSize.setCross(for: direction,
                                                     with: maybeMin)
                child.hypotheticalOuterSize.setCross(for: direction,
                                                     with: child.hypotheticalInnerSize.cross(for: direction) + child.margin.cross(for: direction))
                
            case .failure(_): ()
            }
        })
    })
    
    // TODO - probably should move this somewhere else as it doesn't make a ton of sense here but we need it below
    // TODO - This is expensive and should only be done if we really require a baseline. aka, make it lazy

    func calculateBaseline(for layout: Layout) -> Float32 {
        guard
            layout.children.isEmpty
            else {
                return calculateBaseline(for: layout.children[0])
        }
        return layout.size.height
    }
    
    if hasBaselineChild {
        flexLines.mutateEach({ line in
            line.items.mutateEach({ child in
                
                let result = computeInternal(
                    on: child.node,
                    nodeSize: Size(
                        width: Numbered.default.convert(isRow ? child.targetSize.width : child.hypotheticalInnerSize.width),
                        height: Numbered.default.convert(isRow ? child.hypotheticalInnerSize.height : child.targetSize.height)),
                    parentSize: Size(
                        width: isRow ? Numbered.default.convert(containerSize.width) : nodeSize.width,
                        height: isRow ? nodeSize.height : Numbered.default.convert(containerSize.height)),
                    performLayout: true
                )
                
                switch result {
                case .success(let computeResult):
                    
                    let layout = Layout(
                        order: UInt32(node.children.firstIndex(where: { $0 == child.node })!),
                        size: computeResult.size,
                        location: Point(x: 0.0, y: 0.0),
                        children: computeResult.children
                    )
                    
                    child.baseline = calculateBaseline(for: layout)
                    
                case .failure(_): ()
                }
            })
        })
    }
    
    // 8. Calculate the cross size of each flex line.
    //    If the flex container is single-line and has a definite cross size, the cross size
    //    of the flex line is the flex container’s inner cross size. Otherwise, for each flex line:
    //
    //    If the flex container is single-line, then clamp the line’s cross-size to be within
    //    the container’s computed min and max cross sizes. Note that if CSS 2.1’s definition
    //    of min/max-width/height applied more generally, this behavior would fall out automatically.

    if flexLines.count == 1 && nodeSize.cross(for: direction).isDefined {
        flexLines[0].crossSize = (nodeSize.cross(for: direction) - paddingBorder.cross(for: direction)) || 0.0
    } else {
        flexLines.mutateEach({ line in
            
            //    1. Collect all the flex items whose inline-axis is parallel to the main-axis, whose
            //       align-self is baseline, and whose cross-axis margins are both non-auto. Find the
            //       largest of the distances between each item’s baseline and its hypothetical outer
            //       cross-start edge, and the largest of the distances between each item’s baseline
            //       and its hypothetical outer cross-end edge, and sum these two values.
            
            //    2. Among all the items not collected by the previous step, find the largest
            //       outer hypothetical cross size.
            
            //    3. The used cross-size of the flex line is the largest of the numbers found in the
            //       previous two steps and zero.
            let maxBaseline: Float32 = line.items.reduce(into: 0.0, { $0 = max($0, $1.baseline) })
            
            let lineCrossSize: Float32 = line.items.reduce(into: 0.0, { (result, child) in
                if child.node.style.alignSelf(with: node.style) == .baseline
                    && child.node.style.crossMarginStart(for: direction) != .auto
                    && child.node.style.crossMarginEnd(for: direction) != .auto
                    && child.node.style.crossSize(for: direction) == .auto {
                    result = max(result, maxBaseline - child.baseline + child.hypotheticalOuterSize.cross(for: direction))
                } else {
                    result = max(result, child.hypotheticalOuterSize.cross(for: direction))
                }
            })
            
            line.crossSize = lineCrossSize
        })
    }
    
    // 9. Handle 'align-content: stretch'. If the flex container has a definite cross size,
    //    align-content is stretch, and the sum of the flex lines' cross sizes is less than
    //    the flex container’s inner cross size, increase the cross size of each flex line
    //    by equal amounts such that the sum of their cross sizes exactly equals the
    //    flex container’s inner cross size.
    
    if node.style.alignContent == .stretch
        && nodeSize.cross(for: direction).isDefined {
        
        let totalCross: Float32 = flexLines.reduce(into: 0.0, { $0 += $1.crossSize })
        let innerCross = (nodeSize.cross(for: direction) - paddingBorder.cross(for: direction)) || 0.0
        
        if totalCross < innerCross {
            let remaining = innerCross - totalCross
            let addition = remaining / Float32(flexLines.count)
            flexLines.mutateEach({ $0.crossSize += addition })
        }
    }
    
    // 10. Collapse visibility:collapse items. If any flex items have visibility: collapse,
    //     note the cross size of the line they’re in as the item’s strut size, and restart
    //     layout from the beginning.
    //
    //     In this second layout round, when collecting items into lines, treat the collapsed
    //     items as having zero main size. For the rest of the algorithm following that step,
    //     ignore the collapsed items entirely (as if they were display:none) except that after
    //     calculating the cross size of the lines, if any line’s cross size is less than the
    //     largest strut size among all the collapsed items in the line, set its cross size to
    //     that strut size.
    //
    //     Skip this step in the second layout round.
    
    // TODO implement once (if ever) we support visibility:collapse
    
    // 11. Determine the used cross size of each flex item. If a flex item has align-self: stretch,
    //     its computed cross size property is auto, and neither of its cross-axis margins are auto,
    //     the used outer cross size is the used cross size of its flex line, clamped according to
    //     the item’s used min and max cross sizes. Otherwise, the used cross size is the item’s
    //     hypothetical cross size.
    //
    //     If the flex item has align-self: stretch, redo layout for its contents, treating this
    //     used size as its definite cross size so that percentage-sized children can be resolved.
    //
    //     Note that this step does not affect the main size of the flex item, even if it has an
    //     intrinsic aspect ratio.
    
    flexLines.mutateEach({ line in
        
        let lineCrossSize = line.crossSize
        
        line.items.mutateEach({ child in
            
            let cross: (inout FlexItem) -> Float32 = { child -> Float32 in
                if child.node.style.alignSelf(with: node.style) == .stretch
                    && child.node.style.crossMarginStart(for: direction) != .auto
                    && child.node.style.crossMarginEnd(for: direction) != .auto
                    && child.node.style.crossSize(for: direction) == .auto {
                    return ((lineCrossSize - child.margin.cross(for: direction)) ▽ child.minSize.cross(for: direction)) △ child.maxSize.cross(for: direction)
                } else {
                    return child.hypotheticalInnerSize.cross(for: direction)
                }
            }
            
            child.targetSize.setCross(for: direction,
                                      with: cross(&child))
            
            child.outerTargetSize.setCross(for: direction,
                                           with: child.targetSize.cross(for: direction) + child.margin.cross(for: direction))
        })
    })
    
    // 9.5. Main-Axis Alignment
    
    // 12. Distribute any remaining free space. For each flex line:
    //     1. If the remaining free space is positive and at least one main-axis margin on this
    //        line is auto, distribute the free space equally among these margins. Otherwise,
    //        set all auto margins to zero.
    //     2. Align the items along the main-axis per justify-content.

    flexLines.mutateEach({ line in
        
        let usedSpace: Float32 = line.items.reduce(into: 0.0, { $0 += $1.outerTargetSize.main(for: direction) })
        let freeSpace = innerContainerSize.main(for: direction) - usedSpace
        var numAutoMargins = 0
        
        line.items.forEach({ child in
            if child.node.style.mainMarginStart(for: direction) == .auto {
                numAutoMargins += 1
            }
            if child.node.style.mainMarginEnd(for: direction) == .auto {
                numAutoMargins += 1
            }
        })
        
        if freeSpace > 0.0 && numAutoMargins > 0 {
            
            let margin = freeSpace / Float32(numAutoMargins)
            line.items.mutateEach({ child in
                
                if child.node.style.mainMarginStart(for: direction) == .auto {
                    if isRow {
                        child.margin.start = margin 
                    } else {
                        child.margin.top = margin 
                    }
                }
                
                if child.node.style.mainMarginEnd(for: direction) == .auto {
                    if isRow {
                        child.margin.end = margin
                    } else {
                        child.margin.bottom = margin
                    }
                }
            })
            
        } else {
            
            let numItems = line.items.count
            let layoutReverse = direction.isReversed
            
            let justifyItem: (Int, inout FlexItem) -> () = { (index, child) in
                
                let isFirst = index == 0
                
                switch node.style.justifyContent {
                case .flexStart:
                    child.offsetMain = (layoutReverse && isFirst) ? freeSpace : 0.0
                case .center:
                    child.offsetMain = isFirst ? freeSpace / 2.0 : 0.0
                case .flexEnd:
                    child.offsetMain = (isFirst && !layoutReverse) ? freeSpace : 0.0
                case .spaceBetween:
                    child.offsetMain = isFirst ? 0.0 : freeSpace / (Float32(numItems - 1))
                case .spaceAround:
                    child.offsetMain = isFirst ? (freeSpace / Float32(numItems)) / 2.0 : freeSpace / Float32(numItems)
                case .spaceEvenly:
                    child.offsetMain = freeSpace / Float32(numItems + 1)
                }
            }
            
            if layoutReverse {
                for (index, _) in line.items.enumerated().reversed() {
                    justifyItem(index, &line.items[index])
                }
            } else {
                for (index, _) in line.items.enumerated() {
                    justifyItem(index, &line.items[index])
                }
            }
        }
    })
    
    // 9.6. Cross-Axis Alignment
    
    // 13. Resolve cross-axis auto margins. If a flex item has auto cross-axis margins:
    //     - If its outer cross size (treating those auto margins as zero) is less than the
    //       cross size of its flex line, distribute the difference in those sizes equally
    //       to the auto margins.
    //     - Otherwise, if the block-start or inline-start margin (whichever is in the cross axis)
    //       is auto, set it to zero. Set the opposite margin so that the outer cross size of the
    //       item equals the cross size of its flex line.
    
    flexLines.mutateEach({ line in
        
        let lineCrossSize = line.crossSize
        let maxBaseline: Float32 = line.items.reduce(into: 0.0, { $0 = max($0, $1.baseline) })
        
        line.items.mutateEach({ child in
            
            let freeSpace = lineCrossSize - child.outerTargetSize.cross(for: direction)
            
            if child.node.style.crossMarginStart(for: direction) == .auto
                && child.node.style.crossMarginEnd(for: direction) == .auto {
                
                if isRow {
                    child.margin.top = freeSpace / 2.0
                    child.margin.bottom = freeSpace / 2.0
                } else {
                    child.margin.start = freeSpace / 2.0
                    child.margin.end = freeSpace / 2.0
                }
                
            } else if child.node.style.crossMarginStart(for: direction) == .auto {
                
                if isRow {
                    child.margin.top = freeSpace
                } else {
                    child.margin.start = freeSpace
                }
                
            } else if child.node.style.crossMarginEnd(for: direction) == .auto {
                
                if isRow {
                    child.margin.bottom = freeSpace
                } else {
                    child.margin.end = freeSpace
                }
                
            } else {
                
                // 14. Align all flex items along the cross-axis per align-self, if neither of the item’s
                //     cross-axis margins are auto.
                switch child.node.style.alignSelf(with: node.style) {
                case .auto:
                    child.offsetCross = 0.0 // => should never happen
                case .baseline:
                    if isRow {
                        child.offsetCross = maxBaseline - child.baseline
                    } else {
                        if isWrapReversed {
                            child.offsetCross = freeSpace
                        } else {
                            child.offsetCross = 0.0
                        }
                    }
                case .flexStart:
                    if isWrapReversed {
                        child.offsetCross = freeSpace
                    } else {
                        child.offsetCross = 0.0
                    }
                case .flexEnd:
                    if isWrapReversed {
                        child.offsetCross = 0.0
                    } else {
                        child.offsetCross = freeSpace
                    }
                case .center:
                    child.offsetCross = freeSpace / 2.0
                case .stretch:
                    if isWrapReversed {
                        child.offsetCross = freeSpace
                    } else {
                        child.offsetCross = 0.0
                    }
                }
            }
        })
    })
    
    // 15. Determine the flex container’s used cross size:
    //     - If the cross size property is a definite size, use that, clamped by the used
    //       min and max cross sizes of the flex container.
    //     - Otherwise, use the sum of the flex lines' cross sizes, clamped by the used
    //       min and max cross sizes of the flex container.
    
    let totalCrossSize: Float32 = flexLines.reduce(into: 0.0, { $0 += $1.crossSize })
    containerSize.setCross(for: direction,
                           with: nodeSize.cross(for: direction) || (totalCrossSize + paddingBorder.cross(for: direction)))
    innerContainerSize.setCross(for: direction,
                                with: containerSize.cross(for: direction) - paddingBorder.cross(for: direction))
    
    // We have the container size. If our caller does not care about performing
    // layout we are done now.
    if !performLayout {
        let result = ComputeResult(size: containerSize, children: [])
        node.layoutCache = Cache(nodeSize: nodeSize,
                                 parentSize: parentSize,
                                 performLayout: performLayout,
                                 result: result)
        return .success(result)
    }
    
    // 16. Align all flex lines per align-content.
    
    let freeSpace = innerContainerSize.cross(for: direction) - totalCrossSize
    let numLines = flexLines.count
    
    let alignLine: (Int, inout FlexLine) -> () = { (index, line) in
        
        let isFirst = index == 0
        
        switch node.style.alignContent {
        case .flexStart:
            line.offsetCross = (isFirst && isWrapReversed) ? freeSpace : 0.0
        case .center:
            line.offsetCross = isFirst ? freeSpace / 2.0 : 0.0
        case .flexEnd:
            line.offsetCross = (isFirst && !isWrapReversed) ? freeSpace : 0.0
        case .spaceBetween:
            line.offsetCross = isFirst ? 0.0 : freeSpace / (Float32(numLines - 1))
        case .spaceAround:
            line.offsetCross = isFirst ? (freeSpace / Float32(numLines)) / 2.0 : freeSpace / Float32(numLines)
        case .stretch:
            line.offsetCross = 0.0
        }
    }
    
    if isWrapReversed {
        for (index, _) in flexLines.enumerated().reversed() {
            alignLine(index, &flexLines[index])
        }
    } else {
        for (index, _) in flexLines.enumerated() {
            alignLine(index, &flexLines[index])
        }
    }
    
    
    
    
    
    // Do a final layout pass and gather the resulting layouts
    func gatherLayouts() -> [Layout] {
        
        var lines: [Layout] = []
        var totalOffsetCross = paddingBorder.crossStart(for: direction)
        
        func layoutLine(_ line: inout FlexLine) {
            
            var children = [Layout]()
            var totalOffsetMain = paddingBorder.mainStart(for: direction)
            
            let lineOffsetCross = line.offsetCross
            
            func layoutItem(_ child: inout FlexItem) {
                
                let result = computeInternal(on: child.node,
                                             nodeSize: child.targetSize.map(Numbered.default.convert),
                                             parentSize: containerSize.map(Numbered.default.convert),
                                             performLayout: true)
                
                switch result {
                case .success(let computeResult):
                    
                    let mainStart = child.position.mainStart(for: direction) || 0.0
                    let mainEnd = child.position.mainEnd(for: direction) || 0.0
                    
                    let offsetMain = totalOffsetMain
                        + child.offsetMain
                        + child.margin.mainStart(for: direction)
                        + mainStart
                    
                    let crossStart = child.position.crossStart(for: direction) || 0.0
                    let crossEnd = child.position.crossEnd(for: direction) || 0.0
                    
                    let offsetCross = totalOffsetCross
                        + child.offsetCross
                        + line.offsetCross
                        + child.margin.crossStart(for: direction)
                        + crossStart
                    
                    let layout = Layout(
                        order: UInt32(node.children.firstIndex(where: { $0 == child.node })!),
                        size: computeResult.size,
                        location: Point(
                            x: isRow ? offsetMain : offsetCross,
                            y: isColumn ? offsetMain : offsetCross
                        ),
                        children: computeResult.children
                    )
                    
                    children.append(layout)
                    
                case .failure(_): ()
                }
            }
            
            if direction.isReversed {
                for (index, _) in line.items.enumerated().reversed() {
                    layoutItem(&line.items[index])
                }
            } else {
                for (index, _) in line.items.enumerated() {
                    layoutItem(&line.items[index])
                }
            }
            
            totalOffsetCross += lineOffsetCross + line.crossSize
            
            if direction.isReversed {
                children.reverse()
            }
            
            lines.append(contentsOf: children)
        }
        
        if isWrapReversed {
            for (index, _) in flexLines.enumerated().reversed() {
                layoutLine(&flexLines[index])
            }
        } else {
            for (index, _) in flexLines.enumerated() {
                layoutLine(&flexLines[index])
            }
        }
        
        if isWrapReversed {
            return lines.reversed()
        } else {
            return lines
        }
    }
    
    var children = gatherLayouts()
    
    // Before returning we perform absolute layout on all absolutely positioned children
    // Use a Wrapped iterator to prevent less memory overhead
    let absoluteChildren = WrappedSequence(wrapping: node.children,
                                           iterator: { iterator in iterator.next() })
        .enumerated()
        .filter({ $0.1.style.positionType == .absolute })
        .compactMap({ entry -> Layout? in
            
            let order = entry.offset
            let child = entry.element
            
            let containerWidth = Numbered.default.convert(containerSize.width)
            let containerHeight = Numbered.default.convert(containerSize.height)
            
            let start = child.style.position.start.resolve(withValue: containerWidth)
                + child.style.margin.start.resolve(withValue: containerWidth)
            let end = child.style.position.end.resolve(withValue: containerWidth)
                + child.style.margin.end.resolve(withValue: containerWidth)
            let top = child.style.position.top.resolve(withValue: containerHeight)
                + child.style.margin.top.resolve(withValue: containerHeight)
            let bottom = child.style.position.bottom.resolve(withValue: containerHeight)
                + child.style.margin.bottom.resolve(withValue: containerHeight)
            
            let (startMain, endMain) = isRow ? (start, end) : (top, bottom)
            let (startCross, endCross) = isRow ? (top, bottom): (start, end)
            
            let maybeMaxWidth = child.style.size.width.resolve(withValue: containerWidth) ▽ child.style.minSize.width.resolve(withValue: containerWidth)
            let maybeMinWidth = maybeMaxWidth △ child.style.maxSize.width.resolve(withValue: containerWidth)
            
            func otherWidth() -> Number {
                if start.isDefined && end.isDefined {
                    return containerWidth - start - end
                } else {
                    return .undefined
                }
            }
            
            let width = maybeMinWidth || otherWidth()
            
            let maybeMaxHeight = child.style.size.height.resolve(withValue: containerHeight) ▽ child.style.minSize.height.resolve(withValue: containerHeight)
            let maybeMinHeight = maybeMaxHeight △ child.style.maxSize.height.resolve(withValue: containerHeight)
            
            func otherHeight() -> Number {
                if top.isDefined && bottom.isDefined {
                    return containerHeight - top - bottom
                } else {
                    return .undefined
                }
            }
            
            let height = maybeMinHeight || otherHeight()
            
            let result = computeInternal(on: child,
                                         nodeSize: Size(width: width, height: height),
                                         parentSize: Size(width: containerWidth, height: containerHeight),
                                         performLayout: true)
            
            switch result {
            case .success(let computeResult):
                
                let mainSpaceDiff = (computeResult.size.main(for: direction) ▽ child.style.minMainSize(for: direction).resolve(withValue: innerNodeSize.main(for: direction)))
                    △ child.style.maxMainSize(for: direction).resolve(withValue: innerNodeSize.main(for: direction))
                
                let freeMainSpace = containerSize.main(for: direction) - mainSpaceDiff
                
                let crossSpaceDiff = (computeResult.size.cross(for: direction) ▽ child.style.minCrossSize(for: direction).resolve(withValue: innerNodeSize.cross(for: direction)))
                    △ child.style.maxCrossSize(for: direction).resolve(withValue: innerNodeSize.cross(for: direction))
                
                let freeCrossSpace = containerSize.cross(for: direction) - crossSpaceDiff
                
                let offsetMain: Float32
                if startMain.isDefined {
                    offsetMain = startMain || 0.0 + border.mainStart(for: direction)
                } else if endMain.isDefined {
                    offsetMain = freeMainSpace - (endMain || 0.0) - border.mainEnd(for: direction)
                } else {
                    switch node.style.justifyContent {
                    case .spaceBetween, .flexStart:
                        offsetMain = paddingBorder.mainStart(for: direction)
                    case .flexEnd:
                        offsetMain = freeMainSpace - paddingBorder.mainEnd(for: direction)
                    case .spaceEvenly, .spaceAround, .center:
                        offsetMain = freeMainSpace / 2.0
                    }
                }
                
                let offsetCross: Float32
                if startCross.isDefined {
                    offsetCross = startCross || 0.0 + border.crossStart(for: direction)
                } else if endCross.isDefined {
                    offsetCross = freeCrossSpace - (endCross || 0.0) - border.crossEnd(for: direction)
                } else {
                    switch node.style.alignSelf(with: node.style) {
                    case .auto:
                        offsetCross = 0.0 // => should never happen
                    case .flexStart:
                        offsetCross = isWrapReversed ? (freeCrossSpace - paddingBorder.crossEnd(for: direction)) : paddingBorder.crossStart(for: direction)
                    case .flexEnd:
                        offsetCross = isWrapReversed ? paddingBorder.crossStart(for: direction) : (freeCrossSpace - paddingBorder.crossEnd(for: direction))
                    case .center:
                        offsetCross = freeCrossSpace / 2.0
                    case .baseline:
                        offsetCross = freeCrossSpace / 2.0 // Treat as center for now until we have baseline support
                    case .stretch:
                        offsetCross = isWrapReversed ? (freeCrossSpace - paddingBorder.crossEnd(for: direction)) : paddingBorder.crossStart(for: direction)
                    }
                }
                
                let layout = Layout(order: UInt32(order),
                                    size: computeResult.size,
                                    location: Point(
                                        x: isRow ? offsetMain : offsetCross,
                                        y: isColumn ? offsetMain : offsetCross
                                    ),
                                    children: computeResult.children)
                
                return layout
                
            case .failure(_): return nil
            }
        })
    
    for child in absoluteChildren {
        children.append(child)
    }
    
    func hiddenLayout(on node: InternalNode,
                      order: UInt32) -> Layout {
        return Layout(order: order,
                      size: Size<Float32>(width: 0.0, height: 0.0),
                      location: Point<Float32>(x: 0.0, y: 0.0),
                      children: node.children.enumerated().compactMap({
                            return hiddenLayout(on: $1, order: UInt32($0))
                      }))
    }
    
    let hiddenChildren: [Layout] = node
        .children
        .enumerated()
        .filter({ $1.style.display == .none })
        .compactMap({
            return hiddenLayout(on: $1, order: UInt32($0))
        })
    
    children.append(contentsOf: hiddenChildren)
    children.sort(by: { $0.order < $1.order })
    
    let result = ComputeResult(size: containerSize,
                               children: children)
    node.layoutCache = Cache(nodeSize: nodeSize,
                             parentSize: parentSize,
                             performLayout: performLayout,
                             result: result)
    
    return .success(result)
}
