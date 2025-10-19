import Foundation
import UIKit
import CoreHaptics

public final class HapticsService {
    public static let shared = HapticsService()

    private let supportsHaptics: Bool
    private var engine: CHHapticEngine?
    private var isEngineStarted: Bool = false

    private init() {
        self.supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportsHaptics else { return }
        do {
            let engine = try CHHapticEngine()
            self.engine = engine

            engine.stoppedHandler = { [weak self] _ in
                self?.isEngineStarted = false
            }

            engine.resetHandler = { [weak self] in
                guard let self else { return }
                self.isEngineStarted = false
                do {
                    try self.engine?.start()
                    self.isEngineStarted = true
                } catch {
                    // fallback handled per play call
                }
            }
        } catch {
            self.engine = nil
        }
    }

    private func startEngineIfNeeded() throws {
        guard supportsHaptics else { return }
        if !isEngineStarted {
            try engine?.start()
            isEngineStarted = true
        }
    }

    public func playContinuous(duration: TimeInterval, intensity: Float = 1.0, sharpness: Float = 0.5) {
        guard supportsHaptics, let engine else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            return
        }

        do {
            try startEngineIfNeeded()

            let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
            let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityParam, sharpnessParam], relativeTime: 0, duration: duration)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            // Keep engine running to avoid frequent session teardown
        } catch {
            // Attempt a soft restart once, then fallback
            do {
                try engine.start()
                isEngineStarted = true
            } catch { }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    public func stopEngine() {
        guard supportsHaptics else { return }
        engine?.stop(completionHandler: { _ in })
        isEngineStarted = false
    }
}


