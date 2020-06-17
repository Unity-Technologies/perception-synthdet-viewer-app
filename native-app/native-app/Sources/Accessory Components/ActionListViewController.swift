//
//  ActionListViewController.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/16/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class ActionListViewController: UITableViewController {

    private enum Keys {
        
        static let actionCell = "ActionCell"

    }

    private let MAX_HEIGHT: CGFloat = 440
    private let MIN_HEIGHT: CGFloat = 44
    
    let items: [String]
    
    var actionSelectedHandler: ((Int) -> Void)?
    
    var selectedIndex: Int? {
        didSet {
            guard let index = selectedIndex, index < items.count else { return }
            // Select new row
            tableView.cellForRow(at: IndexPath(row: index, section: 0))?.accessoryType = .checkmark
            
            // Deselect old row
            if let oldIndex = oldValue, selectedIndex != index {
                tableView.cellForRow(at: IndexPath(row: oldIndex, section: 0))?.accessoryType = .none
            }
            
            actionSelectedHandler?(index)
            
            self.dismiss(animated: true)
        }
    }
    
    init(items: [String]) {
        self.items = items
        
        super.init(style: .plain)
        
        tableView.delegate = self
        tableView.allowsMultipleSelection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let index = selectedIndex {
            tableView.cellForRow(at: IndexPath(row: index, section: 0))?.accessoryType = .checkmark
        }
    }
    
}

// MARK: - UITableViewDelegate methods
extension ActionListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if preferredContentSize != tableView.contentSize {
            preferredContentSize = tableView.contentSize
            preferredContentSize.height = max(min(preferredContentSize.height, MAX_HEIGHT), MIN_HEIGHT)
            view.setNeedsLayout()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Keys.actionCell) ?? UITableViewCell(style: .default, reuseIdentifier: Keys.actionCell)
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndex = indexPath.row
    }

}
