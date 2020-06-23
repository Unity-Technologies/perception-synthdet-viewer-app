//
//  SettingsViewController.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/12/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    private enum Keys {
        
        static let thresholdCell = "ThresholdCell"
        static let modelCell = "ModelCell"
        static let addModelCell = "AddModelCell"
        
    }
    
    private var threshold: Float = 0.5
    private var models: [ModelEndpoint] = []
    
    public var settingsModel: SettingsModel? {
        didSet {
            guard let settings = settingsModel else { return }
            
            threshold = settings.predictionScoreThreshold
            models = settings.modelEndpoints
            
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    private var editModelsButton: UIBarButtonItem?
    private var doneButton: UIBarButtonItem?
    private var doneEditingModelsButton: UIBarButtonItem?
    
    var dismissHandler: (() -> Void)?
    
    init() {
        super.init(style: .grouped)
        
        tableView.register(ThresholdCell.self, forCellReuseIdentifier: Keys.thresholdCell)
        tableView.register(ModelCell.self, forCellReuseIdentifier: Keys.modelCell)
        tableView.register(AddModelCell.self, forCellReuseIdentifier: Keys.addModelCell)
        
        tableView.allowsSelection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editModelsButton = UIBarButtonItem(title: "Edit Models", style: .plain, target: self, action: #selector(onEditModelsTapped))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneTapped))
        doneEditingModelsButton = UIBarButtonItem(title: "Done Editing", style: .done, target: self, action: #selector(onDoneEditingModelsTapped))
        
        navigationItem.leftBarButtonItem = editModelsButton
        navigationItem.rightBarButtonItem = doneButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settingsModel), let json = String(bytes: encoded, encoding: .utf8) {
            UnityEmbeddedSwift.instance?.sendUnityMessageToGameObject("Settings", method: "SetSettingsModelFromJson", message: json)
            UnityEmbeddedSwift.instance?.sendUnityMessageToGameObject("Settings", method: "SaveSettings")
        }
        
        dismissHandler?()
    }
    
    @objc private func onEditModelsTapped(_ sender: UIBarButtonItem) {
        tableView.isEditing = true
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = doneEditingModelsButton
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: models.count, section: 1)], with: .top)
        tableView.endUpdates()
    }
    
    @objc private func onDoneTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc private func onDoneEditingModelsTapped(_ sender: UIBarButtonItem) {
        tableView.isEditing = false
        
        navigationItem.leftBarButtonItem = editModelsButton
        navigationItem.rightBarButtonItem = doneButton
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: models.count, section: 1)], with: .top)
        tableView.endUpdates()
    }
    
    private func onAddModelButtonTapped() {
        models.append(ModelEndpoint(name: nil, url: nil))
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: models.count - 1, section: 1)], with: .top)
        tableView.endUpdates()
    }
    
}

// MARK: - UITableViewDelegate methods
extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return models.count + (tableView.isEditing ? 1 : 0)
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Prediction Score Threshold"
        case 1: return "Model Endpoints"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Keys.thresholdCell, for: indexPath)
            
            if let thresholdCell = cell as? ThresholdCell {
                thresholdCell.value = threshold
                thresholdCell.valueChangeHandler = { self.threshold = $0 }
            }
            
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == models.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: Keys.addModelCell, for: indexPath)
                (cell as? AddModelCell)?.addButtonTappedHandler = onAddModelButtonTapped
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Keys.modelCell, for: indexPath)
                
                if let modelCell = cell as? ModelCell {
                    modelCell.row = indexPath.row
                    modelCell.modelEndpoint = models[indexPath.row]
                    modelCell.delegate = self
                }
                
                return cell
            }
        } else {
            fatalError("Bad index path")
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row < models.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            models.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}

extension SettingsViewController: ModelCellDelegate {
    
    func modelCell(_ modelCell: ModelCell, didChangeModel modelEndpoint: ModelEndpoint?) {
        if let row = modelCell.row, let modelEndpoint = modelEndpoint {
            models[row] = modelEndpoint
        }
    }
    
}
