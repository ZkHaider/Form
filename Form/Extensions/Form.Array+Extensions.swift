//
//  Form.Array+Extensions.swift
//  Form
//
//  Created by Haider Khan on 6/1/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

extension Array {
    mutating func mutateEach(_ body: (inout Element) -> ()) {
        for index in self.indices {
            body(&self[index])
        }
    }
    
    mutating func mutateReduce<A>(into initial: A,
                                  _ combine: (inout A, inout Iterator.Element) -> ()) -> A {
        var result = initial
        for index in self.indices {
            combine(&result, &self[index])
        }
        return result
    }
}

