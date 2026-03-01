import Foundation

struct PracticeSession: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let songId: String
    let songTitle: String
    let songEmoji: String
    let totalNotes: Int
    let correctNotes: Int
    let wrongNotes: Int
    let duration: TimeInterval
    
    init(id: UUID = UUID(), date: Date, songId: String, songTitle: String, songEmoji: String, 
         totalNotes: Int, correctNotes: Int, wrongNotes: Int, duration: TimeInterval) {
        self.id = id
        self.date = date
        self.songId = songId
        self.songTitle = songTitle
        self.songEmoji = songEmoji
        self.totalNotes = totalNotes
        self.correctNotes = correctNotes
        self.wrongNotes = wrongNotes
        self.duration = duration
    }
}

struct PracticeStreak: Identifiable {
    let id = UUID()
    let date: Date
    let sessionsCount: Int
    let totalDuration: TimeInterval
}

struct SongPerformance: Identifiable {
    let id: String
    let songTitle: String
    let songEmoji: String
    let playCount: Int
    let lastPlayed: Date
}
