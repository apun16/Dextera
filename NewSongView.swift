import SwiftUI
import AVFoundation

struct PlaySong: View {
    @StateObject private var audio = PianoAudioEngine()
    @StateObject private var database = PracticeDatabaseManager.shared
    
    @State private var currentSongIndex: Int? = nil
    @State private var guidedStep: Int = 0
    @State private var isPlaying = false
    @State private var showSongDropdown = false
    @State private var highlightedKey: Int? = nil
    @State private var showCompletion = false    
    @State private var sessionStartTime: Date?
    @State private var correctTaps: Int = 0
    @State private var wrongTaps: Int = 0
    
    let songs: [GuidedSong] = GuidedSong.allSongs
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                PlaySongHeader(
                    currentSong: currentSongIndex.map { songs[$0] },
                    isPlaying: isPlaying,
                    showCompletion: showCompletion
                )
                
                SongSelectorCard(
                    songs: songs,
                    currentIndex: currentSongIndex,
                    isExpanded: $showSongDropdown,
                    onSelect: { index in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            resetSession()
                            currentSongIndex = index
                            guidedStep = 0
                            isPlaying = false
                            highlightedKey = nil
                            showCompletion = false
                            showSongDropdown = false
                        }
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .zIndex(1)
                
                if let idx = currentSongIndex {
                    SongProgressView(
                        song: songs[idx],
                        guidedStep: guidedStep,
                        isPlaying: isPlaying,
                        highlightedKey: highlightedKey,
                        showCompletion: showCompletion,
                        onStart: { startGuidedSong(songs[idx]) },
                        onStop: { stopGuidedSong(completed: false) },
                        onCompletionDismiss: {
                            withAnimation(.easeInOut(duration: 0.3)) { 
                                showCompletion = false 
                                resetSession()
                            }
                        }
                    )
                    .padding(.top, 20)
                } else {
                    EmptySongState().padding(.top, 40)
                }
                
                Spacer()
                
                PianoKeyboardView(
                    highlightedKey: highlightedKey,
                    onKeyTap: handleKeyTap,
                    audio: audio
                )
                .padding(.bottom, 8)
                
                BottomNavBar()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .applySavedBrightness()
    }
    
    private func resetSession() {
        sessionStartTime = nil
        correctTaps = 0
        wrongTaps = 0
    }
    
    private func logSession(song: GuidedSong, completed: Bool) {
        guard let startTime = sessionStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        let totalNotes = song.sequence.count
        let finalCorrectTaps = completed ? totalNotes : correctTaps
        
        let session = PracticeSession(
            date: Date(),
            songId: song.id.uuidString,
            songTitle: song.title,
            songEmoji: song.emoji,
            totalNotes: totalNotes,
            correctNotes: finalCorrectTaps,
            wrongNotes: wrongTaps,
            duration: duration
        )
        
        database.addSession(session)
    }
    
    func handleKeyTap(index: Int) {
        guard isPlaying, let idx = currentSongIndex else { return }
        let song = songs[idx]
        guard guidedStep < song.sequence.count else { return }
        
        let expected = song.sequence[guidedStep].noteIndex
        
        if index == expected {
            correctTaps += 1
            let nextStep = guidedStep + 1
            
            if nextStep >= song.sequence.count {
                logSession(song: song, completed: true)
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPlaying = false
                    highlightedKey = nil
                    guidedStep = nextStep
                    showCompletion = true
                    sessionStartTime = nil 
                }
            } else {
                guidedStep = nextStep
                highlightedKey = song.sequence[nextStep].noteIndex
            }
        } else {
            wrongTaps += 1
        }
    }
    
    func startGuidedSong(_ song: GuidedSong) {
        withAnimation(.easeInOut(duration: 0.2)) {
            sessionStartTime = Date()
            correctTaps = 0
            wrongTaps = 0
            
            showCompletion = false
            guidedStep = 0
            isPlaying = true
            highlightedKey = song.sequence.first?.noteIndex
        }
    }
    
    func stopGuidedSong(completed: Bool = false) {
        if let idx = currentSongIndex, !completed {
            let song = songs[idx]
            logSession(song: song, completed: false)
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            isPlaying = false
            highlightedKey = nil
            guidedStep = 0
            showCompletion = false
            resetSession()
        }
    }
}

struct SongSelectorCard: View {
    let songs: [GuidedSong]
    let currentIndex: Int?
    @Binding var isExpanded: Bool
    let onSelect: (Int) -> Void
    
    var selectedSong: GuidedSong? { currentIndex.map { songs[$0] } }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            }) {
                HStack(spacing: 14) {
                    Text(selectedSong?.emoji ?? "🎹")
                        .font(.system(size: 36))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedSong?.title ?? "Choose a Song")
                            .scaledText(size: 19, weight: .bold)
                            .foregroundColor(AppColors.textDark)
                        Text(selectedSong?.description ?? "Select a melody to practice")
                            .scaledText(size: 14, weight: .medium)
                            .foregroundColor(AppColors.primaryPurple.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.primaryPurple.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(AppColors.cardBackground)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(selectedSong?.title ?? "Choose a Song")
            .accessibilityHint("Tap to expand the song selector")
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                        .background(AppColors.primaryPurple.opacity(0.08))
                        .padding(.horizontal, 12)
                    
                    ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
                        Button(action: { onSelect(index) }) {
                            HStack(spacing: 12) {
                                Text(song.emoji)
                                    .font(.system(size: 28))
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(song.title)
                                        .scaledText(size: 17, weight: .semibold)
                                        .foregroundColor(currentIndex == index
                                                         ? AppColors.accentPurple
                                                         : AppColors.textDark)
                                    Text(song.description)
                                        .scaledText(size: 13, weight: .medium)
                                        .foregroundColor(AppColors.primaryPurple.opacity(0.5))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                if currentIndex == index {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColors.accentPurple)
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(
                                currentIndex == index
                                ? AppColors.accentPurple.opacity(0.06)
                                : Color.clear
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel(song.title)
                        .accessibilityHint(song.description)
                        
                        if index < songs.count - 1 {
                            Divider()
                                .padding(.leading, 62)
                                .background(AppColors.primaryPurple.opacity(0.06))
                        }
                    }
                }
                .background(AppColors.dropdownBackground)
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

struct PlaySongHeader: View {
    let currentSong: GuidedSong?
    let isPlaying: Bool
    let showCompletion: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Play Song")
                    .scaledText(size: 36, weight: .bold)
                    .foregroundColor(AppColors.primaryPurple)
                
                HStack(spacing: 8) {
                    if showCompletion {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 18))
                        Text("Congratulations!")
                            .scaledText(size: 20, weight: .bold)
                            .foregroundColor(.green)
                    } else if isPlaying {
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Text("Playing")
                            .scaledText(size: 20, weight: .bold)
                            .foregroundColor(.green)
                    } else {
                        Text("Practice mode")
                            .scaledText(size: 20, weight: .semibold)
                            .foregroundColor(AppColors.primaryPurple.opacity(0.5))
                    }
                }
                .frame(height: 24)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 44)
        .padding(.bottom, 12)
        .animation(.easeInOut(duration: 0.2), value: showCompletion)
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }
}

struct SongProgressView: View {
    let song: GuidedSong
    let guidedStep: Int
    let isPlaying: Bool
    let highlightedKey: Int?
    let showCompletion: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    let onCompletionDismiss: () -> Void
    
    var progress: Double {
        guard song.sequence.count > 0 else { return 0 }
        return Double(guidedStep) / Double(song.sequence.count)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.primaryPurple.opacity(0.12))
                            .frame(height: 12)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: showCompletion
                                ? [Color.green, Color.green.opacity(0.8)]
                                : [AppColors.accentPurple, AppColors.primaryPurple],
                                startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 12)
                            .animation(.easeInOut(duration: 0.3), value: guidedStep)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, 20)
                
                HStack {
                    Text(showCompletion ? "Completed!" : "\(guidedStep) of \(song.sequence.count) notes")
                        .scaledText(size: 15, weight: .medium)
                        .foregroundColor(showCompletion ? .green : AppColors.primaryPurple.opacity(0.50))
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .scaledText(size: 15, weight: .bold)
                        .foregroundColor(showCompletion ? .green : AppColors.accentPurple)
                }
                .padding(.horizontal, 20)
            }
            if showCompletion {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill").font(.system(size: 28)).foregroundColor(.yellow)
                        Text("Great Job!")
                            .scaledText(size: 26, weight: .bold)
                            .foregroundColor(AppColors.textDark)
                        Image(systemName: "star.fill").font(.system(size: 28)).foregroundColor(.yellow)
                    }
                    .padding(.vertical, 20)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Saved to Practice History")
                            .font(.caption)
                            .foregroundColor(AppColors.primaryPurple.opacity(0.6))
                    }
                    
                    Button(action: onCompletionDismiss) {
                        Text("Play Again")
                            .scaledText(size: 20, weight: .bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(RoundedRectangle(cornerRadius: 18).fill(AppColors.accentPurple))
                    }
                    .padding(.horizontal, 20)
                    .accessibilityLabel("Play Again")
                    .accessibilityHint("Plays the song again from the start")
                    .accessibilityAddTraits(.isButton)
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: .green.opacity(0.2), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .opacity))
                
            } else {
                Button(action: isPlaying ? onStop : onStart) {
                    HStack(spacing: 14) {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 26, weight: .bold))
                        Text(isPlaying ? "Stop Playing" : "Start Playing")
                            .scaledText(size: 24, weight: .bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isPlaying ? Color.red.opacity(0.9) : AppColors.accentPurple)
                    )
                    .shadow(color: (isPlaying ? Color.red : AppColors.accentPurple).opacity(0.25),
                            radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 20)
                .accessibilityLabel(isPlaying ? "Stop Playing" : "Start Playing")
                .accessibilityHint("Starts or stops the guided practice")
                .accessibilityAddTraits(.isButton)
                
                if isPlaying, let keyIdx = highlightedKey, guidedStep < song.sequence.count {
                    let note  = PianoNote.keys[keyIdx]
                    let color = PianoNote.keyColors[keyIdx]
                    
                    HStack(spacing: 16) {
                        Circle()
                            .fill(color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text(note.displayName.prefix(1))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        Text("Tap \(note.displayName)")
                            .scaledText(size: 24, weight: .bold)
                            .foregroundColor(AppColors.textDark)
                        Image(systemName: "arrow.down")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(color)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.95))
                            .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 3)
                    )
                    .padding(.horizontal, 20)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal:   .move(edge: .bottom).combined(with: .opacity)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showCompletion)
        .animation(.easeInOut(duration: 0.25), value: isPlaying)
    }
}

struct EmptySongState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppColors.primaryPurple.opacity(0.3))
            Text("Select a song above to begin")
                .scaledText(size: 16, weight: .medium)
                .foregroundColor(AppColors.primaryPurple.opacity(0.5))
        }
    }
}
extension AppColors {
    static let cardBackground     = Color.white.opacity(0.95)
    static let dropdownBackground = Color(red: 0.98, green: 0.98, blue: 0.99)
}

struct PlaySong_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { PlaySong() }
    }
}
