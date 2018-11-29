//
//  CommentInputViewController.swift
//  VideoTransitionDemo
//
//  Created by 李响 on 2018/5/18.
//  Copyright © 2018年 李响. All rights reserved.
//

import UIKit

protocol CommentInputViewControllerDelegate: NSObjectProtocol {
    func send(content: String, completion: @escaping (Bool)->Void)
}

class CommentInputViewController: UIViewController {
    
    weak var delegate: CommentInputViewControllerDelegate?
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var editHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var sending: Bool = false
    private var closing: Bool = false
    
    private let maxWordNumber = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupLayout()
        setupNotification()
        
        textView.becomeFirstResponder()
    }
    
    private func setup() {
        textView.font = .systemFont(ofSize: 14.0)
        textView.textContainerInset = UIEdgeInsets(top: 10.5, left: 8, bottom: 10.5, right: 8)
    }
    
    private func setupLayout() {
        bottomConstraint.constant = -editHeightConstraint.constant
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillChangeFrame(_ notify: Notification) {
        guard let info = notify.userInfo else {
            return
        }
        guard let local = info[UIResponder.keyboardIsLocalUserInfoKey] as? Int, local == 1 else {
            return
        }
        guard
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as?TimeInterval,
            let curveRaw = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIView.AnimationCurve(rawValue: curveRaw),
            let endRect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        handleKeyboard(duration: duration, curve: curve, endRect: endRect)
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        sending = true
        sender.startLoading(.gray)
        let content = textView.text
            .prefix(maxWordNumber)
            .replacingOccurrences(of: "\n", with: " ")
        
        delegate?.send(content: content, completion: { [weak self] (result) in
            guard let this = self else { return }
            this.sending = false
            if result {
                this.closing = true
                this.textView.resignFirstResponder()
            } else {
                sender.stopLoading()
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard
            let first = touches.first,
            !editView.frame.contains(first.location(in: view)) else {
            return
        }
        closing = true
        view.endEditing(true)
    }
    
    @discardableResult
    class func present<T: UIViewController & CommentInputViewControllerDelegate>(_ controller: T) -> CommentInputViewController {
        let vc = CommentInputViewController.instance()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = controller
        controller.present(vc, animated: true, completion: nil)
        return vc
    }
    
    class func instance() -> Self {
        return StoryBoard.main.instance()
    }
    
    deinit { print("CommentInputViewController deinit") }
}

extension CommentInputViewController {
    
    private func handleKeyboard(duration: TimeInterval, curve: UIView.AnimationCurve, endRect: CGRect) {
        var closing = self.closing
        let bounds = UIScreen.main.bounds
        let offset = endRect.origin.y.rounded()
        let hide = offset == bounds.height || offset == bounds.width
        if hide {
            closing = true
            self.closing = closing
            bottomConstraint.constant = -editHeightConstraint.constant
        } else {
            bottomConstraint.constant = endRect.height
        }
        UIView.animate(withDuration: duration, animations: {
            UIView.setAnimationCurve(curve)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            if hide, closing { self?.dismiss(animated: true, completion: nil) }
        }
    }
    
    private func updateTextViewHeight(height: CGFloat , animated: Bool) {
        textHeightConstraint.constant = height
        editHeightConstraint.constant = height + 16.0
        UIView.beginAnimations("height", context: nil)
        UIView.setAnimationDuration(0.2)
        UIView.setAnimationsEnabled(animated)
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }
}

extension CommentInputViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard sending == false else { return false }
        
        if range.location < maxWordNumber {
            return true
        } else if range.location < textView.text.count {
            // 超过规定字数，只能删除，不能添加
            return true
        } else {
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let lineHeight = textView.font?.lineHeight else { return }
        
        let maxRow = 6
        let maxHeight = ceilf(Float(lineHeight * CGFloat(maxRow) + textView.textContainerInset.top + textView.textContainerInset.bottom))
        let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat(MAXFLOAT)))
        let height = ceilf(Float(size.height))
        let currentHeight = ceilf(Float(textView.bounds.height))
        textView.isScrollEnabled = height > maxHeight && maxHeight > 0
        let targetHeight = textView.isScrollEnabled ? maxHeight : height
        if currentHeight != targetHeight {
            updateTextViewHeight(height: CGFloat(targetHeight), animated: true)
        }
        
        sendButton.isEnabled = textView.text.count != 0
    }
}
