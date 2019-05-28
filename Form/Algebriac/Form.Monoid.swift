//
//  Form.Monoid.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public protocol Monoid: Semigroup {
    static var identity: Self { get }
}

func concat<M: Monoid>(_ values: [M]) -> M {
    return values.reduce(M.identity, <>)
}

public func concat<M: Monoid>(_ values: M...) -> M {
    return concat(values)
}
