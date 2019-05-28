//
//  Form.Function.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Function<A, B> {
    let f: (A) -> B
}

extension Function {
    
    public func map<C>(_ f: @escaping (A) -> C) -> Function<A, C> {
        return Function<A, C> { f($0) }
    }

}
