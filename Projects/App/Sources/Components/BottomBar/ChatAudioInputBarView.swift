import UIKit
import SwiftUI

class ChatAudioInputBarView: UIView {
    // Container hierarchy
    private let voiceContentView: UIView = UIView()
    private let voiceWaveView: AudioDashWaveView = AudioDashWaveView()
    private let voiceTimeLabel: UILabel = UILabel()
    private let voiceStopButton: UIButton = UIButton(type: .custom)
    private let voiceCancelButton: UIButton = UIButton(type: .system)

    // Styling
    private let borderColor = UIColor(Color.thoughtStream.neutral.gray300)
    private let accentColor = UIColor(Color.thoughtStream.functional.red500)

    // Timer
    private var timer: Timer?
    private var elapsed: Int = 0

    // Callbacks
    var onStopTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onTick: ((Int) -> Void)?

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
        updateTimeLabel()
    }

    private func setupUI() {
        // Style self as rounded capsule (light mode)
//        layer.cornerRadius = 26
        clipsToBounds = true
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = 1
        backgroundColor = UIColor(Color.thoughtStream.functional.red500.opacity(0.3))

        // Wave view (dashed red line)
        voiceWaveView.tintColor = accentColor

        // Time label
        voiceTimeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        voiceTimeLabel.textColor = accentColor
        voiceTimeLabel.textAlignment = .right

        // Stop button (red circle with white square)
        voiceStopButton.backgroundColor = accentColor
        voiceStopButton.layer.cornerRadius = 22
        voiceStopButton.clipsToBounds = true
        voiceStopButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        voiceStopButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        // inner square indicator
        let stopSquare = UIView()
        stopSquare.backgroundColor = .white
        stopSquare.layer.cornerRadius = 2
        stopSquare.translatesAutoresizingMaskIntoConstraints = false
        stopSquare.isUserInteractionEnabled = false
        voiceStopButton.addSubview(stopSquare)
        NSLayoutConstraint.activate([
            stopSquare.centerXAnchor.constraint(equalTo: voiceStopButton.centerXAnchor),
            stopSquare.centerYAnchor.constraint(equalTo: voiceStopButton.centerYAnchor),
            stopSquare.widthAnchor.constraint(equalToConstant: 12),
            stopSquare.heightAnchor.constraint(equalToConstant: 12)
        ])
        voiceStopButton.addTarget(self, action: #selector(handleStopTapped), for: .touchUpInside)

        // Cancel button (light mode subtle)
        voiceCancelButton.setTitle("Cancel", for: .normal)
        voiceCancelButton.setTitleColor(UIColor(Color.thoughtStream.neutral.gray600), for: .normal)
        voiceCancelButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        voiceCancelButton.addTarget(self, action: #selector(handleCancelTapped), for: .touchUpInside)

        addSubview(voiceContentView)
        voiceContentView.addSubview(voiceWaveView)
        voiceContentView.addSubview(voiceTimeLabel)
        voiceContentView.addSubview(voiceStopButton)
        voiceContentView.addSubview(voiceCancelButton)
    }

    private func setupConstraints() {
        voiceContentView.translatesAutoresizingMaskIntoConstraints = false
        voiceWaveView.translatesAutoresizingMaskIntoConstraints = false
        voiceTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceStopButton.translatesAutoresizingMaskIntoConstraints = false
        voiceCancelButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            voiceContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            voiceContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            voiceContentView.topAnchor.constraint(equalTo: topAnchor),
            voiceContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Buttons and label
        NSLayoutConstraint.activate([
            voiceStopButton.trailingAnchor.constraint(equalTo: voiceContentView.trailingAnchor, constant: -8),
            voiceStopButton.centerYAnchor.constraint(equalTo: voiceContentView.centerYAnchor),

            voiceTimeLabel.centerYAnchor.constraint(equalTo: voiceContentView.centerYAnchor),
            voiceTimeLabel.trailingAnchor.constraint(equalTo: voiceStopButton.leadingAnchor, constant: -12),
        ])

        NSLayoutConstraint.activate([
            voiceCancelButton.leadingAnchor.constraint(equalTo: voiceContentView.leadingAnchor, constant: 12),
            voiceCancelButton.centerYAnchor.constraint(equalTo: voiceContentView.centerYAnchor)
        ])

        // Wave between cancel and time label
        NSLayoutConstraint.activate([
            voiceWaveView.leadingAnchor.constraint(equalTo: voiceCancelButton.trailingAnchor, constant: 12),
            voiceWaveView.trailingAnchor.constraint(equalTo: voiceTimeLabel.leadingAnchor, constant: -12),
            voiceWaveView.centerYAnchor.constraint(equalTo: voiceContentView.centerYAnchor),
            voiceWaveView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    // MARK: - Actions
    @objc private func handleStopTapped() {
        stop()
        onStopTapped?()
    }

    @objc private func handleCancelTapped() {
        reset()
        onCancelTapped?()
    }

    // MARK: - Public API
    func start() {
        guard timer == nil else { return }
        elapsed = 0
        updateTimeLabel()
        let t = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsed += 1
            self.updateTimeLabel()
            self.onTick?(self.elapsed)
        }
        timer = t
        RunLoop.main.add(t, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        stop()
        elapsed = 0
        updateTimeLabel()
        voiceWaveView.progress = 0
    }

    // Allow external level/progress update (0...1)
    func updateLevel(_ level: CGFloat) {
        // Map incoming level to a progress value for dashed wave highlight
        let clamped = max(0, min(1, level))
        voiceWaveView.progress = clamped
    }

    private func updateTimeLabel() {
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        voiceTimeLabel.text = String(format: "%d:%02d", minutes, seconds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = floor(bounds.height / 2)
    }
}

// MARK: - Dashed wave line view
private class AudioDashWaveView: UIView {
    // Represents how much of the dashes should be highlighted (0...1)
    var progress: CGFloat = 0.0 { didSet { setNeedsLayout() } }
    override var tintColor: UIColor! { didSet { shapeLayer.strokeColor = tintColor.cgColor } }

    private let shapeLayer = CAShapeLayer()
    private let highlightLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        layer.addSublayer(shapeLayer)
        layer.addSublayer(highlightLayer)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineCap = .round
        shapeLayer.lineDashPattern = [2, 3]
        shapeLayer.strokeColor = tintColor?.withAlphaComponent(0.3).cgColor

        highlightLayer.fillColor = UIColor.clear.cgColor
        highlightLayer.lineWidth = 2
        highlightLayer.lineCap = .round
        highlightLayer.lineDashPattern = [2, 3]
        highlightLayer.strokeColor = tintColor?.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        let midY = bounds.midY
        let startX: CGFloat = 0
        let endX: CGFloat = bounds.width
        path.move(to: CGPoint(x: startX, y: midY))
        path.addLine(to: CGPoint(x: endX, y: midY))

        shapeLayer.frame = bounds
        shapeLayer.path = path.cgPath

        // Highlight portion path based on progress
        let highlightPath = UIBezierPath()
        let highlightEndX = startX + (endX - startX) * max(0, min(1, progress))
        highlightPath.move(to: CGPoint(x: startX, y: midY))
        highlightPath.addLine(to: CGPoint(x: highlightEndX, y: midY))
        highlightLayer.frame = bounds
        highlightLayer.path = highlightPath.cgPath
    }
}

#Preview {
    ChatView()
}
