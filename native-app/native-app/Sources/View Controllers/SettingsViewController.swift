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
        static let shareCapturesCell = "ShareCapturesCell"
        
    }
    
    public var settingsModel: SettingsModel?
    
    private var editModelsButton: UIBarButtonItem?
    private var doneButton: UIBarButtonItem?
    private var doneEditingModelsButton: UIBarButtonItem?
    
    var dismissHandler: (() -> Void)?
    
    init() {
        super.init(style: .grouped)
        
        tableView.register(ThresholdCell.self, forCellReuseIdentifier: Keys.thresholdCell)
        tableView.register(ModelCell.self, forCellReuseIdentifier: Keys.modelCell)
        tableView.register(AddModelCell.self, forCellReuseIdentifier: Keys.addModelCell)
        tableView.register(ShareCapturesCell.self, forCellReuseIdentifier: Keys.shareCapturesCell)
        
        tableView.allowsSelection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if settingsModel == nil {
            settingsModel = SettingsModel(predictionScoreThreshold: 0.75, modelEndpoints: [], activeEndpoint: nil)
        }
        
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
    
    public func reloadSettings() {
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    @objc private func onEditModelsTapped(_ sender: UIBarButtonItem) {
        guard let models = settingsModel?.modelEndpoints else { return }
        
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
        guard let models = settingsModel?.modelEndpoints else { return }
        
        tableView.isEditing = false
        
        navigationItem.leftBarButtonItem = editModelsButton
        navigationItem.rightBarButtonItem = doneButton
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: models.count, section: 1)], with: .top)
        tableView.endUpdates()
    }
    
    private func onAddModelButtonTapped() {
        guard let models = settingsModel?.modelEndpoints else { return }
        
        settingsModel?.modelEndpoints.append(ModelEndpoint(name: nil, url: nil))
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: models.count, section: 1)], with: .top)
        tableView.endUpdates()
    }
    
    private var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}

// MARK: - UITableViewDelegate methods
extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return (settingsModel?.modelEndpoints.count ?? 0) + (tableView.isEditing ? 1 : 0)
        case 2: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Prediction Score Threshold"
        case 1: return "Model Endpoints"
        case 2: return "Capture Export Settings"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Keys.thresholdCell, for: indexPath)
            
            if let thresholdCell = cell as? ThresholdCell {
                thresholdCell.value = settingsModel?.predictionScoreThreshold ?? 0.5
                thresholdCell.valueChangeHandler = { self.settingsModel?.predictionScoreThreshold = $0 }
            }
            
            return cell
        } else if indexPath.section == 1 {
            if let models = settingsModel?.modelEndpoints, indexPath.row == models.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: Keys.addModelCell, for: indexPath)
                (cell as? AddModelCell)?.addButtonTappedHandler = onAddModelButtonTapped
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Keys.modelCell, for: indexPath)
                
                if let modelCell = cell as? ModelCell, let models = settingsModel?.modelEndpoints {
                    modelCell.row = indexPath.row
                    modelCell.modelEndpoint = models[indexPath.row]
                    modelCell.delegate = self
                }
                
                return cell
            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Keys.shareCapturesCell, for: indexPath)
            
            (cell as? ShareCapturesCell)?.shareButtonTappedHandler = {
                let folderUrl = self.documentsDirectory.appendingPathComponent("Captures")
                
                let activityViewController = UIActivityViewController(activityItems: [folderUrl], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = cell.contentView
                self.present(activityViewController, animated: true)
            }
            
            return cell
        } else {
            fatalError("Bad index path")
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row < settingsModel?.modelEndpoints.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            settingsModel?.modelEndpoints.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}

extension SettingsViewController: ModelCellDelegate {
    
    func modelCell(_ modelCell: ModelCell, didChangeModel modelEndpoint: ModelEndpoint?) {
        if let row = modelCell.row, let modelEndpoint = modelEndpoint {
            settingsModel?.modelEndpoints[row] = modelEndpoint
        }
    }
    
}
