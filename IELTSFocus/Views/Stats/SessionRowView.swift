import SwiftUI

struct SessionRowView: View {
    let session: StudySession
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.startedAt)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(session.skill.themeColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: session.skill.systemImage)
                    .foregroundStyle(session.skill.themeColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.skill.rawValue)
                        .font(.subheadline.weight(.semibold))
                    
                    Spacer()
                    
                    Text("\(session.durationMinutes) min")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(session.skill.themeColor)
                }
                
                if !session.notes.isEmpty {
                    Text(session.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
