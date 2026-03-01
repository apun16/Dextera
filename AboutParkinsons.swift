import SwiftUI

struct AboutParkinsons: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    panels
                    researchSection
                    howDexteraHelps
                    tryDexteraStrip
                    disclaimer
                    Spacer(minLength: 90)
                }
                .padding(.horizontal, 26)
                .padding(.top, 48)
            }
            
            VStack {
                Spacer()
                BottomNavBar()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .applySavedBrightness()
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About Parkinson's")
                .scaledText(size: 42, weight: .bold)
                .foregroundColor(AppColors.primaryPurple)
         
            Text("Understanding bradykinesia, and the role music can play.")
                .scaledText(size: 16, weight: .medium)
                .foregroundColor(AppColors.primaryPurple.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var panels: some View {
        Group {
            if sizeClass == .regular {
                HStack(alignment: .top, spacing: 20) {
                    bradykinesiaPanel
                    musicPanel
                }
            } else {
                VStack(spacing: 20) {
                    bradykinesiaPanel
                    musicPanel
                }
            }
        }
    }
    
    private var bradykinesiaPanel: some View {
        ContentPanel(title: "What is bradykinesia?") {
            VStack(alignment: .leading, spacing: 16) {
                Text("Bradykinesia is the slowness of movement that makes everyday actions like buttoning a shirt or lifting your hands, feel harder and slower. It is one of the most common motor symptoms of Parkinson's disease.")
                    .scaledText(size: 15, weight: .regular)
                    .foregroundColor(AppColors.textDark.opacity(0.80))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                
                Divider()
                    .background(AppColors.primaryPurple.opacity(0.12))
                
                StatRow(
                    value: "7–10 million",
                    label: "people worldwide live with Parkinson's disease"
                )
                
                StatRow(
                    value: "~80%",
                    label: "of individuals with Parkinson's experience bradykinesia"
                )
            }
        }
    }
    
    private var musicPanel: some View {
        ContentPanel(title: "Why does music matter?") {
            VStack(alignment: .leading, spacing: 16) {
                Text("For many people with Parkinson's, music offers something medication alone cannot which is a sense of rhythm that the body can follow. Research suggests that musical engagement can ease symptoms and support both physical and emotional wellbeing.")
                    .scaledText(size: 15, weight: .regular)
                    .foregroundColor(AppColors.textDark.opacity(0.80))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                
                Divider()
                    .background(AppColors.primaryPurple.opacity(0.12))
                
                VStack(alignment: .leading, spacing: 12) {
                    BulletPoint("Improvements in motor function, gait, and speech")
                    BulletPoint("Reduced anxiety and improved mood")
                    BulletPoint("A calming, motivating form of gentle hand exercise")
                }
            }
        }
    }

    private var researchSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("What the research shows")
                .scaledText(size: 22, weight: .bold)
                .foregroundColor(AppColors.primaryPurple)
            
            Text("The Parkinson's Foundation notes that music therapy can reduce bradykinesia and other symptoms of Parkinson's disease. At University College London, researchers recorded participants' tremors and transformed them into personalized songs and explored how music rooted in a person's own experience can offer comfort and connection.")
                .scaledText(size: 15, weight: .regular)
                .foregroundColor(AppColors.textDark.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
            
            Text("Rhythmic auditory stimulation, using a steady beat to cue movement, is one of the most studied approaches in Parkinson's rehabilitation. Even simple, repetitive musical tasks can activate motor pathways and help the brain compensate for the dopamine loss that causes bradykinesia.")
                .scaledText(size: 15, weight: .regular)
                .foregroundColor(AppColors.textDark.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
            
            Text("Dextera was built with these ideas in mind. By combining a simplified piano with optional camera-based hand tracking, it offers a way to make music that adapts to you.")
                .scaledText(size: 15, weight: .medium)
                .foregroundColor(AppColors.primaryPurple.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.accentPurple.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.accentPurple.opacity(0.12), lineWidth: 1)
        )
    }
    
    private var howDexteraHelps: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How Dextera helps")
                .scaledText(size: 22, weight: .bold)
                .foregroundColor(AppColors.primaryPurple)
            
            Group {
                if sizeClass == .regular {
                    HStack(alignment: .top, spacing: 20) {
                        guidedPlayCard
                        freePlayCard
                    }
                } else {
                    VStack(spacing: 20) {
                        guidedPlayCard
                        freePlayCard
                    }
                }
            }
        }
    }
    
    private var guidedPlayCard: some View {
        ContentPanel(title: "Guided practice") {
            VStack(alignment: .leading, spacing: 14) {
                Text("Pick a familiar melody and follow along note by note. The keyboard highlights each key as it comes, so you always know what to play next. Sessions are tracked automatically so that you can watch your speed and consistency improve over time in your practice history.")
                    .scaledText(size: 14, weight: .regular)
                    .foregroundColor(AppColors.textDark.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                
                Divider()
                    .background(AppColors.primaryPurple.opacity(0.12))
                
                VStack(alignment: .leading, spacing: 10) {
                    BulletPoint("Step-by-step note highlighting")
                    BulletPoint("Progress tracking with duration")
                    BulletPoint("Multiple songs to choose from")
                }
            }
        }
    }
    
    private var freePlayCard: some View {
        ContentPanel(title: "Free play with Hand Mode") {
            VStack(alignment: .leading, spacing: 14) {
                Text("Play freely on the keyboard using touch or turn on Hand Mode and play with hand gestures through the camera. Using Apple's Vision framework, Dextera maps individual finger movements to notes, so you can make music without needing to press a screen at all.")
                    .scaledText(size: 14, weight: .regular)
                    .foregroundColor(AppColors.textDark.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                
                Divider()
                    .background(AppColors.primaryPurple.opacity(0.12))
                
                VStack(alignment: .leading, spacing: 10) {
                    BulletPoint("Touch or camera-based input")
                    BulletPoint("Real-time hand pose detection")
                    BulletPoint("Notes appear on a live staff as you play")
                }
            }
        }
    }
    
    private var tryDexteraStrip: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Try Dextera")
                .scaledText(size: 26, weight: .bold)
                .foregroundColor(AppColors.primaryPurple)
            
            Text("Choose how you want to play.")
                .scaledText(size: 14, weight: .medium)
                .foregroundColor(AppColors.primaryPurple.opacity(0.50))
            
            HStack(spacing: 14) {
                NavigationLink(destination: PlaySong()) {
                    ActionButton(title: "Play a new song", filled: true)
                }
                NavigationLink(destination: FreePlay()) {
                    ActionButton(title: "Free play", filled: false)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.80))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primaryPurple.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: AppColors.primaryPurple.opacity(0.04), radius: 16, x: 0, y: 8)
    }
    
    private var disclaimer: some View {
        Text("Dextera is not medical advice and does not replace professional care.")
            .scaledText(size: 12, weight: .semibold)
            .foregroundColor(AppColors.primaryPurple.opacity(0.45))
    }
}

private struct ContentPanel<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .scaledText(size: 22, weight: .bold)
                .foregroundColor(AppColors.primaryPurple)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.80))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primaryPurple.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: AppColors.primaryPurple.opacity(0.04), radius: 16, x: 0, y: 8)
    }
}

private struct StatRow: View {
    let value: String
    let label: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(value)
                .scaledText(size: 24, weight: .bold)
                .foregroundColor(AppColors.accentPurple)
                .layoutPriority(1)
            Text(label)
                .scaledText(size: 14, weight: .medium)
                .foregroundColor(AppColors.textDark.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct BulletPoint: View {
    let text: String
    init(_ text: String) { self.text = text }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(AppColors.accentPurple.opacity(0.50))
                .frame(width: 5, height: 5)
                .padding(.top, 7)
            Text(text)
                .scaledText(size: 14, weight: .medium)
                .foregroundColor(AppColors.textDark.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ActionButton: View {
    let title: String
    let filled: Bool
    
    var body: some View {
        Text(title)
            .scaledText(size: 15, weight: .bold)
            .foregroundColor(filled ? .white : AppColors.accentPurple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(filled
                          ? AppColors.accentPurple
                          : AppColors.accentPurple.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(filled
                            ? Color.clear
                            : AppColors.accentPurple.opacity(0.22),
                            lineWidth: 1.5)
            )
    }
}

struct AboutParkinsons_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { AboutParkinsons() }
    }
}
