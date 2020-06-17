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
    private let scaleFactor: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 1280.0 * UIScreen.main.nativeScale
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    private let modelSelectionBackground: UIVisualEffectView = {
        let view = UIVisualEffectView()
        
        view.layer.cornerRadius = 22
        view.layer.masksToBounds = true
        view.effect = UIBlurEffect(style: .systemThinMaterial)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let modelSelectionButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Choose Model", for: .normal)
        button.setTitleColor(.label, for: .normal)
        
        button.titleLabel?.numberOfLines = 1
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let unityView = UnityView()
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    private var filteredModels: [ModelEndpoint]?
    private var selectedModelEndpoint: ModelEndpoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UnityEmbeddedSwift.instance?.delegate = self
        
        setupNavigationBar()
        setupUnityView()
        setupModelSelectionView()
        
        loadModelsFromUserDefaults()
        
        if let filteredModels = filteredModels, filteredModels.count > 0 {
            selectedModelEndpoint = filteredModels.first
            
            modelSelectionButton.setTitle(selectedModelEndpoint?.name ?? selectedModelEndpoint?.url, for: .normal)
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Unity SynthDet"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(onSettingsTapped))
    }
    
    private func setupUnityView() {
        view.addSubview(unityView)
        
        unityView.translatesAutoresizingMaskIntoConstraints = false
        
        unityView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        unityView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        unityView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        unityView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupModelSelectionView() {
        view.addSubview(modelSelectionBackground)
        modelSelectionBackground.contentView.addSubview(modelSelectionButton)
        
        modelSelectionBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        modelSelectionBackground.widthAnchor.constraint(lessThanOrEqualToConstant: 360).isActive = true
        
        let minimumWidth = modelSelectionBackground.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor)
        minimumWidth.priority = .defaultHigh
        minimumWidth.isActive = true
        
        modelSelectionBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        modelSelectionBackground.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        modelSelectionButton.widthAnchor.constraint(equalTo: modelSelectionBackground.widthAnchor).isActive = true
        modelSelectionButton.heightAnchor.constraint(equalTo: modelSelectionBackground.heightAnchor).isActive = true
        modelSelectionButton.topAnchor.constraint(equalTo: modelSelectionBackground.topAnchor).isActive = true
        modelSelectionButton.leftAnchor.constraint(equalTo: modelSelectionBackground.leftAnchor).isActive = true
        
        modelSelectionButton.addTarget(self, action: #selector(onChooseModelTapped), for: .touchUpInside)
    }
    
    private func loadModelsFromUserDefaults() {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.models),
            let models = try? decoder.decode([ModelEndpoint].self, from: data) {
            
            filteredModels = models.filter { $0.url != nil && $0.url != "" }
        }
    }
    
    @objc private func onSettingsTapped(_ sender: UIBarButtonItem) {
        let settingsVc = SettingsViewController()
        let settingsNavVc = UINavigationController(rootViewController: settingsVc)
        
        settingsNavVc.modalPresentationStyle = .pageSheet
        settingsVc.dismissHandler = {
            self.loadModelsFromUserDefaults()
            
            if let filteredModels = self.filteredModels, let model = self.selectedModelEndpoint, !filteredModels.contains(model) {
                self.selectedModelEndpoint = filteredModels.first
                
                self.modelSelectionButton.setTitle(self.selectedModelEndpoint?.name ?? self.selectedModelEndpoint?.url, for: .normal)
            }
        }
        
        present(settingsNavVc, animated: true)
    }
    
    @objc private func onChooseModelTapped(_ sender: UIButton) {
        guard let filteredModels = filteredModels, filteredModels.count > 0 else { return }
        
        let names = filteredModels.map { $0.name ?? $0.url! }
        
        let modelChooser = ActionListViewController(items: names)
        modelChooser.actionSelectedHandler = { index in
            self.selectedModelEndpoint = filteredModels[index]
            
            self.modelSelectionButton.setTitle(names[index], for: .normal)
        }
        modelChooser.selectedIndex = filteredModels.firstIndex(where: { $0 == selectedModelEndpoint }) ?? 0
        modelChooser.modalPresentationStyle = .popover
        
        let popoverController = modelChooser.popoverPresentationController
        popoverController?.sourceView = modelSelectionBackground
        popoverController?.permittedArrowDirections = [.down]
        
        present(modelChooser, animated: true)
    }
    
}

// MARK: - Receiving events from Unity
extension ViewController: NativeCallsDelegate {
    
    func arFoundationDidReceiveCameraFrame(_ imageBytes: Data) {
        guard let urlString = selectedModelEndpoint?.url, let url = URL(string: urlString) else {
            logger.error("Cannot parse url from: \(String(describing: selectedModelEndpoint?.url))")
            return
        }
        
        var task = URLRequest(url: url)
        
        task.httpMethod = "POST"
        task.httpBody = imageBytes
        task.addValue("image/jpg", forHTTPHeaderField: "Content-Type")
        
        urlSession.dataTask(with: task).resume()
    }
    
}

// MARK: - Networking with backend
extension ViewController: URLSessionDataDelegate {
    
    // Override needed to validate self-signed SSL certificates
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        do {
            let classifications = try decoder.decode([ObjectClassification].self, from: data)
                .filter { $0.score > max(UserDefaults.standard.float(forKey: UserDefaultsKeys.predictionThreshold), 0.5) }
            
            DispatchQueue.main.async {
                let orientation = UIApplication.shared.statusBarOrientation.isPortrait ?
                    BoundingBox.Rotation.left :
                    BoundingBox.Rotation.down
                
                let scaledBoxes = classifications.map {
                        ObjectClassification(label: $0.label,
                            box: $0.box
                               .rotated(by: orientation, in: self.IMAGE_SIZE_LANDSCAPE)
                               .scaled(by: self.scaleFactor),
                            score: $0.score)
                    }
                
                let encoder = JSONEncoder()
                if let jsonData = try? encoder.encode(scaledBoxes),
                    let jsonString = String(bytes: jsonData, encoding: .utf8) {
                    UnityEmbeddedSwift.instance?.sendUnityMessageToGameObject("AR Session Origin",
                        method: "SetObjectClassificationsFromJson",
                        message: "{\"objects\": \(jsonString)}")
                }
            }
        } catch _ {
            DispatchQueue.main.async {
                UnityEmbeddedSwift.instance?.sendUnityMessageToGameObject("AR Session Origin",
                    method: "SetObjectClassificationsFromJson",
                    message: "{\"objects\": []}")
            }
        }
    }
    
}
