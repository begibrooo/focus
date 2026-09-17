import Foundation

struct StreakCalculator {
    /// Calculates the consecutive days streak (including today or yesterday)
    static func calculateStreak(from sessions: [StudySession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueDays = Set(sessions.map { calendar.startOfDay(for: $0.date) })
        let sortedDays = uniqueDays.sorted(by: >)
        
        let today = calendar.startOfDay(for: Date())
        guard let mostRecent = sortedDays.first else { return 0 }
        
        let daysSinceLast = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
        // If the latest session was before yesterday, streak is broken
        if daysSinceLast > 1 {
            return 0
        }
        
        var streak = 0
        var expectedDay = mostRecent
        
        for day in sortedDays {
            if day == expectedDay {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: expectedDay) else { break }
                expectedDay = previousDay
            } else if day < expectedDay {
                break
            }
        }
        
        return streak
    }
}
