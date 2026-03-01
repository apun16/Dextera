import SwiftUI
import AVFoundation

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @AppStorage("soundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("hapticsEnabled") var isHapticsEnabled: Bool = true
    
    func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
