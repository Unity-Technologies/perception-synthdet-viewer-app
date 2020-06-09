//
//  ObjectClassification.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/8/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

struct ObjectClassification: Codable {
    
    let label: String
    let box: BoundingBox
    let score: Float
    
}
