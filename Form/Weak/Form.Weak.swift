//
//  Form.Weak.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Weak<T: AnyObject> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}

extension Weak: Equatable where T: Equatable {
    public static func ==(lhs: Weak<T>,
                          rhs: Weak<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
