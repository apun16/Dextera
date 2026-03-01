import SwiftUI
import Charts

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.15))
                    .cornerRadius(10)
                
                Spacer()
                
                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption.bold())
                        Text("\(abs(trend), specifier: "%.1f")%")
                            .font(.caption.bold())
                    }
                    .foregroundColor(trend >= 0 ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((trend >= 0 ? Color.green : Color.red).opacity(0.1))
                    .cornerRadius(6)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .scaledText(size: 28, weight: .bold)
                    .foregroundColor(AppColors.textDark)
                
                Text(title)
                    .scaledText(size: 14, weight: .semibold)
                    .foregroundColor(AppColors.primaryPurple.opacity(0.6))
            }
            
            Text(subtitle)
                .scaledText(size: 12, weight: .medium)
                .foregroundColor(AppColors.primaryPurple.opacity(0.4))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.97))
                .shadow(color: color.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
}

struct RecentSessionRow: View {
    let session: PracticeSession
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.25),
                                Color.green.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Text(session.songEmoji.isEmpty ? "🎵" : session.songEmoji)
                    .font(.system(size: 22))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(session.songTitle)
                    .font(.subheadline.bold())
                    .foregroundColor(AppColors.textDark)
                
                HStack(spacing: 10) {
                    Label(formatDuration(session.duration), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryPurple.opacity(0.5))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(timeAgoString(from: session.date))
                    .font(.caption2)
                    .foregroundColor(AppColors.primaryPurple.opacity(0.4))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.green.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.green.opacity(0.10), lineWidth: 1)
                )
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    private func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days < 7 { return "\(days)d ago" }
        let weeks = days / 7
        return "\(weeks)w ago"
    }
}

struct SongLeaderboardView: View {
    let performances: [SongPerformance]
    @State private var showAsPie = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showAsPie = false }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                        Text("List")
                            .scaledText(size: 12, weight: .bold)
                    }
                    .foregroundColor(showAsPie ? AppColors.primaryPurple.opacity(0.6) : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(showAsPie ? Color.clear : AppColors.accentPurple, in: Capsule())
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showAsPie = true }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.pie.fill")
                        Text("Pie")
                            .scaledText(size: 12, weight: .bold)
                    }
                    .foregroundColor(showAsPie ? .white : AppColors.primaryPurple.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(showAsPie ? AppColors.accentPurple : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            
            if showAsPie {
                SongLeaderboardPieChart(performances: Array(performances.prefix(6)))
                    .frame(minHeight: 200)
            } else {
                SongLeaderboardList(performances: Array(performances.prefix(6)))
                    .frame(minHeight: 140)
            }
        }
    }
}

struct SongLeaderboardList: View {
    let performances: [SongPerformance]
    
    var body: some View {
        Group {
            if performances.isEmpty {
                ContentUnavailableView(
                    "No Songs Yet",
                    systemImage: "music.note",
                    description: Text("Start playing to see your leaderboard")
                )
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(performances.enumerated()), id: \.element.id) { index, song in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppColors.accentPurple)
                                    .frame(width: 20, alignment: .center)
                                
                                Text(song.songTitle)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(AppColors.textDark)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("\(song.playCount)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.primaryPurple)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppColors.lightPurple.opacity(0.25), in: Capsule())
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 4)
                            
                            if index < performances.count - 1 {
                                Divider()
                                    .background(AppColors.primaryPurple.opacity(0.12))
                                    .padding(.leading, 32)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SongLeaderboardPieChart: View {
    let performances: [SongPerformance]
    
    private let colors: [Color] = [
        Color(red: 0.98, green: 0.36, blue: 0.36),
        Color(red: 0.98, green: 0.60, blue: 0.20),
        Color(red: 0.30, green: 0.78, blue: 0.40),
        Color(red: 0.25, green: 0.65, blue: 0.95),
        Color(red: 0.45, green: 0.35, blue: 0.90),
        Color(red: 0.80, green: 0.35, blue: 0.90),
    ]
    
    var body: some View {
        let total = performances.reduce(0) { $0 + $1.playCount }
        
        Group {
            if performances.isEmpty || total <= 0 {
                VStack(spacing: 10) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(AppColors.primaryPurple.opacity(0.35))
                    Text("No data yet")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryPurple.opacity(0.55))
                }
                .frame(maxWidth: .infinity, minHeight: 140)
            } else {
                VStack(spacing: 14) {
                    Chart(Array(performances.enumerated()), id: \.element.id) { idx, song in
                        SectorMark(
                            angle: .value("Plays", song.playCount),
                            innerRadius: .ratio(0.55),
                            angularInset: 1.5
                        )
                        .foregroundStyle(colors[idx % colors.count])
                        .cornerRadius(4)
                    }
                    .chartBackground { proxy in
                        GeometryReader { geo in
                            let frame = geo[proxy.plotFrame!]
                            VStack(spacing: 2) {
                                Text("\(total)")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.primaryPurple)
                                Text("plays")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColors.primaryPurple.opacity(0.55))
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                    .frame(height: 180)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(performances.prefix(4).enumerated()), id: \.element.id) { idx, song in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(colors[idx % colors.count])
                                    .frame(width: 9, height: 9)
                                Text(song.songTitle)
                                    .scaledText(size: 12, weight: .medium)
                                    .foregroundColor(AppColors.textDark)
                                    .lineLimit(1)
                                Spacer()
                                Text("\(song.playCount)")
                                    .scaledText(size: 11, weight: .bold)
                                    .foregroundColor(AppColors.primaryPurple.opacity(0.75))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 6)
                }
                .padding(.vertical, 6)
            }
        }
    }
}

struct PracticeEmptyState: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryPurple.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.accentPurple)
            }
            
            Text("No Practice Data Yet")
                .font(.title3.bold())
                .foregroundColor(AppColors.textDark)
            
            Text("Complete your first song to see insights and track your progress!")
                .font(.subheadline)
                .foregroundColor(AppColors.primaryPurple.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(40)
    }
}
