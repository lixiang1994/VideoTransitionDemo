//
//  DetailViewController.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/18.
//  Copyright © 2018年 李响. All rights reserved.
//

import UIKit
import Foundation

enum DetailType {
    case horizontal
    case vertical
}

class DetailViewController: UIViewController {
    
    var type: DetailType = .horizontal
    
    lazy var transition: Transition = {
        loadViewIfNeeded()
        $0.targetView = playerView
        $0.targetGravity = .resizeAspect
        return $0
    } ( VideoDetailTransition() )
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fullButton: UIButton!
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var statusHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showControls()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 解决横竖屏切换时 view异常
        view.frame = UIScreen.main.bounds
    }
    
    private func setup() {
        backButton.alpha = 0
        fullButton.alpha = 0
    }
    
    private func setupLayout() {
        statusHeightConstraint.constant = CGFloat(20).ifull(44)
    }
    
    @objc private func deviceOrientationDidChange() {
        guard shouldAutorotate else { return }
        guard presentedViewController == nil else { return }
        guard type == .horizontal else { return }
        
        switch UIDevice.current.orientation {
        case .landscapeRight, .landscapeLeft:
            gotoFull()
        default: break
        }
    }
    
    private func gotoFull() {
        if presentingViewController is VideoFullable {
            dismiss(animated: true) { }
        } else {
            switch type {
            case .horizontal:
                var orientation: UIInterfaceOrientation = UIDevice.current.orientation == .landscapeRight ? .landscapeLeft : .landscapeRight
                orientation = shouldAutorotate ?  orientation : .landscapeRight
                let controller = HorizontalFullViewController.instance()
                let transition = controller.transition as! VideoFullTransition
                transition.sourceView = playerView
                transition.sourceGravity = .resizeAspect
                controller.preferredOrientation = orientation
                controller.modalPresentationStyle = .fullScreen
                controller.transitioningDelegate = transition
                present(controller, animated: true) { }
            case .vertical:
                let controller = VerticalFullViewController.instance()
                let transition = controller.transition as! VideoFullTransition
                transition.sourceView = playerView
                transition.sourceGravity = .resizeAspect
                controller.modalPresentationStyle = .fullScreen
                controller.transitioningDelegate = transition
                present(controller, animated: true) { }
            }
        }
        
        hideControls()
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true) { }
    }
    
    @IBAction func fullAction(_ sender: Any) {
        gotoFull()
    }
    @IBAction func commentAction(_ sender: Any) {
        CommentInputViewController.present(self)
    }
    
    override var shouldAutorotate: Bool {
        return true
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
    
    deinit { print("DetailViewController deinit") }
}

extension DetailViewController {
    
    /// 显示控件
    private func showControls() {
        UIView.beginAnimations("", context: nil)
        backButton.alpha = 1.0
        fullButton.alpha = 1.0
        UIView.commitAnimations()
    }
    
    /// 隐藏控件
    private func hideControls() {
        UIView.beginAnimations("", context: nil)
        backButton.alpha = 0
        fullButton.alpha = 0
        UIView.commitAnimations()
    }
}

extension DetailViewController: CommentInputViewControllerDelegate {
    
    func send(content: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(true)
        }
    }
}

extension DetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
}

extension DetailViewController: UITableViewDelegate {
    
}

extension DetailViewController: TransitionTarget { }
