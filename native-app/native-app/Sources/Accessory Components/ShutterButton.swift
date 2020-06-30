//
//  ShutterButton.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/18/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class ShutterButton: UIButton {
    
    private let innerCircle: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        view.layer.masksToBounds =  true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let shapeLayer = CAShapeLayer()
    
    private var innerCircleWidth: NSLayoutConstraint!
    private var innerCircleHeight: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        
        addSubview(innerCircle)
        
        innerCircleWidth = innerCircle.widthAnchor.constraint(equalTo: widthAnchor, constant: -20)
        innerCircleHeight = innerCircle.heightAnchor.constraint(equalTo: heightAnchor, constant: -20)
        innerCircle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        innerCircle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        innerCircleWidth.isActive = true
        innerCircleHeight.isActive = true
        
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addTarget(self, action: #selector(onButtonPressedDown), for: .touchDown)
        addTarget(self, action: #selector(onButtonReleasedInside), for: .touchUpInside)
        addTarget(self, action: #selector(onButtonReleasedOutside), for: .touchUpOutside)
        
        innerCircle.layer.cornerRadius = innerCircle.bounds.width / 2
        
        drawOuterRing()
    }
    
    private func drawOuterRing() {
        let diameter = min(bounds.width, bounds.height)
        let radius = diameter / 2 - 5
        
        let path = UIBezierPath()
        path.lineWidth = 5
        
        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                    radius: radius,
                    startAngle: 0,
                    endAngle: 2 * CGFloat.pi,
                    clockwise: true)
        
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOffset = .zero
        shapeLayer.shadowRadius = 0.25
        shapeLayer.shadowOpacity = 0.25
    }
    
    @objc private func onButtonPressedDown(_ sender: UIButton) {
        self.innerCircleWidth.constant = -25
        self.innerCircleHeight.constant = -25
        self.innerCircle.layer.cornerRadius = (self.innerCircle.bounds.width - 2.5) / 2
    }
    
    @objc private func onButtonReleasedInside(_ sender: UIButton) {
        self.innerCircleWidth.constant = -20
        self.innerCircleHeight.constant = -20
        self.innerCircle.layer.cornerRadius = (self.innerCircle.bounds.width + 2.5) / 2
    }
    
    @objc private func onButtonReleasedOutside(_ sender: UIButton) {
        self.innerCircleWidth.constant = -20
        self.innerCircleHeight.constant = -20
        self.innerCircle.layer.cornerRadius = (self.innerCircle.bounds.width + 2.5) / 2
    }
    
}
