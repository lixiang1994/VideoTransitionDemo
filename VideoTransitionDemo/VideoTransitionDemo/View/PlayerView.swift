//
//  PlayerView.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/18.
//  Copyright © 2018年 李响. All rights reserved.
//

import UIKit

class PlayerView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let animation = layer.animation(forKey: "bounds.size") {
            CATransaction.begin()
            CATransaction.setAnimationDuration(animation.duration)
            CATransaction.setAnimationTimingFunction(animation.timingFunction)
            layer.sublayers?.forEach({ $0.frame = bounds })
            CATransaction.commit()
        } else {
            layer.sublayers?.forEach({ $0.frame = bounds })
        }
    }
    
}
