import UIKit
import SwiftUI
import LucideIcons

class ChatSendButton: UIView {
    private let button: UIButton = UIButton(type: .system)
    private let backgroundView: UIView = UIView()

    var onSendTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        // Button configuration
        button.setImage(Lucide.arrowUp, for: .normal)
        button.tintColor = UIColor(Color.thoughtStream.white)
        button.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        // Background view configuration
        backgroundView.backgroundColor = UIColor(Color.thoughtStream.theme.green600)
        backgroundView.layer.cornerRadius = 12
        backgroundView.layer.masksToBounds = true
        backgroundView.isUserInteractionEnabled = false

        // Add background view below button's image
        button.insertSubview(backgroundView, belowSubview: button.imageView!)

        addSubview(button)
    }

    private func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Button fills the view
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Background view constraints (inset from button edges)
            backgroundView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 4),
            backgroundView.topAnchor.constraint(equalTo: button.topAnchor, constant: 4),
        ])
    }

    @objc private func sendTapped() {
        onSendTapped?()
    }

    // MARK: - Public Methods

    func setHidden(_ hidden: Bool) {
        self.isHidden = hidden
    }

    func setEnabled(_ enabled: Bool) {
        button.isEnabled = enabled
        backgroundView.alpha = enabled ? 1.0 : 0.5
    }
}
