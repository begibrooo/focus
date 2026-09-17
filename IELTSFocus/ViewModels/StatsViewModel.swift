import Foundation
import SwiftData

final class StatsViewModel {
    
    /// Calculates the consecutive active study streak (in days)
    static func calculateStreak(sessions: [StudySession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let completedSessions = sessions
            .filter { $0.isCompleted }
            .sorted(by: { $0.startedAt > $1.startedAt })
        
        guard !completedSessions.isEmpty else { return 0 }
        
        var uniqueDays = Set<Date>()
        for session in completedSessions {
            let startOfDay = calendar.startOfDay(for: session.startedAt)
            uniqueDays.insert(startOfDay)
        }
        
        let sortedDays = uniqueDays.sorted(by: >)
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Streak is active if user studied today or yesterday
        guard let mostRecent = sortedDays.first,
              mostRecent == today || mostRecent == yesterday else {
            return 0
        }
        
        var streak = 0
        var expectedDay = mostRecent
        
        for day in sortedDays {
            if day == expectedDay {
                streak += 1
                expectedDay = calendar.date(byAdding: .day, value: -1, to: expectedDay)!
            } else if day < expectedDay {
                break
            }
        }
        
        return streak
    }
    
    /// Returns total minutes studied
    static func totalStudyMinutes(sessions: [StudySession]) -> Int {
        sessions.filter { $0.isCompleted }.reduce(0) { $0 + $1.durationMinutes }
    }
    
    /// Returns study minutes for a specific IELTS skill
    static func minutesForSkill(_ skill: IELTSSkill, sessions: [StudySession]) -> Int {
        sessions
            .filter { $0.isCompleted && $0.skill == skill }
            .reduce(0) { $0 + $1.durationMinutes }
    }
    
    /// Weekly study minutes (last 7 days)
    static func weeklyStudyMinutes(sessions: [StudySession]) -> Int {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions
            .filter { $0.isCompleted && $0.startedAt >= oneWeekAgo }
            .reduce(0) { $0 + $1.durationMinutes }
    }
}
