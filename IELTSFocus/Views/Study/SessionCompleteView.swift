import SwiftUI

struct SessionCompleteView: View {
    let sessionType: IELTSSessionType
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.orange)
                }
                
                VStack(spacing: 8) {
                    Text("Session Complete!")
                        .font(.title.weight(.bold))
                    
                    Text("You completed \(sessionType.durationMinutes) minutes of IELTS \(sessionType.rawValue) practice.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Target 8.0 Milestone", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                    
                    Text("Consistent, timed practice under exam conditions is the proven way to reach Band 8.0 stamina.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(sessionType.themeColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Great Work!")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SessionCompleteView(sessionType: .reading, onDismiss: {})
}
