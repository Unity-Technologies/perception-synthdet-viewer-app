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
        slider.value = 0.5
        
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
    
    private let separatorView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.systemGray2.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
        
        return view
    }()
    
    private let currentValueLabel: UILabel = {
        let label = UILabel()
        
        label.text = "50%"
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    public var valueChangeHandler: ((Float) -> Void)?
    
    public var value: Float = 0.5 {
        didSet {
            currentValueLabel.text = valueTextForPercentage(value)
            slider.value = value
            
            valueChangeHandler?(value)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(slider)
        addSubview(maximumLabel)
        addSubview(minimumLabel)
        addSubview(separatorView)
        addSubview(currentValueLabel)
        
        currentValueLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        currentValueLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        currentValueLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        separatorView.rightAnchor.constraint(equalTo: currentValueLabel.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        maximumLabel.rightAnchor.constraint(equalTo: separatorView.leftAnchor, constant: -10).isActive = true
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        separatorView.layer.sublayers?[0].frame = separatorView.bounds
    }
    
    @objc private func onSliderValueChanged(_ sender: UISlider) {
        value = sender.value
    }
    
    private func valueTextForPercentage(_ percentage: Float) -> String {
        return "\(Int(round(percentage * 100)))%"
    }
    
}
