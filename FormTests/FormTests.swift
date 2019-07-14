//
//  FormTests.swift
//  FormTests
//
//  Created by Haider Khan on 7/13/19.
//  Copyright © 2019 flow. All rights reserved.
//

import XCTest
@testable import Form

class FormTests: XCTestCase {
    
    lazy var node: Node = {
        return .node(
            .layout(
                size: Size(width: .points(500.0),
                           height: .points(500.0))),
            children: .node(
                .layout(
                    position: Rect(start: .percent(0.02),
                                   end: .percent(0.52),
                                   top: .percent(0.02),
                                   bottom: .percent(0.52)),
                    size: Size(
                        width: .percent(0.5),
                        height: .percent(0.5)
                    ),
                    aspectRatio: .defined(0.5)
                )
            )
        )
    }()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLayoutBasicCompute() {
        let result = self.node.computeLayout()
        let layout = try! result.get()
        assert(
            layout.size.width == 500.0 &&
            layout.size.height == 500.0 &&
            layout.location.x == 0.0 &&
            layout.location.y == 0.0 &&
            layout.children[0].size.width == 250.0 &&
            layout.children[0].size.height == 250.0 &&
            layout.children[0].location.x == 0.0 &&
            layout.children[0].location.y == 0.0
        )
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
