import Foundation
import Combine

class PracticeDatabaseManager: ObservableObject {
    static let shared = PracticeDatabaseManager()
    
    @Published private(set) var sessions: [PracticeSession] = []
    private let saveKey = "practice_sessions"
    
    init() {
        loadSessions()
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([PracticeSession].self, from: data) {
            sessions = decoded.sorted { $0.date > $1.date }
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func addSession(_ session: PracticeSession) {
        sessions.insert(session, at: 0)
        saveSessions()
    }
    
    var totalSessions: Int { sessions.count }
    
    var uniqueSongsCount: Int {
        Set(sessions.map { $0.songTitle.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }).count
    }
    
    var totalPracticeTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        let groupedByDay = Dictionary(grouping: sessions) { 
            calendar.startOfDay(for: $0.date) 
        }
        
        while groupedByDay[checkDate] != nil {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        
        return streak
    }
    
    var longestStreak: Int {
        let calendar = Calendar.current
        let sortedDays = Set(sessions.map { calendar.startOfDay(for: $0.date) }).sorted()
        
        guard !sortedDays.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDays.count {
            if let daysBetween = calendar.dateComponents([.day], from: sortedDays[i-1], to: sortedDays[i]).day,
               daysBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
}
