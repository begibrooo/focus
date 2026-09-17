import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let tintColor: Color
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    tintColor.opacity(0.12),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
            
            // Animated progress ring
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            tintColor.opacity(0.7),
                            tintColor,
                            tintColor.opacity(0.9)
                        ]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
        }
        .padding(20)
    }
}
