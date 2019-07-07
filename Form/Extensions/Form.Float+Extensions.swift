//
//  Float+Extensions.swift
//  Form
//
//  Created by Haider Khan on 5/23/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation
import CoreGraphics

extension Float {
    public var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat {
    public var float: Float {
        return Float(self)
    }
}
