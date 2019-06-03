//
//  Form.Node.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Node {
    
    // MARK: - Attributes
    
    internal let boxedNode: Box<InternalNode>
    internal var backingNode: InternalNode {
        return boxedNode.value
    }
    
    var dirty: Bool {
        get {
            return self.backingNode.isDirty
        }
    }
    
    var style: Style<Dimension> {
        get {
            return self.backingNode.style
        }
        set(newValue) {
            self.setStyle(newValue)
        }
    }
    
    var children: [Node] {
        get {
            return self.backingNode.children
                .compactMap({ $0.value })
                .compactMap({ Node($0) })
        }
        set(newValue) {
            self.setChildren(newValue)
        }
    }
    
    var measureFunction: MeasureFunc? {
        get {
            return self.backingNode.measureFunction
        }
        set(newValue) {
            self.setMeasureFunction(newValue)
        }
    }
    
    var childCount: Int {
        return children.count
    }
    
    // MARK: - Init

    init(_ internalNode: InternalNode) {
        self.boxedNode = Box(value: internalNode)
    }
    
    internal init(style: Style<Dimension>,
                measureFunction: MeasureFunc) {
        let internalNode = InternalNode(
            style: style,
            parents: [],
            children: [],
            measureFunction: measureFunction,
            layoutCache: nil,
            isDirty: true
        )
        self.boxedNode = Box(value: internalNode)
    }
    
    internal init(style: Style<Dimension>,
                children: [Node]) {
        
        let internalNode = InternalNode(
            style: style,
            parents: [],
            children: children.compactMap({ Weak<InternalNode>(value: $0.backingNode) }),
            measureFunction: nil,
            layoutCache: nil,
            isDirty: true
        )
        
        for child in internalNode.children {
            child.value?.parents.append(Weak<InternalNode>(value: internalNode))
        }
        
        self.boxedNode = Box(value: internalNode)
    }
    
    // MARK: - Public
    
    public func addChild(_ child: Node) {
        child.backingNode.parents.append(Weak(value: self.backingNode))
        self.backingNode.children.append(Weak(value: child.backingNode))
        self.markDirty()
    }
    
    // Can cause crash - intended.
    public func removeChild(_ child: Node) -> Node {
        guard
            let index = self.backingNode.children.firstIndex(where: { $0.value == child.backingNode })
            else {
                fatalError("Could not find child.")
        }
        return self.removeChild(at: index)
    }
    
    // Can cause crash - intended.
    public func removeChild(at index: Int) -> Node {
        let child = self.backingNode.children.remove(at: index)
        
        guard
            let index = child.value?.parents.firstIndex(where: { $0.value == self.backingNode })
            else {
                fatalError("Parent index does not exist.")
        }
        child.value?.parents.remove(at: index)
        self.markDirty()
        return Node(child.value!)
    }
    
    // Can cause crash - intended.
    public func replaceChild(at index: Int,
                             with child: Node) -> Node {
        child.backingNode.parents.append(Weak(value: self.backingNode))
        let oldChild = self.backingNode.children.remove(at: index)
        
        if let parentIndex = oldChild.value?.parents.firstIndex(where: { $0.value == self.backingNode }) {
            oldChild.value?.parents.remove(at: parentIndex)
        }
        
        self.markDirty()
        return Node(oldChild.value!)
    }
    
    public func computeLayout(for size: Size<Number>) -> Result<Layout> {
        return compute(on: self.backingNode, size: size)
    }
    
    // MARK: - Private Methods
    
    private func setMeasureFunction(_ measure: MeasureFunc?) {
        self.backingNode.measureFunction = measure
        self.markDirty()
    }
    
    private func setChildren(_ children: [Node]) {
        for child in self.backingNode.children {
            if let parentIndex = child.value?.parents.firstIndex(where: { $0.value == self.backingNode }) {
                child.value?.parents.remove(at: parentIndex)
            }
        }
        
        self.backingNode.children = []
        for child in children {
            child.backingNode.parents.append(Weak(value: self.backingNode))
            self.backingNode.children.append(Weak(value: child.backingNode))
        }
        
        self.markDirty()
    }
    
    private func setStyle(_ style: Style<Dimension>) {
        self.backingNode.style = style
        self.markDirty()
    }
    
    private func markDirty() {
        let node = self.backingNode
        node.layoutCache = nil
        node.isDirty = true
        node.parents.forEach({ $0.value?.isDirty = true })
    }
    
}

extension Node: Equatable {
    
    public static func ==(lhs: Node,
                          rhs: Node) -> Bool {
        if lhs.childCount != rhs.childCount {
            return false
        }
        if lhs.children != rhs.children {
            return false
        }
        if lhs.dirty != rhs.dirty {
            return false
        }
        if lhs.style != rhs.style {
            return false 
        }
        return true
    }
    
}

extension Node: NodeLayout {
    
    public static func node(style: Style<Dimension>,
                            measureFunction: MeasureFunc) -> Node {
        return Node(style: style, measureFunction: measureFunction)
    }
    
    public static func node(style: Style<Dimension>,
                            children: Node...) -> Node {
        return Node(style: style, children: children)
    }
    
    public static func node(style: Style<Dimension>,
                            children: [Node]) -> Node {
        return Node(style: style, children: children)
    }
    
}
