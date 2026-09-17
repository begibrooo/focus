import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StudySession.startedAt, order: .reverse) private var sessions: [StudySession]
    
    private var streakDays: Int {
        StatsViewModel.calculateStreak(sessions: sessions)
    }
    
    private var totalMinutes: Int {
        StatsViewModel.totalStudyMinutes(sessions: sessions)
    }
    
    private var weeklyMinutes: Int {
        StatsViewModel.weeklyStudyMinutes(sessions: sessions)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Streak Hero Card
                    streakHeroCard
                    
                    // Metric Summary Grid
                    metricGrid
                    
                    // Skill Breakdown
                    skillBreakdownCard
                    
                    // History List
                    historySection
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Study Log & Streaks")
        }
    }
    
    // MARK: - Streak Hero Card
    private var streakHeroCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.15))
                    .frame(width: 68, height: 68)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(streakDays)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.accent)
                    
                    Text(streakDays == 1 ? "Day Streak" : "Days Streak")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                
                Text(streakDays > 0 ? "You're on track! Consistency guarantees Band 8.0." : "Start a session today to start your streak.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .focusCardStyle()
    }
    
    // MARK: - Metric Grid
    private var metricGrid: some View {
        HStack(spacing: 12) {
            metricItem(
                title: "Total Study",
                value: formatHours(minutes: totalMinutes),
                icon: "clock.fill",
                tint: Theme.primary
            )
            
            metricItem(
                title: "This Week",
                value: formatHours(minutes: weeklyMinutes),
                icon: "calendar",
                tint: Theme.success
            )
            
            metricItem(
                title: "Sessions",
                value: "\(sessions.filter { $0.isCompleted }.count)",
                icon: "checkmark.circle.fill",
                tint: Theme.writing2
            )
        }
    }
    
    private func metricItem(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(tint)
                Spacer()
            }
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .focusCardStyle()
    }
    
    // MARK: - Skill Breakdown
    private var skillBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Skill Distribution")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach([IELTSSkill.listening, .reading, .writingTask1, .writingTask2, .speaking], id: \.self) { skill in
                    let skillMins = StatsViewModel.minutesForSkill(skill, sessions: sessions)
                    let fraction = totalMinutes > 0 ? Double(skillMins) / Double(totalMinutes) : 0.0
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label(skill.rawValue, systemImage: skill.systemImage)
                                .font(.caption.weight(.medium))
                            Spacer()
                            Text("\(skillMins)m (\(Int(fraction * 100))%)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(skill.themeColor.opacity(0.15))
                                    .frame(height: 8)
                                
                                Capsule()
                                    .fill(skill.themeColor)
                                    .frame(width: max(proxy.size.width * CGFloat(fraction), 0), height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .focusCardStyle()
    }
    
    // MARK: - History Section
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.headline)
            
            if sessions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "pencil.and.ruler")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 12)
                    
                    Text("No practice logs yet")
                        .font(.subheadline.weight(.semibold))
                    
                    Text("Complete your first study session to track your IELTS milestones.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity)
                .focusCardStyle()
            } else {
                VStack(spacing: 8) {
                    ForEach(sessions.prefix(15)) { session in
                        SessionRowView(session: session)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteSession(session)
                                } label: {
                                    Label("Delete Entry", systemImage: "trash")
                                }
                            }
                        
                        if session.id != sessions.prefix(15).last?.id {
                            Divider()
                        }
                    }
                }
                .focusCardStyle()
            }
        }
    }
    
    private func deleteSession(_ session: StudySession) {
        withAnimation {
            modelContext.delete(session)
            try? modelContext.save()
        }
    }
    
    private func formatHours(minutes: Int) -> String {
        let hrs = Double(minutes) / 60.0
        return String(format: "%.1fh", hrs)
    }
}
