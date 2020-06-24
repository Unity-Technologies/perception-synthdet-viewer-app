//
//  ShareCapturesCell.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/24/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class ShareCapturesCell: UITableViewCell {
    
    var shareButtonTappedHandler: (() -> Void)?

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Share Captures", for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(shareButton)
        
        shareButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        shareButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        shareButton.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        shareButton.addTarget(self, action: #selector(onShareButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onShareButtonTapped(_ sender: UIButton) {
        shareButtonTappedHandler?()
    }
    
}

