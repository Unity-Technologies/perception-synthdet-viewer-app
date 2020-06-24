//
//  AddModelCell.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/15/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class AddModelCell: UITableViewCell {
    
    var addButtonTappedHandler: (() -> Void)?

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Add Model Endpoint", for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(addButton)
        
        addButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addButton.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addButton.addTarget(self, action: #selector(onShareButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onShareButtonTapped(_ sender: UIButton) {
        addButtonTappedHandler?()
    }
    
}
