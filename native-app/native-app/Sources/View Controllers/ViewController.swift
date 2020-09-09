//
//  ViewController.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/3/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit
import AVKit

///
/// Main VC of the app; this VC contains the Unity view for AR, shutter button, model selection, and navigation bar with settings button
///
class ViewController: UIViewController {
    
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
    
    private let shutterButton = ShutterButton()
    
    private let unityView = UnityView()
    
    private let settingsViewController = SettingsViewController()
    
    private var settings: SettingsModel? {
        didSet {
            if let filteredModels = filteredModels, let model = settings?.activeEndpoint,
                !filteredModels.contains(model) {
                settings?.activeEndpoint = filteredModels.first
                
                changeActiveEndpoint()
            }
            
            if let endpoint = settings?.activeEndpoint, endpoint.isValid {
                modelSelectionButton.setTitle(settings?.activeEndpoint?.name ??
                    settings?.activeEndpoint?.url!, for: .normal)
            } else {
                modelSelectionButton.setTitle("Choose Model", for: .normal)
            }
            
            settingsViewController.settingsModel = settings
            settingsViewController.reloadSettings()
        }
    }
    
    private var filteredModels: [ModelEndpoint]? {
        return settings?.modelEndpoints.filter { $0.isValid }
    }
    
    private var namesForFilteredModels: [String]? {
        return filteredModels?.map { $0.name ?? $0.url! }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUnityView()
        setupModelSelectionView()
        setupShutterButton()
        
        UnityEmbeddedSwift.instance?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            present(Dialogs.noCameraAccess, animated: true)
        }
    }
    
    // MARK: - UI Setup
    
    private func setupNavigationBar() {
        navigationItem.title = "Unity SynthDet Viewer"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(onSettingsTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
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
    
    private func setupShutterButton() {
        view.addSubview(shutterButton)
        
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        
        shutterButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        shutterButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        shutterButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        shutterButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -25).isActive = true
        
        shutterButton.addTarget(self, action: #selector(onShutterButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Helper functions
    
    private func changeActiveEndpoint() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.settings?.activeEndpoint),
            let json = String(bytes: encoded, encoding: .utf8) {
            UnityEmbeddedSwift.instance?.sendUnityMessageToGameObject("Settings",
                                                                      method: "SetActiveEndpointFromJson",
                                                                      message: json)
        }
    }
    
    private func testInternetConnection() {
        DispatchQueue.global().async {
            let test = try? String(contentsOf: URL(string: "https://unity3d.com")!, encoding: .utf8)
            if test == nil {
                DispatchQueue.main.async {
                    self.present(Dialogs.noInternetAccess, animated: true)
                }
            }
        }
    }
    
    // MARK: - Button press callbacks
    
    @objc private func onSettingsTapped(_ sender: UIBarButtonItem) {
        let settingsNavVc = UINavigationController(rootViewController: settingsViewController)
        settingsNavVc.modalPresentationStyle = .pageSheet
        present(settingsNavVc, animated: true)
    }
    
    @objc private func onChooseModelTapped(_ sender: UIButton) {
        guard let filteredModels = filteredModels, filteredModels.count > 0,
            let names = namesForFilteredModels else {
                
            present(Dialogs.noModelEndpoints, animated: true)
            return
        }
        
        let modelChooser = ActionListViewController(items: names)
        modelChooser.actionSelectedHandler = { index in
            self.settings?.activeEndpoint = filteredModels[index]
            
            self.changeActiveEndpoint()
            
            self.testInternetConnection()
        }
        modelChooser.selectedIndex = filteredModels.firstIndex(where: { $0 == settings?.activeEndpoint })
        modelChooser.modalPresentationStyle = .popover
        
        let popoverController = modelChooser.popoverPresentationController
        popoverController?.sourceView = modelSelectionBackground
        popoverController?.permittedArrowDirections = [.down]
        
        present(modelChooser, animated: true)
    }
    
    @objc private func onShutterButtonTapped(_ sender: UIButton) {
        UnityEmbeddedSwift.instance?.sendUnityMessageToGameObject("AR Session Main", method: "CaptureWithFormat", message: "Both")
        AudioServicesPlaySystemSoundWithCompletion(1108, {
            AudioServicesDisposeSystemSoundID(1108);
        });
    }
    
}

// MARK: - NativeCallsDelegate implementation for receiving events from Unity

extension ViewController: NativeCallsDelegate {
    
    func arFoundationDidReceiveCameraFrame(_ imageBytes: Data) {
        // Do nothing, this method is unused
    }
    
    func settingsJsonDidChange(_ json: Data) {
        let decoder = JSONDecoder()
        
        if let settings = try? decoder.decode(SettingsModel.self, from: json) {
            self.settings = settings
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func imageRequestHandler(_ imageBytes: Data) {
        self.settingsViewController.useQrCodeFromImage(CIImage(cgImage: UIImage(data: imageBytes)!.cgImage!))
    }
    
}
