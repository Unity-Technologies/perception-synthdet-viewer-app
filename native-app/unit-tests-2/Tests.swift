//
//  Tests.swift
//  unit-tests
//
//  Created by Michael Pavkovic on 6/9/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import XCTest

class Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoundingBoxRotationDown() throws {
        let box = BoundingBox(topLeft: Point2D(x: 100, y: 100), bottomRight: Point2D(x: 200, y: 300))
        let resultingBox = BoundingBox(topLeft: Point2D(x: 300, y: 300), bottomRight: Point2D(x: 400, y: 500))
        
        XCTAssert(box.rotated(by: .down, in: CGSize(width: 500, height: 600)) == resultingBox)
    }
    
    func testBoundingBoxRotationLeft() throws {
        let box = BoundingBox(topLeft: Point2D(x: 100, y: 100), bottomRight: Point2D(x: 200, y: 300))
        let resultingBox = BoundingBox(topLeft: Point2D(x: 100, y: 300), bottomRight: Point2D(x: 300, y: 400))
        XCTAssert(box.rotated(by: .left, in: CGSize(width: 500, height: 600)) == resultingBox)
    }
    
    func testBoundingBoxRotationRight() throws {
        let box = BoundingBox(topLeft: Point2D(x: 100, y: 100), bottomRight: Point2D(x: 200, y: 300))
        let resultingBox = BoundingBox(topLeft: Point2D(x: 300, y: 100), bottomRight: Point2D(x: 500, y: 200))
        
        XCTAssert(box.rotated(by: .right, in: CGSize(width: 500, height: 600)) == resultingBox)
    }
    
    func testBoundingBoxRotationLeftTwiceIsDown() throws {
        let box = BoundingBox(topLeft: Point2D(x: 100, y: 100), bottomRight: Point2D(x: 200, y: 300))
        let resultingBox = box.rotated(by: .down, in: CGSize(width: 500, height: 600))
        XCTAssert(box.rotated(by: .left, in: CGSize(width: 500, height: 600))?.rotated(by: .left, in: CGSize(width: 600, height: 500)) == resultingBox)
    }
    
    func testBoundingBoxRotationRightTwiceIsDown() throws {
        let box = BoundingBox(topLeft: Point2D(x: 100, y: 100), bottomRight: Point2D(x: 200, y: 300))
        let resultingBox = box.rotated(by: .down, in: CGSize(width: 500, height: 600))
        XCTAssert(box.rotated(by: .right, in: CGSize(width: 500, height: 600))?.rotated(by: .right, in: CGSize(width: 600, height: 500)) == resultingBox)
    }
    
    func testBoundingBoxRotationLeftThenRightIsOriginalPicture() throws {
        let box = BoundingBox(topLeft: Point2D(x: 100, y: 100), bottomRight: Point2D(x: 200, y: 300))
        XCTAssert(box.rotated(by: .left, in: CGSize(width: 500, height: 600))?.rotated(by: .right, in: CGSize(width: 600, height: 500)) == box)
    }

}
