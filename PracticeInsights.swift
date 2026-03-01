import Foundation
import Combine

class PracticeInsights: ObservableObject {
    @Published private(set) var songPerformances: [SongPerformance] = []
    @Published private(set) var streakData: [PracticeStreak] = []
    private var database: PracticeDatabaseManager
    private var cancellables = Set<AnyCancellable>()
    
    init(database: PracticeDatabaseManager = .shared) {
        self.database = database
        setupSubscriptions()
        calculateInsights()
    }
    
    private func setupSubscriptions() {
        database.$sessions
            .sink { [weak self] _ in
                self?.calculateInsights()
            }
            .store(in: &cancellables)
    }
    
    func calculateInsights() {
        calculateSongPerformances()
        calculateStreakData()
    }
    
    private func calculateSongPerformances() {
        let grouped = Dictionary(grouping: database.sessions) {
            $0.songTitle.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
        
        songPerformances = grouped.compactMap { _, sessions in
            guard let mostRecent = sessions.max(by: { $0.date < $1.date }) else { return nil }
            
            return SongPerformance(
                id: mostRecent.songTitle.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                songTitle: mostRecent.songTitle,
                songEmoji: mostRecent.songEmoji,
                playCount: sessions.count,
                lastPlayed: sessions.map { $0.date }.max() ?? Date()
            )
        }.sorted { $0.playCount > $1.playCount }
    }
    
    private func calculateStreakData() {
        let calendar = Calendar.current
        let last30Days = (0..<30).compactMap { 
            calendar.date(byAdding: .day, value: -$0, to: calendar.startOfDay(for: Date())) 
        }.reversed()
        
        streakData = last30Days.map { date in
            let daySessions = database.sessions.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            return PracticeStreak(
                date: date,
                sessionsCount: daySessions.count,
                totalDuration: daySessions.reduce(0) { $0 + $1.duration }
            )
        }
    }
}
