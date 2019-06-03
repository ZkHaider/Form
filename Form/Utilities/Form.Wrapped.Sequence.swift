//
//  Form.Wrapped.Sequence.swift
//  Form
//
//  Created by Haider Khan on 6/1/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

struct WrappedSequence<Wrapped: Sequence, Element>: Sequence {
    typealias IteratorFunction = (inout Wrapped.Iterator) -> Element?
    
    private let wrapped: Wrapped
    private let iterator: IteratorFunction
    
    init(wrapping wrapped: Wrapped,
         iterator: @escaping IteratorFunction) {
        self.wrapped = wrapped
        self.iterator = iterator
    }
    
    func makeIterator() -> AnyIterator<Element> {
        var wrappedIterator = self.wrapped.makeIterator()
        return AnyIterator { self.iterator(&wrappedIterator) }
    }
}

extension Sequence where Element == Weak<InternalNode> {
    var nodeIterator: WrappedSequence<Self, Element> {
        return WrappedSequence(wrapping: self) { iterator in
            return iterator.next()
        }
    }
}
