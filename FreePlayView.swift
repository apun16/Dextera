import SwiftUI
import AVFoundation

struct FreePlay: View {
    @StateObject private var audio  = PianoAudioEngine()
    @StateObject private var camera = HandCameraManager()
    
    @State private var staffNotes: [StaffNote] = []
    @State private var noteCount: Int = 0
    @State private var cameraEnabled = false
    @State private var cameraPressedKey: Int? = nil
    
    private let startX: CGFloat = 0.13
    private let endX: CGFloat   = 0.90
    private let maxNotes: Int   = 8
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                header.padding(.bottom, 14)
                centerCard
                    .padding(.horizontal, 18)
                    .frame(maxHeight: .infinity)
                    .padding(.bottom, 12)
                PianoKeyboardView(
                    cameraPressedKey: cameraPressedKey,
                    onKeyTap: handleKeyTap,
                    audio: audio
                )
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
                BottomNavBar()
            }
            .padding(.top, 52)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .applySavedBrightness()
        .onDisappear { camera.stop() }
        .onChange(of: camera.detectedFingerIndex) { _, idx in
            guard cameraEnabled, let i = idx else { return }
            handleCameraKeyTrigger(index: i)
        }
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Free Play")
                    .scaledText(size: 36, weight: .bold)
                    .foregroundColor(AppColors.primaryPurple)
                Text("Play anything. No rules.")
                    .scaledText(size: 18, weight: .medium)
                    .foregroundColor(AppColors.primaryPurple.opacity(0.55))
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    var centerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.95))
                .shadow(color: AppColors.primaryPurple.opacity(0.10), radius: 20, y: 6)
            
            if cameraEnabled {
                if camera.permissionDenied { permissionDeniedView }
                else { cameraContentView }
            } else {
                staffContentView
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { cameraEnabled.toggle() }
                        if cameraEnabled { camera.requestAndStart() }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cameraEnabled ? "hand.raised.fill" : "hand.raised")
                                .font(.system(size: 14, weight: .bold))
                            Text(cameraEnabled ? "Hand ON" : "Hand Mode")
                                .scaledText(size: 14, weight: .bold)
                        }
                        .foregroundColor(cameraEnabled ? .white : AppColors.accentPurple)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Capsule().fill(cameraEnabled
                                                   ? AppColors.accentPurple
                                                   : AppColors.accentPurple.opacity(0.15)))
                    }
                        .padding(16)
                        .accessibilityElement()
                        .accessibilityLabel(cameraEnabled ? "Hand mode on" : "Enable hand mode")
                        .accessibilityHint("Use the camera to play notes without touching the screen")
                        .accessibilityAddTraits(.isButton)
                }
                Spacer()
            }
        }
    }
    
    var staffContentView: some View {
        GeometryReader { geo in
            let staffTop    = geo.size.height * 0.25
            let staffBottom = geo.size.height * 0.65
            let lineSpacing = (staffBottom - staffTop) / 4.0
            let halfStep    = lineSpacing / 2.0
            
            let clefCentreX: CGFloat  = 26.0
            let noteAreaLeft: CGFloat = 52.0
            let noteAreaRight = geo.size.width - 20.0
            
            ZStack {
                ForEach(0..<5, id: \.self) { i in
                    Rectangle()
                        .fill(AppColors.primaryPurple.opacity(0.30))
                        .frame(width: geo.size.width - 16, height: 1.5)
                        .position(x: geo.size.width / 2,
                                  y: staffTop + CGFloat(i) * lineSpacing)
                }
                Text(" 𝄞")
                    .font(.system(size: lineSpacing * 3.25))
                    .foregroundColor(AppColors.primaryPurple.opacity(0.55))
                    .position(x: clefCentreX, y: staffTop + lineSpacing * 2.0)                
                ForEach(staffNotes) { sNote in
                    let color = PianoNote.keyColors[sNote.noteIndex]
                    let yPos  = staffNoteY(index: sNote.noteIndex,
                                          staffBottom: staffBottom,
                                          halfStep: halfStep)
                    let xPos  = noteAreaLeft + sNote.xFraction * (noteAreaRight - noteAreaLeft)
                    
                    SmallStaffNoteView(
                        noteIndex: sNote.noteIndex,
                        color: color,
                        halfStep: halfStep
                    )
                    .position(x: xPos, y: yPos)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    var cameraContentView: some View {
        ZStack {
            if camera.cameraAvailable {
                CameraPreviewRepresentable(session: camera.session)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                VStack(spacing: 14) {
                    ProgressView().scaleEffect(1.4).tint(AppColors.accentPurple)
                    Text("Starting camera…")
                        .scaledText(size: 15, weight: .medium)
                        .foregroundColor(AppColors.primaryPurple.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            VStack {
                cameraInstructionsCard
                Spacer()
            }
        }
    }
    
    var cameraInstructionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Circle()
                    .fill(camera.handDetected ? Color.green : Color.orange)
                    .frame(width: 10, height: 10)
                Text(camera.handDetected ? "Ready" : "Position your hands")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Right Hand — thumb: C, index: D, middle: E, pinky: F")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                Text("Left Hand — thumb: G, index: A, middle: B, pinky: C")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                Text("Point a finger toward the camera to play")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }
    
    var permissionDeniedView: some View {
        VStack(spacing: 14) {
            Image(systemName: "camera.fill.badge.ellipsis")
                .font(.system(size: 40))
                .foregroundColor(AppColors.accentPurple.opacity(0.5))
            Text("Camera access needed")
                .scaledText(size: 17, weight: .bold)
                .foregroundColor(AppColors.primaryPurple)
            Text("Go to Settings → Privacy → Camera\nand enable access for this app.")
                .scaledText(size: 13, weight: .medium)
                .foregroundColor(AppColors.primaryPurple.opacity(0.55))
                .multilineTextAlignment(.center)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .scaledText(size: 14, weight: .semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 22).padding(.vertical, 10)
            .background(AppColors.accentPurple, in: Capsule())
            .accessibilityLabel("Open Settings")
            .accessibilityHint("Opens the Settings app so you can enable camera access for Dextera")
            .accessibilityAddTraits(.isButton)
        }
        .padding(24)
    }
    
    func handleKeyTap(index: Int) {
        guard index < PianoNote.keys.count else { return }
        addStaffNote(index: index)
    }
    
    func handleCameraKeyTrigger(index: Int) {
        guard index < PianoNote.keys.count else { return }
        withAnimation(.easeOut(duration: 0.08)) { cameraPressedKey = index }
        audio.playNote(PianoNote.keys[index])
        SoundManager.shared.playHaptic(.medium)
        addStaffNote(index: index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.15)) { cameraPressedKey = nil }
        }
    }
    
    private func addStaffNote(index: Int) {
        if noteCount >= maxNotes {
            staffNotes.removeAll()
            noteCount = 0
        }
        let spacing = (endX - startX) / CGFloat(maxNotes - 1)
        let xPos    = startX + CGFloat(noteCount) * spacing
        staffNotes.append(StaffNote(noteIndex: index, xFraction: xPos))
        noteCount += 1
    }
}

struct FreePlay_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { FreePlay() }
    }
}
