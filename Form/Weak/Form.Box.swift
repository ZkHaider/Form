//
//  Form.Box.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

final class Ref<T> {
    var value: T
    init(value: T) {
        self.value = value
    }
}

struct Box<T> {
    private var ref: Ref<T>
    init(value: T) {
        self.ref = Ref(value: value)
    }
    
    var value: T {
        get { return self.ref.value }
        set {
            guard
                isKnownUniquelyReferenced(&ref)
                else {
                    self.ref = Ref(value: newValue)
                    return
            }
            ref.value = newValue
        }
    }
}

extension Box: Equatable where T: Equatable {
    static func ==(lhs: Box,
                   rhs: Box) -> Bool {
        return lhs.value == rhs.value
    }
}
