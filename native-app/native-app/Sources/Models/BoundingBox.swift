//
//  BoundingBox.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/8/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

public struct BoundingBox: Codable, Equatable {
    
    enum Rotation {
        
        /// Rotation of nothing relative to itself
        case up
        
        /// Rotation of 90° relative to itself
        case right
        
        /// Rotation of 180° relative to itself
        case down
        
        /// Rotation of 270° relative to itself
        case left
        
    }
    
    let topLeft: Point2D
    
    let bottomRight: Point2D
    
    ///
    /// Rotates an image by a specified 90° or 180° turn, either to the left, right, up, or upside down
    ///
    /// - Parameter rotation: `Rotation` to turn the picture
    /// - Parameter imageSize: Original size of the image, before the rotation occurs
    ///
    func rotated(by rotation: Rotation, in imageSize: CGSize) -> BoundingBox {
        let width = imageSize.width
        let height = imageSize.height
        
        switch rotation {
        case .up:
            return self
        case .down:
            return BoundingBox(topLeft: Point2D(x: width - bottomRight.x, y: height - bottomRight.y),
                               bottomRight: Point2D(x: width - topLeft.x, y: height - topLeft.y))
        case .left:
            return BoundingBox(topLeft: Point2D(x: topLeft.y, y: width - bottomRight.x),
                               bottomRight: Point2D(x: bottomRight.y, y: width - topLeft.x))
        case .right:
            return BoundingBox(topLeft: Point2D(x: height - bottomRight.y, y: topLeft.x),
                               bottomRight: Point2D(x: height - topLeft.y, y: bottomRight.x))
        }
    }
    
    ///
    /// Scales a bounding box's size by a specified factor. This transform does not center around a point, unlike `rotated(by:)`
    ///
    /// - Parameter scaleFactor: Float to scale by, where a value of 1 is the identity scale, values less than 1 shrink the box, and values greater than 1 expand the box
    ///
    func scaled(by scaleFactor: CGFloat) -> BoundingBox {
        return BoundingBox(topLeft: Point2D(x: topLeft.x * scaleFactor, y: topLeft.y * scaleFactor),
                           bottomRight: Point2D(x: bottomRight.x * scaleFactor, y: bottomRight.y * scaleFactor))
    }
    
    ///
    /// A `CGRect` representation of the bounding box
    ///
    var cgRect: CGRect {
        return CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
    }
    
}

public struct Point2D: Codable, Equatable {
    
    let x: CGFloat
    
    let y: CGFloat
    
}
