//
//  ButtonCell.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/15/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    
    var buttonTappedHandler: (() -> Void)?
    
    var buttonTitle: String? {
        set {
            button.setTitle(newValue, for: .normal)
        }
        
        get {
            return button.title(for: .normal)
        }
    }
    
    var buttonTitleColor: UIColor? {
        set {
            button.setTitleColor(newValue, for: .normal)
        }
        
        get {
            return button.titleColor(for: .normal)
        }
    }

    private let button: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Add Model Endpoint", for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onButtonTapped(_ sender: UIButton) {
        buttonTappedHandler?()
    }
    
}
