//
//  UnityView.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/5/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import UIKit

class UnityView: UIView {
    private var unityView: UIView?
    
    init() {
        // Must be initialized with a frame size larger than 0
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        UnityEmbeddedSwift.instance?.load()
        unityView = UnityEmbeddedSwift.instance?.unityRootView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let unityView = unityView else {
            logger.warning("Attempting to load UnityView without Unity loaded first")
            return
        }
        
        unityView.removeFromSuperview()
        unityView.frame = bounds
        
        insertSubview(unityView, at: 0)
        unityView.setNeedsLayout()
    }
    
}
