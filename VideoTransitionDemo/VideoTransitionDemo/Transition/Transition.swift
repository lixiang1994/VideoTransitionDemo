//
//  Transition.swift
//  LiveTrivia
//
//  Created by 李响 on 2017/11/29.
//  Copyright © 2017年 LiveTrivia. All rights reserved.
//

import UIKit

enum TransitionType {
    case present
    case dismiss
}

typealias Transition = UIViewControllerTransitioningDelegate

protocol TransitionTarget {
    var transition: Transition { get }
}

extension UIViewController {
    
    func presentWithTransition<T: UIViewController & TransitionTarget>(_ vc: T, completion: (() -> Void)? = nil) {
        vc.transitioningDelegate = vc.transition
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: completion)
    }
    
}
