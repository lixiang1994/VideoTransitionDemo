//
//  VideoTransition.swift
//  LiveTrivia
//
//  Created by 李响 on 2018/5/10.
//  Copyright © 2018年 LiveTrivia. All rights reserved.
//

import Foundation
import UIKit
import AVKit

/*
 视频全屏过渡
 动画视图为全屏VC的view
 从来源视图的大小动画到全屏大小
 如果全屏VC的优先方向是横屏 那么动画中增加旋转
 */

protocol VideoFullable: NSObjectProtocol {}

class VideoFullTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    public var sourceView: UIView?
    public var targetView: UIView?
    public var sourceGravity: AVLayerVideoGravity = .resizeAspect
    public var targetGravity: AVLayerVideoGravity = .resizeAspect
    
    public var presentDuration: TimeInterval = 0.3
    public var dismissDuration: TimeInterval = 0.3
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = VideoFullAnimatedTransitioning(.present)
        transitioning.duration = presentDuration
        transitioning.sourceView = sourceView
        transitioning.targetView = targetView
        transitioning.sourceGravity = sourceGravity
        transitioning.targetGravity = targetGravity
        return transitioning
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = VideoFullAnimatedTransitioning(.dismiss)
        transitioning.duration = dismissDuration
        transitioning.sourceView = targetView
        transitioning.targetView = sourceView
        transitioning.sourceGravity = targetGravity
        transitioning.targetGravity = sourceGravity
        return transitioning
    }
}

class VideoFullAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    public var sourceView: UIView?
    public var targetView: UIView?
    public var sourceGravity: AVLayerVideoGravity = .resizeAspect
    public var targetGravity: AVLayerVideoGravity = .resizeAspect
    
    public var duration: TimeInterval = 0.5
    
    let type: TransitionType
    
    init(_ type: TransitionType) {
        self.type = type
        super.init()
    }
    
    func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let fromView = fromViewController.view,
            let toViewController = transitionContext.viewController(forKey: .to),
            let toView = toViewController.view else { return }
        guard let sourceView = sourceView, let targetView = targetView else { return }
        
        fromView.layoutIfNeeded()
        toView.layoutIfNeeded()
        
        let containerView = transitionContext.containerView
        let sourceCenter = sourceView.superview!.convert(sourceView.center, to: containerView)
        
        toView.clipsToBounds = true
        toView.bounds = sourceView.bounds
        toView.center = sourceCenter
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        containerView.addSubview(toView)
        
        // 根据目标VC的优先方向设置目标视图的旋转
        switch toViewController.preferredInterfaceOrientationForPresentation {
        case .landscapeLeft:
            toView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        case .landscapeRight:
            toView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        default: break
        }
        
        // 设置layer
        playerLayer.frame = targetView.bounds
        targetView.layer.addSublayer(playerLayer)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .layoutSubviews,
            animations: {
                
                toView.transform = .identity
                toView.bounds = containerView.bounds
                toView.center = containerView.center
                toView.layoutIfNeeded()
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(.easeInOut)
                playerLayer.videoGravity = self.targetGravity
                CATransaction.commit()
        }) { (_) in
            
            toView.transform = .identity
            toView.bounds = containerView.bounds
            toView.center = containerView.center
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let targetView = targetView else { return }
        
        fromView.layoutIfNeeded()
        toView.layoutIfNeeded()
        
        let containerView = transitionContext.containerView
        let targetRect = targetView.convert(targetView.bounds, to: containerView)
        
        containerView.insertSubview(toView, belowSubview: fromView)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .layoutSubviews,
            animations: {
                fromView.transform = .identity
                fromView.frame = targetRect
                fromView.layoutIfNeeded()
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(.easeInOut)
                playerLayer.videoGravity = self.targetGravity
                CATransaction.commit()
        }) { (_) in
            // 移除视图
            fromView.removeFromSuperview()
            
            // 设置layer
            playerLayer.frame = targetView.bounds
            targetView.layer.addSublayer(playerLayer)
            targetView.layer.insertSublayer(playerLayer, at: 0)
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch type {
        case .present:
            presentAnimation(transitionContext)
        case .dismiss:
            dismissAnimation(transitionContext)
        }
    }
}
