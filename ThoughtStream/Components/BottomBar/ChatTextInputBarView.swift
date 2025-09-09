import UIKit
import SwiftUI
import LucideIcons
import Combine

class ChatTextInputBarView: UIView {
    // UI
    private let containerView: UIView = UIView()
    private let textView: UITextView = UITextView()
    private let micButton: UIButton = UIButton(type: .system)
    private let sendButton: ChatSendButton = ChatSendButton()

    // Layout
    private var textViewHeightConstraint: NSLayoutConstraint?
    private var micButtonConstraints: [NSLayoutConstraint] = []
    private var sendButtonConstraints: [NSLayoutConstraint] = []

    // Styling
    private let borderColor = UIColor(Color.thoughtStream.neutral.gray400)
    private let micColor = UIColor(Color.thoughtStream.functional.red500)

    // Height config
    private var baseHeight: CGFloat = 30
    private var maxHeight: CGFloat = 58 // matches previous hard limit used

    // ViewModel binding
    private weak var chatViewModel: ChatViewModel?
    private var cancellables = Set<AnyCancellable>()

    // Callbacks
    var onMicTapped: (() -> Void)?
    var onSendTapped: (() -> Void)?
    var onTextHeightChanged: ((CGFloat) -> Void)?

    init(chatViewModel: ChatViewModel? = nil) {
        self.chatViewModel = chatViewModel
        super.init(frame: .zero)
        setup()
        setupViewModelBinding()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupViewModelBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupViewModelBinding()
    }

    private func setup() {
        setupUI()
        setupConstraints()
    }

    private func setupViewModelBinding() {
        // Bind ViewModel's inputText to textView
        chatViewModel?.$inputText
            .sink { [weak self] newText in
                guard let self = self else { return }
                // Only update textView if the text is different and we're not currently editing
                if self.textView.text != newText && !self.textView.isFirstResponder {
                    self.textView.text = newText.isEmpty ? "" : newText
                    // Update text color based on content
                    self.textView.textColor = newText.isEmpty ? .lightGray : .black
                }
                // Update button visibility based on input text
                self.updateButtonVisibility(hasText: !newText.isEmpty)
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        // Container styling
        containerView.layer.cornerRadius = 15
        containerView.clipsToBounds = true
        containerView.layer.borderColor = borderColor.cgColor
        containerView.layer.borderWidth = 1
        
        // Text view
        textView.textColor = .lightGray
        textView.backgroundColor = .clear
        textView.text = "Type your thoughts here..."
        textView.font = .systemFont(ofSize: 14)
        textView.delegate = self
        
        if let font = textView.font {
            let verticalPadding = textView.textContainerInset.top + textView.textContainerInset.bottom
            baseHeight = font.lineHeight + verticalPadding
        }
        
        // Mic button
        micButton.setImage(Lucide.audioLines, for: .normal)
        micButton.tintColor = micColor
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
        
        // send button setup
        sendButton.onSendTapped = { [weak self] in
            self?.onSendTapped?()
        }

        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(micButton)
        containerView.addSubview(sendButton)
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: baseHeight)

        NSLayoutConstraint.activate([
            // Container fills self with horizontal padding managed by superview
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textViewHeightConstraint!
        ])

        // Create constraints but don't activate them yet
        micButtonConstraints = [
            micButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor),
            micButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            micButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 32),
            micButton.heightAnchor.constraint(equalToConstant: 32),
        ]

        sendButtonConstraints = [
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor),
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
        ]

        // Initially show mic button if no text
        updateButtonVisibility(hasText: false)
    }

    private func updateButtonVisibility(hasText: Bool) {
        if hasText {
            // Show send button, hide mic button
            sendButton.isHidden = false
            micButton.isHidden = true
            installConstraints(for: sendButtonConstraints)
            uninstallConstraints(for: micButtonConstraints)
        } else {
            // Show mic button, hide send button
            micButton.isHidden = false
            sendButton.isHidden = true
            installConstraints(for: micButtonConstraints)
            uninstallConstraints(for: sendButtonConstraints)
        }
    }

    private func installConstraints(for constraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.activate(constraints)
    }

    private func uninstallConstraints(for constraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.deactivate(constraints)
    }

    @objc private func micTapped() {
        onMicTapped?()
    }

    @objc private func sendTapped() {
        onSendTapped?()
    }
}

extension ChatTextInputBarView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray && textView.isFirstResponder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.textColor = .lightGray
            textView.text = "Type your thoughts here..."
        }
        // Sync final text to ViewModel when editing ends
        syncTextToViewModel(textView.text)
    }

    func textViewDidChange(_ textView: UITextView) {
        let newHeight = min(textView.contentSize.height, maxHeight)
        textViewHeightConstraint?.constant = newHeight
        onTextHeightChanged?(newHeight)

        // Sync text changes to ViewModel in real-time
        syncTextToViewModel(textView.text)
    }

    private func syncTextToViewModel(_ text: String) {
        let actualText = (text == "Type your thoughts here..." || textView.textColor == .lightGray) ? "" : text
        if chatViewModel?.inputText != actualText {
            chatViewModel?.inputText = actualText
        }
    }
}

#Preview {
    ChatView()
}

