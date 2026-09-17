import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StudySession.date, order: .reverse) private var sessions: [StudySession]
    
    private var currentStreak: Int {
        StreakCalculator.calculateStreak(from: sessions)
    }
    
    private var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.durationMinutes }
    }
    
    private var userXP: Int {
        sessions.count * 100
    }
    
    private var levelTitle: String {
        if userXP >= 500 { return "🏆 Band 8.0 Master" }
        if userXP >= 300 { return "🔥 Level 3: Grind Master" }
        if userXP >= 150 { return "⚡ Level 2: Focused Scholar" }
        return "⭐ Level 1: Novice"
    }
    
    // Group sessions by calendar day
    private var groupedSessions: [(date: Date, title: String, items: [StudySession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }
        
        let sortedDates = grouped.keys.sorted(by: >)
        
        return sortedDates.map { date in
            let title = formatDayHeader(date: date)
            let items = grouped[date] ?? []
            return (date: date, title: title, items: items)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Streak & XP Hero Header Card
                Section {
                    streakHeaderCard
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                // Skill Progress Distribution Card
                Section {
                    skillDistributionCard
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                // Past Sessions Grouped by Day
                if sessions.isEmpty {
                    Section {
                        emptyStateView
                            .listRowBackground(Color.clear)
                    }
                } else {
                    ForEach(groupedSessions, id: \.date) { group in
                        Section(header: Text(group.title).font(.subheadline.weight(.bold))) {
                            ForEach(group.items) { session in
                                sessionRow(session)
                            }
                            .onDelete { indexSet in
                                deleteSession(from: group.items, at: indexSet)
                            }
                        }
                    }
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Grind Log & Streaks 🔥")
        }
    }
    
    // MARK: - Streak Header Card
    private var streakHeaderCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .overlay(Circle().stroke(Color.orange.opacity(0.3), lineWidth: 1))
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Color.orange)
                    .shadow(color: Color.orange.opacity(0.5), radius: 6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(currentStreak)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(Color.orange)
                    
                    Text(currentStreak == 1 ? "Day Streak" : "Days Streak")
                        .font(.headline.weight(.bold))
                    
                    Spacer()
                    
                    Text(levelTitle)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Capsule())
                        .foregroundStyle(Color.orange)
                }
                
                Text(currentStreak > 0 ? "Zero slacking. Consistency separates Band 8.0 from the rest." : "Complete a study session today to start your streak!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Skill Distribution Card
    private var skillDistributionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skill Progress Toward 8.0")
                .font(.subheadline.weight(.bold))
            
            VStack(spacing: 10) {
                skillBar(name: "Listening", type: .listening, mins: minutesFor(type: .listening))
                skillBar(name: "Reading", type: .reading, mins: minutesFor(type: .reading))
                skillBar(name: "Writing (T1 & T2)", type: .writingTask2, mins: minutesFor(type: .writingTask1) + minutesFor(type: .writingTask2))
                skillBar(name: "Speaking", type: .speaking, mins: minutesFor(type: .speaking))
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
    
    private func skillBar(name: String, type: IELTSSessionType, mins: Int) -> some View {
        let targetMins = 300 // 5 hours per module milestone
        let fraction = min(1.0, Double(mins) / Double(targetMins))
        
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption.weight(.semibold))
                Spacer()
                Text("\(mins)m / \(targetMins)m")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 7)
                    
                    Capsule()
                        .fill(type.themeColor)
                        .frame(width: max(proxy.size.width * CGFloat(fraction), 0), height: 7)
                        .shadow(color: type.themeColor.opacity(0.3), radius: 3)
                }
            }
            .frame(height: 7)
        }
    }
    
    private func minutesFor(type: IELTSSessionType) -> Int {
        sessions.filter { $0.sessionType == type }.reduce(0) { $0 + $1.durationMinutes }
    }
    
    // MARK: - Session Row
    private func sessionRow(_ session: StudySession) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(session.sessionType.themeColor.opacity(0.15))
                    .frame(width: 42, height: 42)
                
                Image(systemName: session.sessionType.icon)
                    .foregroundStyle(session.sessionType.themeColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(session.sessionType.rawValue)
                    .font(.body.weight(.semibold))
                
                Text(session.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(session.durationMinutes) min")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(session.sessionType.themeColor)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Image(systemName: "flame")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
                .padding(.top, 24)
            
            Text("No Proof of Work Yet")
                .font(.headline)
            
            Text("Bro, what are you waiting for? Put in the work in the Study tab to log your first session.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formatDayHeader(date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
    
    private func deleteSession(from items: [StudySession], at indexSet: IndexSet) {
        for index in indexSet {
            let session = items[index]
            modelContext.delete(session)
        }
        try? modelContext.save()
    }
}

#Preview {
    LogView()
}
