//
//  ViewController.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/3/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let IMAGE_SIZE_LANDSCAPE = CGSize(width: 1280, height: 960)
    private let SCALE_FACTOR: CGFloat = 1024.0 / 1280.0
    
    private let unityView = UnityView()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    private var boundingBoxes: [UIView] = []
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UnityEmbeddedSwift.instance?.delegate = self
        
        view.backgroundColor = .white
        
        navigationItem.title = "Unity SynthDet"
        
        setupUnityView()
        setupBoundingBoxes()
    }
    
    private func setupUnityView() {
        view.addSubview(unityView)
        
        unityView.translatesAutoresizingMaskIntoConstraints = false
        
        unityView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        unityView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        unityView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        unityView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupBoundingBoxes() {
        for _ in 0..<30 {
            let box = UIView()
            
            box.layer.borderWidth = 2
            box.layer.borderColor = UIColor.blue.cgColor
            box.layer.cornerRadius = 4
            boundingBoxes.append(box)
        }
        boundingBoxes.forEach(view.addSubview)
    }
    
}

extension ViewController: NativeCallsDelegate {
    
    func arFoundationDidReceiveCameraFrame(_ imageBytes: Data) {
        var task = URLRequest(url: URL(string: "https://34.82.135.220:8443/predictions/synthdet")!)
        
        task.httpMethod = "POST"
        task.httpBody = imageBytes
        task.addValue("image/jpg", forHTTPHeaderField: "Content-Type")
        
        urlSession.dataTask(with: task).resume()
    }
    
}

extension ViewController: URLSessionDataDelegate {
    
    // Override needed to validate self-signed SSL certificates
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {        
        do {
            let classifications = try decoder.decode([ObjectClassification].self, from: data)
                .filter { $0.score > 0.75 }
            
            DispatchQueue.main.async {
                let orientation = UIApplication.shared.statusBarOrientation.isPortrait ?
                    BoundingBox.Rotation.left :
                    BoundingBox.Rotation.down
                
                for i in 1..<self.boundingBoxes.count {
                    if i >= classifications.count {
                        self.boundingBoxes[i].isHidden = true
                        
                        return
                    } else {
                        self.boundingBoxes[i].frame = classifications[i].box
                            .rotated(by: orientation, in: self.IMAGE_SIZE_LANDSCAPE)
                            .scaled(by: self.SCALE_FACTOR)
                            .cgRect
                        
                        self.boundingBoxes[i].setNeedsLayout()
                        self.boundingBoxes[i].isHidden = false
                    }
                }
            }
        } catch _ {
            print("Prediction error")
            DispatchQueue.main.async {
                self.boundingBoxes.forEach { $0.isHidden = true }
            }
        }
    }
    
}
