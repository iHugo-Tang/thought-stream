import UIKit
import LucideIcons
import SwiftUI

class ChatInputView: UIView {
    // input bar view (encapsulated)
    private let textInputBar: ChatTextInputBarView
    private let audioInputBar = ChatAudioInputBarView()
    
    // dynamic constraints per bar
    private var textBarConstraints: [NSLayoutConstraint] = []
    private var audioBarConstraints: [NSLayoutConstraint] = []
    private var audioBarHeightConstraint: NSLayoutConstraint?
    
    private enum Mode { case text, audio }
    private var currentMode: Mode = .text
    // bottom view
    private let bottomView = UIView()
    private let bottomBackgroundView: UIView
    // blurredView
    private let blurredView: UIVisualEffectView
    
    // callbacks
    // update content frame and keyboard frame
    var onBottomViewFrameChanged: ((CGRect) -> Void)?
    
    init(chatViewModel: ChatViewModel? = nil, onBottomViewFrameChanged: ((CGRect) -> Void)?) {
        self.textInputBar = ChatTextInputBarView(chatViewModel: chatViewModel)
        self.bottomBackgroundView = UIView()
        self.onBottomViewFrameChanged = onBottomViewFrameChanged

        // Create the UIVisualEffectView
        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
        self.blurredView = UIVisualEffectView(effect: blurEffect)
        self.blurredView.backgroundColor = UIColor(Color.thoughtStream.white.opacity(0.9))
        self.blurredView.frame = CGRect(x: 50, y: 150, width: 250, height: 250)

        super.init(frame: .zero)

        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIKit.UIEvent?) -> UIKit.UIView? {
        let convertedPoint = bottomView.convert(point, from: self)
        if bottomView.bounds.contains(convertedPoint) {
            return bottomView.hitTest(convertedPoint, with: event)
        }
        return nil
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let onBottomViewFrameChanged {
            print("onBottomViewFrameChanged: \(bottomView.frame)")
            onBottomViewFrameChanged(bottomView.frame)
        }
    }
}

// setup views
extension ChatInputView {
    private func setupViews() {
        self.setupBottonView()
        self.addSubview(self.bottomView)
        
        // wire callbacks
        self.textInputBar.onMicTapped = { [weak self] in
            self?.switchToAudioMode()
        }

        self.audioInputBar.onCancelTapped = { [weak self] in
            self?.switchToTextMode()
        }
        self.audioInputBar.onStopTapped = { [weak self] in
            self?.switchToTextMode()
        }

        // show text bar lazily
        self.showTextBar(animated: false)
    }
    
    private func setupBottonView() {
        self.bottomBackgroundView.addSubview(self.blurredView)
        self.bottomView.addSubview(self.bottomBackgroundView)
        // bars will be added lazily when shown
    }
    
    private func setupConstraints() {
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        // bars are constrained when added lazily
        self.blurredView.translatesAutoresizingMaskIntoConstraints = false
        
        // bottomView / bottomBackgroundView | contentView
        // bottomView
        NSLayoutConstraint.activate([
            self.bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.bottomBackgroundView.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor),
            self.bottomBackgroundView.trailingAnchor.constraint(equalTo: self.bottomView.trailingAnchor),
            self.bottomBackgroundView.topAnchor.constraint(equalTo: self.bottomView.topAnchor),
            self.bottomBackgroundView.bottomAnchor.constraint(equalTo: self.bottomView.bottomAnchor)
        ])
        
        // bar constraints are added dynamically
        
        NSLayoutConstraint.activate([
            self.blurredView.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor),
            self.blurredView.trailingAnchor.constraint(equalTo: self.bottomView.trailingAnchor),
            self.blurredView.topAnchor.constraint(equalTo: self.bottomView.topAnchor),
            self.blurredView.bottomAnchor.constraint(equalTo: self.bottomView.bottomAnchor),
        ])
    }
    
    @objc func onMicButotnClicked(sender: UIButton) {
        print("onMicButotnClicked")
    }

    // MARK: - Lazy show/hide with animation
    private func constrainBar(_ bar: UIView, isAudio: Bool) -> [NSLayoutConstraint] {
        bar.translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = [
            bar.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor, constant: 16),
            bar.trailingAnchor.constraint(equalTo: self.bottomView.trailingAnchor, constant: -16),
            bar.topAnchor.constraint(greaterThanOrEqualTo: self.bottomView.topAnchor, constant: 8),
            bar.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor, constant: -8)
        ]
        if isAudio {
            // height constraint set separately for animation
            let h = bar.heightAnchor.constraint(equalToConstant: 52)
            audioBarHeightConstraint = h
            constraints.append(h)
        }
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    private func showTextBar(animated: Bool) {
        guard textInputBar.superview == nil else { return }
        currentMode = .text
        bottomView.addSubview(textInputBar)
        textBarConstraints = constrainBar(textInputBar, isAudio: false)
        textInputBar.alpha = 0
        textInputBar.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        let animations = {
            self.textInputBar.alpha = 1
            self.textInputBar.transform = .identity
        }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: animations)
        } else {
            animations()
        }
    }

    private func showAudioBar(animated: Bool) {
        guard audioInputBar.superview == nil else { return }
        currentMode = .audio
        bottomView.addSubview(audioInputBar)
        audioBarConstraints = constrainBar(audioInputBar, isAudio: true)
        audioInputBar.alpha = 0
        let animations = {
            self.audioInputBar.alpha = 1
        }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: animations)
        } else {
            animations()
        }
    }

    private func hideTextBar(animated: Bool, completion: (() -> Void)? = nil) {
        guard textInputBar.superview != nil else { completion?(); return }
        let animations = {
            self.textInputBar.alpha = 0
            self.textInputBar.transform = CGAffineTransform(scaleX: 1, y: 0.92)
        }
        let finished: (Bool) -> Void = { _ in
            NSLayoutConstraint.deactivate(self.textBarConstraints)
            self.textBarConstraints.removeAll()
            self.textInputBar.removeFromSuperview()
            completion?()
        }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: animations, completion: finished)
        } else {
            animations()
            finished(true)
        }
    }

    private func hideAudioBar(animated: Bool, completion: (() -> Void)? = nil) {
        guard audioInputBar.superview != nil else { completion?(); return }
        let animations = {
            self.audioInputBar.alpha = 0
            self.audioInputBar.transform = CGAffineTransform(scaleX: 1, y: 0.85)
        }
        let finished: (Bool) -> Void = { _ in
            NSLayoutConstraint.deactivate(self.audioBarConstraints)
            self.audioBarConstraints.removeAll()
            self.audioInputBar.removeFromSuperview()
            completion?()
        }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: animations, completion: finished)
        } else {
            animations()
            finished(true)
        }
    }

    private func switchToAudioMode() {
        guard currentMode != .audio else { return }
        // Ensure current layout to read text bar height
        self.layoutIfNeeded()
        let startHeight = self.textInputBar.bounds.height

        // Add audio bar with same initial height/position
        if self.audioInputBar.superview == nil {
            bottomView.addSubview(audioInputBar)
            audioBarConstraints = constrainBar(audioInputBar, isAudio: true)
        }
        self.audioBarHeightConstraint?.constant = startHeight
        self.audioInputBar.alpha = 0
        self.layoutIfNeeded()

        // Target height a bit larger (min 52)
        let targetHeight: CGFloat = max(startHeight + 12, 52)
        self.currentMode = .audio
        self.audioInputBar.start()

        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseInOut]) {
            // 1) text alpha -> 0
            self.textInputBar.alpha = 0
            // 2) audio alpha -> 1
            self.audioInputBar.alpha = 1
            // 3) audio height from text height -> target height
            self.audioBarHeightConstraint?.constant = targetHeight
            self.layoutIfNeeded()
        } completion: { _ in
            // Remove text bar to keep view minimal
            self.hideTextBar(animated: false)
        }
    }

    private func switchToTextMode() {
        guard currentMode != .text else { return }
        // Prepare layout info
        self.layoutIfNeeded()

        // Ensure text bar exists (overlay under/over audio)
        if self.textInputBar.superview == nil {
            bottomView.addSubview(textInputBar)
            textBarConstraints = constrainBar(textInputBar, isAudio: false)
        }
        // Start with text invisible
        self.textInputBar.alpha = 0
        self.layoutIfNeeded()

        // Target to shrink audio to text's height
        let targetHeight = self.textInputBar.bounds.height
        self.currentMode = .text

        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseInOut]) {
            // 1) text alpha -> 1
            self.textInputBar.alpha = 1
            // 2) audio alpha -> 0
            self.audioInputBar.alpha = 0
            // 3) audio height -> text height
            self.audioBarHeightConstraint?.constant = targetHeight
            self.layoutIfNeeded()
        } completion: { _ in
            // Cleanup audio bar
            self.audioInputBar.stop()
            NSLayoutConstraint.deactivate(self.audioBarConstraints)
            self.audioBarConstraints.removeAll()
            self.audioInputBar.removeFromSuperview()
        }
    }
}

// ChatInputView no longer needs to conform to UITextViewDelegate;
// the text handling lives inside ChatTextInputBarView.

#Preview {
    ChatView()
}
