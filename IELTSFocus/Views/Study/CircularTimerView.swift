import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let formattedTime: String
    let sessionType: IELTSSessionType
    let timerState: TimerViewModel.TimerState
    
    var body: some View {
        ZStack {
            // Liquid Glass Translucent Orb Center
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            sessionType.themeColor.opacity(0.22),
                            Color.white.opacity(0.04),
                            Color.black.opacity(0.5)
                        ],
                        center: .init(x: 0.35, y: 0.3),
                        startRadius: 10,
                        endRadius: 110
                    )
                )
                .frame(width: 210, height: 210)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.white.opacity(0.05), Color.white.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: sessionType.themeColor.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Background Track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 16)
                .frame(width: 240, height: 240)
            
            // Glowing Neon Progress Stroke
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            sessionType.themeColor.opacity(0.7),
                            sessionType.themeColor,
                            sessionType.themeColor.opacity(0.9)
                        ]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))
                .shadow(color: sessionType.themeColor.opacity(0.5), radius: 10, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Center Labels
            VStack(spacing: 6) {
                Image(systemName: sessionType.icon)
                    .font(.title2)
                    .foregroundStyle(sessionType.themeColor)
                
                Text(formattedTime)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 4, y: 2)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(timerState == .running ? Color.green : Color.orange)
                        .frame(width: 6, height: 6)
                    
                    Text(statusText)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
    }
    
    private var statusText: String {
        switch timerState {
        case .idle: return "Ready to grind"
        case .running: return "Locked In 🔒"
        case .paused: return "Paused (Don't slack)"
        case .completed: return "Good Work Bro!"
        }
    }
}

#Preview {
    CircularTimerView(
        progress: 0.4,
        formattedTime: "36:00",
        sessionType: .reading,
        timerState: .running
    )
    .frame(width: 300, height: 300)
    .background(Theme.background)
}
