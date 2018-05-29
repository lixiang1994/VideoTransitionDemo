//
//  VideoDetailTransition.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/18.
//  Copyright © 2018年 李响. All rights reserved.
//

import Foundation
import UIKit
import AVKit

/*
 视频详情过渡
 动画视图为临时view
 从来源视图的大小动画到详情视图大小 (详情视图大小位置固定)
 如果来源VC的优先方向是横屏 那么动画中增加旋转
 dismiss时根据目标VC的横竖屏方向支持判断是否需要做旋转处理
 */

class VideoDetailTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    public var sourceView: UIView?
    public var targetView: UIView?
    public var sourceGravity: AVLayerVideoGravity = .resizeAspect
    public var targetGravity: AVLayerVideoGravity = .resizeAspect
    
    public var presentDuration: TimeInterval = 0.3
    public var dismissDuration: TimeInterval = 0.3
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = VideoDetailAnimatedTransitioning(.present)
        transitioning.duration = presentDuration
        transitioning.sourceView = sourceView
        transitioning.targetView = targetView
        transitioning.sourceGravity = sourceGravity
        transitioning.targetGravity = targetGravity
        return transitioning
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = VideoDetailAnimatedTransitioning(.dismiss)
        transitioning.duration = dismissDuration
        transitioning.sourceView = targetView
        transitioning.targetView = sourceView
        transitioning.sourceGravity = targetGravity
        transitioning.targetGravity = sourceGravity
        return transitioning
    }
}

class VideoDetailAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        let targetRect = targetView.convert(targetView.bounds, to: containerView)
        
        toView.alpha = 0.0
        toView.clipsToBounds = true
        toView.bounds = containerView.bounds
        toView.center = containerView.center
        containerView.addSubview(toView)
        
        let tempView = PlayerView()
        tempView.clipsToBounds = true
        tempView.backgroundColor = .black
        tempView.bounds = sourceView.bounds
        tempView.center = sourceCenter
        containerView.addSubview(tempView)
        
        // 根据来自VC的优先方向设置临时视图旋转 (跳转横全屏时)
        switch fromViewController.preferredInterfaceOrientationForPresentation {
        case .landscapeLeft:
            tempView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        case .landscapeRight:
            tempView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        default: break
        }
        // 设置layer
        playerLayer.frame = tempView.bounds
        tempView.layer.addSublayer(playerLayer)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .layoutSubviews,
            animations: {
                tempView.transform = .identity
                tempView.frame = targetRect
                toView.alpha = 1.0
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(.easeInOut)
                playerLayer.videoGravity = self.targetGravity
                CATransaction.commit()
        }) { (_) in
            // 移除临时视图
            tempView.removeFromSuperview()
            
            // 设置layer
            playerLayer.frame = targetView.bounds
            targetView.layer.addSublayer(playerLayer)
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = toViewController.view else { return }
        guard let sourceView = sourceView, let targetView = targetView else { return }
        
        fromView.layoutIfNeeded()
        toView.layoutIfNeeded()
        
        let containerView = transitionContext.containerView
        let sourceCenter = sourceView.superview!.convert(sourceView.center, to: containerView)
        let targetRect = targetView.convert(targetView.bounds, to: containerView)
        
        containerView.insertSubview(toView, belowSubview: fromView)
        
        let tempView = PlayerView()
        tempView.clipsToBounds = true
        tempView.backgroundColor = .black
        tempView.bounds = sourceView.bounds
        tempView.center = sourceCenter
        containerView.addSubview(tempView)
        
        // 根据VC支持的屏幕方向和当前屏幕方向设置旋转 (返回横全屏时)
        switch toViewController.preferredInterfaceOrientationForPresentation {
        case .landscapeLeft:
            tempView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        case .landscapeRight:
            tempView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        default: break
        }
        
        // 设置layer
        playerLayer.frame = tempView.bounds
        tempView.layer.addSublayer(playerLayer)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .layoutSubviews,
            animations: {
                tempView.transform = .identity
                tempView.frame = targetRect
                fromView.alpha = 0.0
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(.easeInOut)
                playerLayer.videoGravity = self.targetGravity
                CATransaction.commit()
        }) { (_) in
            // 移除临时视图
            fromView.removeFromSuperview()
            tempView.removeFromSuperview()
            
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

