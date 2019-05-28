//
//  Form.Cache.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Cache {
    public let nodeSize: Size<Number>
    public let parentSize: Size<Number>
    public let performLayout: Bool
    
    public let result: ComputeResult
}

extension Cache: Equatable {
    public static func ==(lhs: Cache,
                          rhs: Cache) -> Bool {
        if lhs.nodeSize != rhs.nodeSize {
            return false
        }
        if lhs.parentSize != rhs.parentSize {
            return false
        }
        if lhs.performLayout != rhs.performLayout {
            return false
        }
        if lhs.result != rhs.result {
            return false
        }
        return true
    }
}
