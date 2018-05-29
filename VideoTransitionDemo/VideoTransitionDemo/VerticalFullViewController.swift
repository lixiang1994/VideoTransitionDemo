//
//  VerticalFullViewController.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/18.
//  Copyright © 2018年 李响. All rights reserved.
//

import UIKit

class VerticalFullViewController: UIViewController {

    lazy var transition: Transition = {
        loadViewIfNeeded()
        $0.targetView = playerView
        $0.targetGravity = .resizeAspectFill
        return $0
    } ( VideoFullTransition() )
    
    /// 详情控制器 持有 防止每次初始化新的 (根据需求调整即可)
    lazy var detailController: DetailViewController = .instance()
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    
    @IBOutlet weak var statusHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupLayout()
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
        statusHeightConstraint.constant = CGFloat(20).i58full(44)
    }
    
    private func gotoDetail() {
        if presentingViewController is DetailViewController {
            dismiss(animated: true) { }
        } else {
            let controller = detailController
            let transition = controller.transition as! VideoDetailTransition
            transition.sourceView = playerView
            transition.sourceGravity = .resizeAspectFill
            controller.type = .vertical
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
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    class func instance() -> Self {
        return StoryBoard.main.instance()
    }
    
    deinit { print("VerticalFullViewController deinit") }
}

extension VerticalFullViewController {
    
    /// 显示控件
    private func showControls() {
        UIView.beginAnimations("", context: nil)
        backButton.alpha = 1.0
        detailButton.alpha = 1.0
        UIView.commitAnimations()
    }
    
    /// 隐藏控件
    private func hideControls() {
        UIView.beginAnimations("", context: nil)
        backButton.alpha = 0
        detailButton.alpha = 0
        UIView.commitAnimations()
    }
}

extension VerticalFullViewController: VideoFullable { }
extension VerticalFullViewController: TransitionTarget { }
