//
//  VideoTableViewCell.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/18.
//  Copyright © 2018年 李响. All rights reserved.
//

import UIKit

protocol VideoTableViewCellDelegate: NSObjectProtocol {
    func fullH(view: UIView)
    func fullV(view: UIView)
    func detail(view: UIView, type: DetailType)
}

class VideoTableViewCell: UITableViewCell {

    weak var delegate: VideoTableViewCellDelegate?
    var indexPath: IndexPath?
    
    @IBOutlet weak var playerView: PlayerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func detailAction(_ sender: Any) {
        // 为了演示 第二条打开横屏
        let type: DetailType = indexPath?.row == 1 ? .horizontal : .vertical
        delegate?.detail(view: playerView, type: type)
    }
    
    @IBAction func fullAction(_ sender: Any) {
        // 为了演示 第二条打开横屏
        if indexPath?.row == 1 {
            delegate?.fullH(view: playerView)
        } else {
            delegate?.fullV(view: playerView)
        }
    }
}
