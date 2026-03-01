import SwiftUI

struct StreakCalendarView: View {
    let streakData: [PracticeStreak]
    
    private let minCell: CGFloat = 30
    private let maxCell: CGFloat = 54
    private let spacing: CGFloat = 10
    
    var body: some View {
        GeometryReader { geo in
            let rows = Int(ceil(Double(streakData.count) / 7.0))
            let cell = min(max((geo.size.width - spacing * 6) / 7.0, minCell), maxCell)
            let columns = Array(repeating: GridItem(.fixed(cell), spacing: spacing), count: 7)
            let gridHeight = cell * CGFloat(rows) + spacing * CGFloat(max(rows - 1, 0))
            
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(streakData) { day in
                    DayCell(day: day, size: cell)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: gridHeight, alignment: .top)
        }
        .frame(height: maxCell * 5 + spacing * 4)
    }
}

struct DayCell: View {
    let day: PracticeStreak
    private let calendar = Calendar.current
    let size: CGFloat
    
    var intensity: Double {
        guard day.sessionsCount > 0 else { return 0 }
        return min(1.0, Double(day.sessionsCount) * 0.3 + 0.3)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    day.sessionsCount > 0 
                    ? AppColors.accentPurple.opacity(intensity)
                    : AppColors.primaryPurple.opacity(0.05)
                )
            
            if day.sessionsCount > 0 {
                Text("\(calendar.component(.day, from: day.date))")
                    .font(.system(size: max(11, size * 0.38), weight: .bold))
                    .foregroundColor(intensity > 0.6 ? .white : AppColors.primaryPurple)
            } else {
                Text("\(calendar.component(.day, from: day.date))")
                    .font(.system(size: max(11, size * 0.38)))
                    .foregroundColor(AppColors.primaryPurple.opacity(0.3))
            }
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.22)
                .stroke(
                    calendar.isDateInToday(day.date) 
                    ? AppColors.accentPurple 
                    : Color.clear,
                    lineWidth: 2.5
                )
        )
    }
}
