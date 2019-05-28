//
//  Form.Layout.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public struct Layout {
    public let order: UInt32
    public let size: Size<Float32>
    public let location: Point<Float32>
    public let children: [Layout]
}

extension Layout: Equatable {
    public static func ==(lhs: Layout,
                          rhs: Layout) -> Bool {
        if lhs.order != rhs.order {
            return false
        }
        if lhs.size != rhs.size {
            return false
        }
        if lhs.location != rhs.location {
            return false
        }
        if lhs.children != rhs.children {
            return false
        }
        return true 
    }
}
