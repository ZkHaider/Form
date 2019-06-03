//
//  Form.Sequence+Extensions.swift
//  Form
//
//  Created by Haider Khan on 6/2/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

extension EnumeratedSequence {
    mutating func mutateEach(_ body: (inout Element) -> ()) {
        for value in self {
            var value = value 
            body(&value)
        }
    }
}
