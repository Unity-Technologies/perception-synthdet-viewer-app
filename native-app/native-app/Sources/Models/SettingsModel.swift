//
//  SettingsModel.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/22/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import Foundation

struct SettingsModel: Codable {
    
    var predictionScoreThreshold: Float
    var modelEndpoints: [ModelEndpoint]
    var activeEndpoint: ModelEndpoint?
    
}
