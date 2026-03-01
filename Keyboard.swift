import SwiftUI
import AVFoundation

class PianoAudioEngine: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var mixer = AVAudioMixerNode()

    init() { setupEngine() }

    private func setupEngine() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setPreferredIOBufferDuration(0.003)
        try? session.setActive(true)
        audioEngine.attach(mixer)
        audioEngine.connect(mixer, to: audioEngine.mainMixerNode, format: nil)
        try? audioEngine.start()
    }

    func playNote(_ note: PianoNote) {
        guard SoundManager.shared.isSoundEnabled else { return }

        let sampleRate = 44100.0
        let duration   = 1.2
        let frequency  = note.frequency
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!,
            frameCapacity: frameCount
        ) else { return }
        buffer.frameLength = frameCount
        let data = buffer.floatChannelData![0]
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let wave = sin(2 * .pi * frequency * t)
            + 0.5  * sin(2 * .pi * frequency * 2 * t)
            + 0.25 * sin(2 * .pi * frequency * 3 * t)
            + 0.12 * sin(2 * .pi * frequency * 4 * t)
            + 0.06 * sin(2 * .pi * frequency * 5 * t)
            let envelope = min(t / 0.003, 1.0) * (t < 0.1 ? 1.0 : exp(-(t - 0.1) * 3.0))
            data[frame] = Float(wave * envelope * 0.18)
        }
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)
        audioEngine.connect(player, to: mixer, format: buffer.format)
        player.scheduleBuffer(buffer) {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
                self.audioEngine.detach(player)
            }
        }
        player.play()
    }
}

struct PianoNote: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let frequency: Double
    let isBlack: Bool
    let displayName: String

    static let keys: [PianoNote] = [
        PianoNote(name: "C4", frequency: 261.63, isBlack: false, displayName: "C"),
        PianoNote(name: "D4", frequency: 293.66, isBlack: false, displayName: "D"),
        PianoNote(name: "E4", frequency: 329.63, isBlack: false, displayName: "E"),
        PianoNote(name: "F4", frequency: 349.23, isBlack: false, displayName: "F"),
        PianoNote(name: "G4", frequency: 392.00, isBlack: false, displayName: "G"),
        PianoNote(name: "A4", frequency: 440.00, isBlack: false, displayName: "A"),
        PianoNote(name: "B4", frequency: 493.88, isBlack: false, displayName: "B"),
        PianoNote(name: "C5", frequency: 523.25, isBlack: false, displayName: "C"),
    ]

    static let keyColors: [Color] = [
        Color(red: 0.98, green: 0.36, blue: 0.36),
        Color(red: 0.98, green: 0.60, blue: 0.20),
        Color(red: 0.85, green: 0.76, blue: 0.10),
        Color(red: 0.30, green: 0.78, blue: 0.40),
        Color(red: 0.25, green: 0.65, blue: 0.95),
        Color(red: 0.45, green: 0.35, blue: 0.90),
        Color(red: 0.80, green: 0.35, blue: 0.90),
        Color(red: 0.98, green: 0.36, blue: 0.36),
    ]
}

struct PianoKeyboardView: View {
    var highlightedKey: Int? = nil
    var cameraPressedKey: Int? = nil
    var onKeyTap: (Int) -> Void = { _ in }
    @ObservedObject var audio: PianoAudioEngine

    var body: some View {
        GeometryReader { geo in
            let count = PianoNote.keys.count
            let spacing: CGFloat = 4
            let keyW = (geo.size.width - 32 - spacing * CGFloat(count - 1)) / CGFloat(count)
            let keyH = min(keyW * 5.2, 260.0)

            HStack(spacing: spacing) {
                ForEach(Array(PianoNote.keys.enumerated()), id: \.offset) { index, note in
                    PianoKey(
                        note: note,
                        color: PianoNote.keyColors[index],
                        isHighlighted: highlightedKey == index,
                        isCameraPressed: cameraPressedKey == index,
                        width: keyW,
                        height: keyH
                    ) {
                        onKeyTap(index)
                        audio.playNote(note)
                        SoundManager.shared.playHaptic(.medium)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .frame(height: 280)
    }
}

private struct PianoKey: View {
    let note: PianoNote
    let color: Color
    let isHighlighted: Bool
    let isCameraPressed: Bool
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    @State private var touchDown = false

    private var isPressed: Bool { touchDown || isCameraPressed }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13)
                .fill(backgroundFill)

            RoundedRectangle(cornerRadius: 13)
                .strokeBorder(borderColor, lineWidth: isHighlighted ? 3 : 1.5)

            if isPressed {
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color.black.opacity(0.07))
            }

            Text(note.displayName)
                .font(.system(size: min(width * 0.50, 28), weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(width: width, height: height)
        .shadow(
            color: isPressed ? Color.black.opacity(0.18) : color.opacity(isHighlighted ? 0.35 : 0.15),
            radius: isPressed ? 1 : (isHighlighted ? 8 : 4),
            y: isPressed ? 1 : 4
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeOut(duration: 0.08), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !touchDown {
                        touchDown = true
                        action()
                    }
                }
                .onEnded { _ in
                    touchDown = false
                }
        )
        .accessibilityElement()
        .accessibilityLabel("\(note.displayName)")
        .accessibilityAddTraits(.isButton)
    }

    private var backgroundFill: Color {
        isHighlighted ? color.opacity(0.18) : .white
    }

    private var borderColor: Color {
        isHighlighted ? color : color.opacity(0.30)
    }
}
