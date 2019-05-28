//
//  ViewController.swift
//  Example
//
//  Created by Haider Khan on 5/28/19.
//  Copyright © 2019 flow. All rights reserved.
//

import UIKit
import Form

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let parentLayout: Node = .node(
            style: .defaultValue,
            children: [
                .node(style: .defaultValue,
                      children: .node(style: .defaultValue, children: [])),
                .node(style: .defaultValue, children: [])
            ])
        
        let compute = parentLayout.computeLayout(for: Size<Number>(width: .undefined, height: .undefined))
        
    }


}

