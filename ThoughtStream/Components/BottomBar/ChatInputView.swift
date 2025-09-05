import UIKit
import LucideIcons
import SwiftUI

class ChatInputView: UIView {
    // input bar view (encapsulated)
    private let textInputBar = ChatTextInputBarView()
    // bottom view
    private let bottomView = UIView()
    private let bottomBackgroundView: UIView
    // blurredView
    private let blurredView: UIVisualEffectView
    // voiceContentView
    private let voiceContentView: UIView = UIView()
    private let voiceBackgroundView: UIView = UIView()
    private let voiceWaveView: UIView = UIView()
    private let voiceTimeLabel: UILabel = UILabel()
    private let voiceStopButton: UIButton = UIButton(type: .custom)
    private let voiceCancelButton: UIButton = UIButton(type: .custom)
    
    // constraints (none for text view here; managed by ChatTextInputBarView)

    // callbacks
    // update content frame and keyboard frame
    var onBottomViewFrameChanged: ((CGRect) -> Void)?
    
    init(onBottomViewFrameChanged: ((CGRect) -> Void)?) {
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
            self?.onMicButotnClicked(sender: UIButton(type: .system))
        }
    }
    
    private func setupBottonView() {
        self.bottomBackgroundView.addSubview(self.blurredView)
        self.bottomView.addSubview(self.bottomBackgroundView)
        self.bottomView.addSubview(self.textInputBar)
    }
    
    private func setupConstraints() {
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.textInputBar.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            self.textInputBar.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor, constant: 16),
            self.textInputBar.trailingAnchor.constraint(equalTo: self.bottomView.trailingAnchor, constant: -16),
            self.textInputBar.topAnchor.constraint(greaterThanOrEqualTo: self.bottomView.topAnchor, constant: 8),
            self.textInputBar.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor, constant: -8)
        ])
        
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
}

// ChatInputView no longer needs to conform to UITextViewDelegate;
// the text handling lives inside ChatTextInputBarView.

#Preview {
    ChatView()
}
