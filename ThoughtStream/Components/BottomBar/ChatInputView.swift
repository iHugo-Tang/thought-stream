import UIKit
import LucideIcons
import SwiftUI

class ChatInputView: UIView {
    // inputTextView
    private var rowHeight : CGFloat = 14
    private var baseHeight: CGFloat = 30
    private var maxHeight: CGFloat = 30
    private let contentView: UIView = UIView()
    private let inputTextView: UITextView
    private let micButton: UIButton
    // bottom view
    private let bottomView = UIView()
    private let bottomBackgroundView: UIView
    // blurredView
    private let blurredView: UIVisualEffectView
    
    // constraints
    var heightConstraint: NSLayoutConstraint?
    
    // color
    private let borderColor = UIColor(Color.thoughtStream.neutral.gray400)
    private let micColor = UIColor(Color.thoughtStream.functional.red500)

    // callbacks
    // update content frame and keyboard frame
    var onBottomViewFrameChanged: ((CGRect) -> Void)?
    
    init(onBottomViewFrameChanged: ((CGRect) -> Void)?) {
        self.inputTextView = UITextView()
        self.micButton = UIButton(type: .system)
        self.micButton.setImage(Lucide.audioLines, for: .normal)
        self.micButton.tintColor = self.micColor
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
        self.setupContentView()
        self.setupBottonView()
        self.addSubview(self.bottomView)
        
        self.micButton.addTarget(self, action: #selector(onMicButotnClicked), for: .touchUpInside)
    }
    
    private func setupContentView() {
        self.inputTextView.textColor = .lightGray
        self.inputTextView.backgroundColor = .clear
        self.inputTextView.text = "Type your thoughts here..."
        self.inputTextView.font = .systemFont(ofSize: 14)
        self.inputTextView.delegate = self

        if let font = self.self.inputTextView.font {
            self.rowHeight = self.self.inputTextView.font!.lineHeight
            let verticalPadding = self.self.inputTextView.textContainerInset.top + self.self.inputTextView.textContainerInset.bottom
            // Height for a single line
            self.baseHeight = font.lineHeight + verticalPadding
            // Max height for 3 lines
            self.maxHeight = (font.lineHeight * 3) + verticalPadding
        }
        
        self.contentView.layer.cornerRadius = floor(self.baseHeight / 2)
        self.contentView.clipsToBounds = true
        self.contentView.layer.borderColor = self.borderColor.cgColor
        self.contentView.layer.borderWidth = 1

        self.contentView.addSubview(self.inputTextView)
        self.contentView.addSubview(self.micButton)
    }
    
    private func setupBottonView() {
        self.bottomBackgroundView.addSubview(self.blurredView)
        self.bottomView.addSubview(self.bottomBackgroundView)
        self.bottomView.addSubview(self.contentView)
    }
    
    private func setupConstraints() {
        self.heightConstraint = self.self.inputTextView.heightAnchor.constraint(equalToConstant: baseHeight)
        
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.inputTextView.translatesAutoresizingMaskIntoConstraints = false
        self.micButton.translatesAutoresizingMaskIntoConstraints = false
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
            self.contentView.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor, constant: 16),
            self.contentView.trailingAnchor.constraint(equalTo: self.bottomView.trailingAnchor, constant: -16),
            self.contentView.topAnchor.constraint(greaterThanOrEqualTo: self.bottomView.topAnchor, constant: 8),
            self.contentView.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            self.inputTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.inputTextView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            self.inputTextView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.heightConstraint!
        ])
        
        NSLayoutConstraint.activate([
            self.micButton.leadingAnchor.constraint(equalTo: self.inputTextView.trailingAnchor),
            self.micButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            self.micButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.micButton.widthAnchor.constraint(equalToConstant: 32),
            self.micButton.heightAnchor.constraint(equalToConstant: 32),
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

extension ChatInputView: UITextViewDelegate {
    func textViewDidBeginEditing (_ textView: UITextView) {
        if self.inputTextView.textColor == .lightGray && self.inputTextView.isFirstResponder {
            self.inputTextView.text = nil
            self.inputTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        if self.inputTextView.text.isEmpty || self.inputTextView.text == "" {
            self.inputTextView.textColor = .lightGray
            self.inputTextView.text = "Type your thoughts here..."
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.contentSize.height)
        self.heightConstraint?.constant = min(textView.contentSize.height, 58)
    }
}

#Preview {
    ChatView()
}
