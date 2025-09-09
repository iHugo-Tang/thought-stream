import UIKit
import SwiftUI
import LucideIcons
import Combine

class ChatTextInputBarView: UIView {
    // UI
    private let containerView: UIView = UIView()
    private let textView: UITextView = UITextView()
    private let micButton: UIButton = UIButton(type: .system)

    // Layout
    private var textViewHeightConstraint: NSLayoutConstraint?

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

        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(micButton)
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false

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

        NSLayoutConstraint.activate([
            micButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor),
            micButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            micButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 32),
            micButton.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    @objc private func micTapped() {
        onMicTapped?()
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

