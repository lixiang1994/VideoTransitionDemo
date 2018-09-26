//
//  CAMediaTimingFunction+Extension.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/22.
//  Copyright © 2018年 李响. All rights reserved.
//

import UIKit

extension CAMediaTimingFunction {
    // default
    public static let linear = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    public static let easeIn = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
    public static let easeOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    public static let easeInOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    
    // material
    public static let standard = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
    public static let deceleration = CAMediaTimingFunction(controlPoints: 0.0, 0.0, 0.2, 1)
    public static let acceleration = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 1, 1)
    public static let sharp = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.6, 1)
    
    // easing.net
    public static let easeOutBack = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
    
    static func from(name: String) -> CAMediaTimingFunction? {
        switch name {
        case "linear":
            return .linear
        case "easeIn":
            return .easeIn
        case "easeOut":
            return .easeOut
        case "easeInOut":
            return .easeInOut
        case "standard":
            return .standard
        case "deceleration":
            return .deceleration
        case "acceleration":
            return .acceleration
        case "sharp":
            return .sharp
        default:
            return nil
        }
    }
}
