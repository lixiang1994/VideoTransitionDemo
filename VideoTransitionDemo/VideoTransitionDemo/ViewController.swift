//
//  ViewController.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/18.
//  Copyright © 2018年 李响. All rights reserved.
//

import UIKit
import AVKit

// 主要为了演示视频转场过渡 视频播放器简单带过
let url = URL(string: "https://devstreaming-cdn.apple.com/videos/tutorials/20170912/201qy4t11tjpm/building_apps_for_iphone_x/hls_vod_mvp.m3u8")!
let player = AVPlayer(playerItem: playerItem)
let playerItem = AVPlayerItem(url: url)
let playerLayer = AVPlayerLayer(player: player)

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 为了解决横竖屏切换时 SafeArea变动导致的布局问题
        // 这里所有的布局尽量不要使用SafeArea
        topConstraint.constant = CGFloat(20).i58full(44)
        
        player.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 解决横竖屏切换时 view异常
        view.frame = UIScreen.main.bounds
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
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VideoTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "竖屏视频 - "
        case 1:
            return "横屏视频 - "
        default:
            return ""
        }
    }
}

extension ViewController: VideoTableViewCellDelegate {
    
    /// 跳转全屏(横屏)
    func fullH(view: UIView) {
        let controller = HorizontalFullViewController.instance()
        let transition = controller.transition as! VideoFullTransition
        transition.sourceView = view
        transition.sourceGravity = .resizeAspect
        controller.modalPresentationStyle = .fullScreen
        controller.transitioningDelegate = transition
        present(controller, animated: true) { }
    }
    
    /// 跳转全屏(竖屏)
    func fullV(view: UIView) {
        let controller = VerticalFullViewController.instance()
        let transition = controller.transition as! VideoFullTransition
        transition.sourceView = view
        transition.sourceGravity = .resizeAspect
        controller.modalPresentationStyle = .fullScreen
        controller.transitioningDelegate = transition
        present(controller, animated: true) { }
    }
    
    /// 跳转详情
    func detail(view: UIView, type: DetailType) {
        let controller = DetailViewController.instance()
        let transition = controller.transition as! VideoDetailTransition
        transition.sourceView = view
        transition.sourceGravity = .resizeAspect
        controller.type = type
        controller.modalPresentationStyle = .fullScreen
        controller.transitioningDelegate = transition
        present(controller, animated: true) { }
    }
}
