//
//  ThresholdCell.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/12/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class ThresholdCell: UITableViewCell {
    
    private let slider: UISlider = {
        let slider = UISlider()
        
        slider.minimumValue = 0.5
        slider.maximumValue = 1.0
        slider.value = UserDefaults.standard.float(forKey: UserDefaultsKeys.predictionThreshold)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }()
    
    private let minimumLabel: UILabel = {
        let label = UILabel()
        
        label.text = "50%"
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let maximumLabel: UILabel = {
        let label = UILabel()
        
        label.text = "100%"
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(maximumLabel)
        addSubview(minimumLabel)
        addSubview(slider)
        
        maximumLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        maximumLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        minimumLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        minimumLabel.widthAnchor.constraint(equalTo: maximumLabel.widthAnchor).isActive = true
        minimumLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        slider.leftAnchor.constraint(equalTo: minimumLabel.rightAnchor, constant: 10).isActive = true
        slider.rightAnchor.constraint(equalTo: maximumLabel.leftAnchor, constant: -10).isActive = true
        slider.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        slider.addTarget(self, action: #selector(onSliderValueChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onSliderValueChanged(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: UserDefaultsKeys.predictionThreshold)
    }
    
}
