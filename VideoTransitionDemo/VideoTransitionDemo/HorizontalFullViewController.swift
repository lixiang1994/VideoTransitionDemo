//
//  HorizontalFullViewController.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/18.
//  Copyright © 2018年 李响. All rights reserved.
//

import UIKit

class HorizontalFullViewController: UIViewController {

    lazy var transition: Transition = {
        loadViewIfNeeded()
        $0.targetView = playerView
        $0.targetGravity = .resizeAspect
        return $0
    } ( VideoFullTransition() )
    
    /// 优先方向 用于判断过渡时的方向 同步旋转屏幕时的过渡旋转效果
    lazy var preferredOrientation: UIInterfaceOrientation = .landscapeRight
    
    /// 详情控制器 持有 防止每次初始化新的
    lazy var detailController: DetailViewController = .instance()
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    
    @IBOutlet weak var statusHeightConstraint: NSLayoutConstraint!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupLayout()
        setupNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 解决横竖屏切换时 view异常
        view.frame = UIScreen.main.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 显示控件 优化过渡效果
        showControls()
    }
    
    private func setup() {
        backButton.alpha = 0
        detailButton.alpha = 0
    }
    
    private func setupLayout() {
        statusHeightConstraint.constant = 0
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc func deviceOrientationDidChange() {
        guard shouldAutorotate else { return }
        
        switch UIDevice.current.orientation {
        case .portrait:
            guard presentedViewController == nil else { return }
            gotoDetail()
        case .landscapeLeft:
            preferredOrientation = .landscapeRight
        case .landscapeRight:
            preferredOrientation = .landscapeLeft
        default: break
        }
    }
    
    private func gotoDetail() {
        if presentingViewController is DetailViewController {
            dismiss(animated: true) { }
        } else {
            let controller = detailController
            let transition = controller.transition as! VideoDetailTransition
            transition.sourceView = playerView
            transition.sourceGravity = .resizeAspect
            controller.type = .horizontal
            controller.modalPresentationStyle = .fullScreen
            controller.transitioningDelegate = transition
            present(controller, animated: true) { }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true) { }
    }
    
    @IBAction func detailAction(_ sender: Any) {
        gotoDetail()
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        
        hideControls()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        hideControls()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return preferredOrientation
    }
    
    class func instance() -> Self {
        return StoryBoard.main.instance()
    }
    
    deinit { print("HorizontalFullViewController deinit") }
}

extension HorizontalFullViewController {
    
    /// 显示控件
    private func showControls() {
        UIView.beginAnimations("", context: nil)
        backButton.alpha = 1.0
        detailButton.alpha = 1.0
        UIView.commitAnimations()
    }
    
    /// 隐藏控件
    private func hideControls() {
        backButton.alpha = 0
        detailButton.alpha = 0
    }
}

extension HorizontalFullViewController: VideoFullable { }
extension HorizontalFullViewController: TransitionTarget { }
