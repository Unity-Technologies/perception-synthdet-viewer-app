//
//  Dialogs.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/30/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

enum Dialogs {
    
    static var noInternetAccess: UIAlertController {
        let alert = UIAlertController(title: "No Internet Access",
                                      message: "Your device does not have Internet access, which is required for fetching object detection data",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
    
    static var noModelEndpoints: UIAlertController {
        let alert = UIAlertController(title: "No Valid Model Endpoints",
                                      message: "Please tap Settings in the top right to add model endpoints. A valid model endpoint must have a URL",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
    
    static var noCameraAccess: UIAlertController {
        let alert = UIAlertController(title: "No Camera Access",
                                      message: "Unity Object Detector needs access to your device's camera to detect objects in its view",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
    
    static var couldNotFindQrCode: UIAlertController {
        let alert = UIAlertController(title: "No QR Code in View",
                                      message: "Please position a QR code within your device's camera before scanning",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
    
}
