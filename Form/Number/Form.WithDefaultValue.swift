//
//  Form.WithDefaultValue.swift
//  Form
//
//  Created by Haider Khan on 5/27/19.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

public protocol WithDefaultValue {
    static var defaultValue: Self { get }
}
