//
//  Extension.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/18.
//  Copyright © 2018年 李响. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func startLoading(_ activityIndicatorStyle: UIActivityIndicatorView.Style = .white) {
        stopLoading()
        
        let maskView = UIView(frame: bounds)
        
        addSubview(maskView)
        maskView.tag = 1994
        
        if let button = self as? UIButton {
            button.titleLabel?.alpha = 0.0
            button.imageView?.alpha = 0.0
        }
        maskView.backgroundColor = backgroundColor
        
        let load = UIActivityIndicatorView(style: activityIndicatorStyle)
        
        maskView.addSubview(load)
        load.center = maskView.center
        load.startAnimating()
    }
    
    func stopLoading() {
        guard let maskView = viewWithTag(1994) else { return }
        
        if let button = self as? UIButton {
            button.titleLabel?.alpha = 1.0
            button.imageView?.alpha = 1.0
        }
        maskView.removeFromSuperview()
    }
}
