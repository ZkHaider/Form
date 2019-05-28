//
//  Form.ComputeResult.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct ComputeResult {
    public let size: Size<Float32>
    public let children: [Layout]
}

extension ComputeResult: Equatable {
    public static func ==(lhs: ComputeResult,
                          rhs: ComputeResult) -> Bool {
        if lhs.size != rhs.size {
            return false
        }
        if lhs.children != rhs.children {
            return false
        }
        return true 
    }
}
