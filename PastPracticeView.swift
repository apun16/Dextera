import SwiftUI

struct PastPractice: View {
    @StateObject private var database = PracticeDatabaseManager.shared
    @StateObject private var insights = PracticeInsights()
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection                    
                    if database.sessions.isEmpty {
                        PracticeEmptyState()
                            .padding(.top, 40)
                    } else {
                        statsGrid
                        recentSessionsSection
                        streakAndSongsSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 22)
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
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Past Practice")
                    .scaledText(size: 34, weight: .bold)
                    .foregroundColor(AppColors.primaryPurple)
                
                Text("Track your musical journey")
                    .scaledText(size: 15, weight: .medium)
                    .foregroundColor(AppColors.primaryPurple.opacity(0.55))
            }
            Spacer()
        }
        .padding(.bottom, 4)
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 14) {
            StatCard(
                title: "Total Sessions",
                value: "\(database.totalSessions)",
                subtitle: "Keep practicing!",
                icon: "number",
                color: AppColors.accentPurple,
                trend: nil
            )
            
            StatCard(
                title: "Current Streak",
                value: database.currentStreak == 1 ? "1 day" : "\(database.currentStreak) days",
                subtitle: database.longestStreak == 1 ? "Best: 1 day" : "Best: \(database.longestStreak) days",
                icon: "flame.fill",
                color: Color.orange,
                trend: nil
            )
            
            StatCard(
                title: "Practice Time",
                value: formatTotalTime(database.totalPracticeTime),
                subtitle: "Total time invested",
                icon: "clock.fill",
                color: Color.blue,
                trend: nil
            )
            
            StatCard(
                title: "Unique Songs Played",
                value: "\(database.uniqueSongsCount)",
                subtitle: "Number of unique songs practiced",
                icon: "music.note.list",
                color: Color.pink,
                trend: nil
            )
        }
    }
    
    private var streakAndSongsSection: some View {
        let streakCard = VStack(alignment: .leading, spacing: 18) {
            Text("Last 30 Days")
                .scaledText(size: 18, weight: .bold)
                .foregroundColor(AppColors.textDark)
            StreakCalendarView(streakData: insights.streakData)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 260, alignment: .top)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.97))
                .shadow(color: AppColors.primaryPurple.opacity(0.06), radius: 16, x: 0, y: 8)
        )
        
        let songsCard = VStack(alignment: .leading, spacing: 14) {
            Text("Leaderboard")
                .scaledText(size: 18, weight: .bold)
                .foregroundColor(AppColors.textDark)
            SongLeaderboardView(performances: insights.songPerformances)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 260, alignment: .top)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.97))
                .shadow(color: AppColors.primaryPurple.opacity(0.06), radius: 16, x: 0, y: 8)
        )
        
        return Group {
            if sizeClass == .regular {
                HStack(alignment: .top, spacing: 16) {
                    streakCard
                    songsCard
                }
            } else {
                VStack(spacing: 16) {
                    streakCard
                    songsCard
                }
            }
        }
    }
    
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Recent Sessions")
                    .scaledText(size: 18, weight: .bold)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                if database.sessions.count > 5 {
                    Text("Last 5 of \(database.sessions.count)")
                        .scaledText(size: 12, weight: .medium)
                        .foregroundColor(AppColors.primaryPurple.opacity(0.5))
                }
            }
            
            VStack(spacing: 10) {
                ForEach(database.sessions.prefix(5)) { session in
                    RecentSessionRow(session: session)
                }
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.97))
                .shadow(color: AppColors.primaryPurple.opacity(0.06), radius: 16, x: 0, y: 8)
        )
    }
    
    private func formatTotalTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct PastPractice_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { PastPractice() }
    }
}
