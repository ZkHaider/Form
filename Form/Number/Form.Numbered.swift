//
//  Form.ToNumbered.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Numbered<A> {
    public let convert: (A) -> Number
}

extension Numbered where A == Float32 {
    public static var `default`: Numbered<A> {
        return Numbered<A> { float in
            return .defined(float)
        }
    }
}
