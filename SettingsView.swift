import SwiftUI

struct Settings: View {
    @StateObject private var soundManager = SoundManager.shared
    @StateObject private var brightnessManager = BrightnessManager.shared
    @StateObject private var textManager = TextSizeManager.shared
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Settings")
                    .scaledText(size: 40, weight: .bold)
                    .foregroundColor(AppColors.primaryPurple)
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        ProfileCard()
                        AudioSection()
                        NotificationsSection()
                        AccessibilitySection()
                    }
                    .padding(.horizontal, 27)
                    .padding(.bottom, 20)
                }
                
                Spacer(minLength: 0)
                
                BottomNavBar()
                    .padding(.top, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .applySavedBrightness()
    }
}

struct ProfileCard: View {
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppColors.accentPurple.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: "person.fill")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.accentPurple)
            }
            
            VStack(alignment: .leading, spacing: 6) {                
                Text("Anushka Punukollu")
                    .scaledText(size: 25, weight: .bold)
                    .foregroundColor(AppColors.textDark)
                Text("Piano Learner")
                    .scaledText(size: 17, weight: .medium)
                    .foregroundColor(AppColors.primaryPurple.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.accentPurple.opacity(0.6))
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.7)))
    }
}

struct AudioSection: View {
    @StateObject private var soundManager = SoundManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audio")
                .scaledText(size: 32, weight: .bold)
                .foregroundColor(AppColors.primaryPurple)
            
            VStack(spacing: 20) {
                Toggle(isOn: $soundManager.isSoundEnabled) {
                    HStack(spacing: 25) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.accentPurple)
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Sound Effects")
                                .scaledText(size: 21, weight: .semibold)
                                .foregroundColor(AppColors.textDark)
                            Text("Play sounds during practice")
                                .scaledText(size: 15, weight: .medium)
                                .foregroundColor(AppColors.primaryPurple.opacity(0.7))
                        }
                    }
                }
                .tint(AppColors.accentPurple)
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.7)))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Sound Effects")
                .accessibilityHint("Plays sound effects during practice")
                .accessibilityValue(soundManager.isSoundEnabled ? "On" : "Off")
                
                Toggle(isOn: $soundManager.isHapticsEnabled) {
                    HStack(spacing: 20) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.accentPurple)
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Haptics")
                                .scaledText(size: 21, weight: .semibold)
                                .foregroundColor(AppColors.textDark)
                            Text("Vibration feedback")
                                .scaledText(size: 15, weight: .medium)
                                .foregroundColor(AppColors.primaryPurple.opacity(0.7))
                        }
                    }
                }
                .tint(AppColors.accentPurple)
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.7)))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Haptics")
                .accessibilityHint("Vibration feedback on key presses")
                .accessibilityValue(soundManager.isHapticsEnabled ? "On" : "Off")
            }
        }
    }
}

struct NotificationsSection: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Notifications")
                .scaledText(size: 30, weight: .bold)
                .foregroundColor(AppColors.primaryPurple)
            
            Toggle(isOn: $notificationsEnabled) {
                HStack(spacing: 20) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 30, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.accentPurple)
                        .frame(width: 40)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Push Notifications")
                            .scaledText(size: 21, weight: .semibold)
                            .foregroundColor(AppColors.textDark)
                        Text("Reminders and updates")
                            .scaledText(size: 15, weight: .medium)
                            .foregroundColor(AppColors.primaryPurple.opacity(0.7))
                    }
                }
            }
            .tint(AppColors.accentPurple)
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.7)))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Push Notifications")
            .accessibilityHint("Enable reminders and updates")
            .accessibilityValue(notificationsEnabled ? "On" : "Off")
        }
    }
}

struct AccessibilitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accessibility")
                .scaledText(size: 30, weight: .bold)
                .foregroundColor(AppColors.primaryPurple)
            
            VStack(spacing: 20) {
                BrightnessControl()
                TextSizeControl()
            }
        }
    }
}

struct BrightnessControl: View {
    @StateObject private var manager = BrightnessManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.accentPurple)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Brightness")
                        .scaledText(size: 21, weight: .semibold)
                        .foregroundColor(AppColors.textDark)
                    Text("Adjust screen brightness")
                        .scaledText(size: 15, weight: .medium)
                        .foregroundColor(AppColors.primaryPurple.opacity(0.7))
                }
                Spacer()
            }
            
            HStack(spacing: 12) {
                Image(systemName: "sun.min")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.primaryPurple)
                Slider(value: $manager.currentBrightness, in: 0.1...1.0, step: 0.05)
                    .tint(AppColors.accentPurple)
                Image(systemName: "sun.max")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.primaryPurple)
            }
            .padding(.leading, 40)
            .accessibilityElement()
            .accessibilityLabel("Brightness")
            .accessibilityValue("\(Int(manager.currentBrightness * 100)) percent")
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.7)))
    }
}

struct TextSizeControl: View {
    @StateObject private var manager = TextSizeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                Image(systemName: "textformat.size")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.accentPurple)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Text Size")
                        .font(.system(size: 22 * CGFloat(manager.currentSize),
                                      weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textDark)
                    Text("Adjust app text size")
                        .font(.system(size: 15 * CGFloat(manager.currentSize),
                                      weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.primaryPurple.opacity(0.7))
                }
                Spacer()
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("A")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.primaryPurple)
                    Slider(value: $manager.currentSize, in: 0.8...1.5, step: 0.1)
                        .tint(AppColors.accentPurple)
                    Text("A")
                        .font(.system(size: 26, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.primaryPurple)
                }
                Text("Preview: This is how text will appear")
                    .font(.system(size: 17 * CGFloat(manager.currentSize),
                                  weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textDark)
            }
            .padding(.leading, 40)
            .accessibilityElement()
            .accessibilityLabel("Text Size")
            .accessibilityValue(String(format: "%.1f", manager.currentSize))
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.7)))
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { Settings() }
    }
}
