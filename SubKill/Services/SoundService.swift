import AVFoundation

@Observable
final class SoundService {
    private var players: [String: AVAudioPlayer] = [:]
    var isSoundEnabled: Bool = true

    // System sounds for now — custom sounds can be added to Resources/Sounds/
    func playSmash() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1521) // Heavy vibrate + click
    }

    func playDing() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1057) // Subtle ding
    }

    func playSuccess() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1025) // Success tone
    }

    func playDrip() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Subtle water-like
    }

    // For custom sound files in the bundle
    func play(_ filename: String, extension ext: String = "wav") {
        guard isSoundEnabled else { return }
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.5
            player.play()
            players[filename] = player
        } catch {
            print("Sound playback error: \(error)")
        }
    }
}
