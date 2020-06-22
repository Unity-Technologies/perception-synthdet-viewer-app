//
//  ViewController.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/3/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

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
    
    private var filteredModels: [ModelEndpoint]?
    
    private var selectedModelEndpoint: ModelEndpoint? {
        didSet {
            guard let url = selectedModelEndpoint?.url else { return }
            
            UnityEmbeddedSwift.instance?.sendUnityMessageToGameObject("AR Session Main",
                method: "SetUrl",
                message: url)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUnityView()
        setupModelSelectionView()
        setupShutterButton()
        
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
    
    private func setupShutterButton() {
        view.addSubview(shutterButton)
        
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        
        shutterButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        shutterButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        shutterButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        shutterButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -25).isActive = true
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
