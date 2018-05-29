//
//  StoryBoard.swift
//  LiveTrivia
//
//  Created by 李响 on 2018/1/16.
//  Copyright © 2018年 LiveTrivia. All rights reserved.
//

import Foundation
import UIKit

enum StoryBoard: String {
    case main               = "Main"
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: nil)
    }
    
    func instance<T>() -> T {
        return storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
}
