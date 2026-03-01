import Foundation

struct GuidedSong: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let description: String
    let sequence: [(noteIndex: Int, duration: Double)]
    let tempo: Double
}

extension GuidedSong {
    static let allSongs: [GuidedSong] = [
        GuidedSong(
            title: "Twinkle Twinkle",
            emoji: "⭐",
            description: "A gentle warm up",
            sequence: [
                (0,0.5),(0,0.5),(4,0.5),(4,0.5),(5,0.5),(5,0.5),(4,1.0),
                (3,0.5),(3,0.5),(2,0.5),(2,0.5),(1,0.5),(1,0.5),(0,1.0),
                (4,0.5),(4,0.5),(3,0.5),(3,0.5),(2,0.5),(2,0.5),(1,1.0),
                (4,0.5),(4,0.5),(3,0.5),(3,0.5),(2,0.5),(2,0.5),(1,1.0),
                (0,0.5),(0,0.5),(4,0.5),(4,0.5),(5,0.5),(5,0.5),(4,1.0),
                (3,0.5),(3,0.5),(2,0.5),(2,0.5),(1,0.5),(1,0.5),(0,1.5),
            ],
            tempo: 80
        ),
        GuidedSong(
            title: "Mary Had a Little Lamb",
            emoji: "🐑",
            description: "Simple repeating pattern, great for coordination",
            sequence: [
                (2,0.5),(1,0.5),(0,0.5),(1,0.5),(2,0.5),(2,0.5),(2,1.0),
                (1,0.5),(1,0.5),(1,1.0),(2,0.5),(4,0.5),(4,1.0),
                (2,0.5),(1,0.5),(0,0.5),(1,0.5),(2,0.5),(2,0.5),(2,0.5),(2,0.5),
                (1,0.5),(1,0.5),(2,0.5),(1,0.5),(0,1.5),
            ],
            tempo: 75
        ),
        GuidedSong(
            title: "Ode to Joy",
            emoji: "🎵",
            description: "A Beethoven classic",
            sequence: [
                (2,0.5),(2,0.5),(3,0.5),(4,0.5),(4,0.5),(3,0.5),(2,0.5),(1,0.5),
                (0,0.5),(0,0.5),(1,0.5),(2,0.5),(2,0.75),(1,0.25),(1,1.0),
                (2,0.5),(2,0.5),(3,0.5),(4,0.5),(4,0.5),(3,0.5),(2,0.5),(1,0.5),
                (0,0.5),(0,0.5),(1,0.5),(2,0.5),(1,0.75),(0,0.25),(0,1.0),
            ],
            tempo: 70
        ),
        GuidedSong(
            title: "Scale Workout",
            emoji: "💪",
            description: "Up and down exercise for your fingers",
            sequence: [
                (0,0.4),(1,0.4),(2,0.4),(3,0.4),(4,0.4),(5,0.4),(6,0.4),(7,0.6),
                (7,0.4),(6,0.4),(5,0.4),(4,0.4),(3,0.4),(2,0.4),(1,0.4),(0,0.8),
                (0,0.4),(1,0.4),(2,0.4),(3,0.4),(4,0.4),(5,0.4),(6,0.4),(7,0.6),
                (7,0.4),(6,0.4),(5,0.4),(4,0.4),(3,0.4),(2,0.4),(1,0.4),(0,1.0),
            ],
            tempo: 65
        ),
    ]
}
