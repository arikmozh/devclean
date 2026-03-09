import CoreHaptics
import UIKit

@Observable
final class HapticService {
    private var engine: CHHapticEngine?

    init() {
        prepareEngine()
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            try engine?.start()
        } catch {
            print("Haptic engine error: \(error)")
        }
    }

    // MARK: - Simple Haptics

    func lightTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func mediumTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func heavyTap() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func selectionChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: - Custom Patterns

    func cancelSmash() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine else {
            heavyTap()
            return
        }

        do {
            var events: [CHHapticEvent] = []

            // Initial heavy impact
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            ))

            // Shatter fragments - rapid lighter taps
            for i in 1...6 {
                let intensity = Float(1.0) - Float(i) * 0.12
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                    ],
                    relativeTime: TimeInterval(i) * 0.05
                ))
            }

            // Final rumble
            events.append(CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.35,
                duration: 0.3
            ))

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            heavyTap()
        }
    }

    func drip() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine else {
            lightTap()
            return
        }

        do {
            let events = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                    ],
                    relativeTime: 0
                )
            ]

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            lightTap()
        }
    }

    func celebration() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine else {
            success()
            return
        }

        do {
            var events: [CHHapticEvent] = []

            for i in 0..<8 {
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: Float.random(in: 0.4...1.0)),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: Float.random(in: 0.3...0.8))
                    ],
                    relativeTime: TimeInterval(i) * 0.08
                ))
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            success()
        }
    }
}
