import UIKit
import SwiftUI
import LucideIcons
import Combine

// A tiny UITextView subclass to support custom slash-command menu actions
class SlashTextView: UITextView, UIEditMenuInteractionDelegate {
    private var editMenuInteraction: UIEditMenuInteraction?
    var onSlashCommandSelected: ((String) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 16.0, *) {
            if editMenuInteraction == nil {
                let interaction = UIEditMenuInteraction(delegate: self)
                addInteraction(interaction)
                editMenuInteraction = interaction
            }
        }
    }

    // Present the modern edit menu anchored at the caret
    func presentSlashMenu() {
        guard isFirstResponder, let range = selectedTextRange else { return }
        let caret = caretRect(for: range.end)
        if #available(iOS 16.0, *) {
            let point = CGPoint(x: caret.midX, y: caret.minY)
            let config = UIEditMenuConfiguration(identifier: nil, sourcePoint: point)
            editMenuInteraction?.presentEditMenu(with: config)
        } else {
            // Fallback will be handled by caller via UIMenuController
        }
    }

    // Handle the action: directly send the command
    @objc func sendCommand(_ sender: Any?, cmd: String) {
        onSlashCommandSelected?("\(CommandRegistry.slashPrefix)\(cmd)")
    }

    // MARK: - UIEditMenuInteractionDelegate (iOS 16+)
    @available(iOS 16.0, *)
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        // Build actions from centralized command registry using system localization
        let actions: [UIAction] = CommandRegistry.all.map { def in
            let title = def.displayName()
            return UIAction(title: title) { [weak self] _ in
                self?.sendCommand(nil, cmd: title)
            }
        }
        return UIMenu(children: actions)
    }
}

class ChatTextInputBarView: UIView {
    // UI
    private let containerView: UIView = UIView()
    private let textView: SlashTextView = SlashTextView()
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

    // Stream binding
    private var inputTextPublisher: AnyPublisher<String, Never>?
    private var cancellables = Set<AnyCancellable>()

    // Callbacks
    var onMicTapped: (() -> Void)?
    var onSendTapped: ((String, UITextView) -> Void)?
    var onTextHeightChanged: ((CGFloat) -> Void)?
    var onTextDidChange: ((String, UITextView) -> Void)?

    init(
        inputTextPublisher: AnyPublisher<String, Never>? = nil,
        onTextDidChange: ((String, UITextView) -> Void)? = nil,
    ) {
        self.inputTextPublisher = inputTextPublisher
        self.onTextDidChange = onTextDidChange
        super.init(frame: .zero)
        setup()
        setupStreamBinding()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupStreamBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupStreamBinding()
    }

    private func setup() {
        setupUI()
        setupConstraints()
    }

    private func setupStreamBinding() {
        inputTextPublisher?
            .sink { [weak self] newText in
                guard let self = self else { return }
                if self.textView.text != newText && !self.textView.isFirstResponder {
                    self.textView.text = newText.isEmpty ? "" : newText
                    self.textView.textColor = newText.isEmpty ? .lightGray : .black
                }
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
        // Bridge slash command selection to sending callback
        textView.onSlashCommandSelected = { [weak self] command in
            guard let self = self else { return }
            self.onSendTapped?(command, self.textView)
        }
        
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
            guard let self = self else { return }
            let text = self.currentActualText()
            self.onSendTapped?(text, self.textView)
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
        let text = currentActualText()
        onSendTapped?(text, self.textView)
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
        // emit final text
        let actual = currentActualText()
        onTextDidChange?(actual, textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        let newHeight = min(textView.contentSize.height, maxHeight)
        textViewHeightConstraint?.constant = newHeight
        onTextHeightChanged?(newHeight)
        let actual = currentActualText()
        onTextDidChange?(actual, textView)
        updateButtonVisibility(hasText: !actual.isEmpty)
    }

    private func currentActualText() -> String {
        let text = textView.text ?? ""
        let actual = (text == "Type your thoughts here..." || textView.textColor == .lightGray) ? "" : text
        return actual
    }
}

#Preview {
    ChatView()
}
