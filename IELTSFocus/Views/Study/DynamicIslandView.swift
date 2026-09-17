import SwiftUI

struct DynamicIslandView: View {
    @Bindable var viewModel: TimerViewModel
    @State private var musicService = ClassicalMusicService.shared
    @State private var isPulsing: Bool = false
    @State private var eqHeights: [CGFloat] = [4, 11, 7]
    
    private var isVisible: Bool {
        viewModel.timerState == .running || viewModel.timerState == .paused
    }
    
    var body: some View {
        if isVisible {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    if viewModel.timerState == .running {
                        AudioService.shared.playClick()
                        AudioService.shared.speakSessionPause()
                        viewModel.pause()
                    } else {
                        AudioService.shared.playStartBell()
                        AudioService.shared.speakSessionResume()
                        viewModel.resume()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    // Left: Icon + Skill Name
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.selectedType.icon)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(viewModel.selectedType.themeColor)
                        
                        Text(viewModel.selectedType.rawValue)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Center: Classical Music Mini Visualizer
                    if musicService.isPlaying {
                        HStack(spacing: 3) {
                            Image(systemName: "music.note")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.cyan)
                            
                            HStack(spacing: 2) {
                                ForEach(0..<3) { i in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color.cyan)
                                        .frame(width: 2.5, height: eqHeights[i])
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.cyan.opacity(0.18))
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    // Right: Formatted Countdown + Live Activity Pulse Dot
                    HStack(spacing: 6) {
                        Text(viewModel.formattedTime)
                            .font(.system(size: 13, weight: .heavy, design: .monospaced))
                            .foregroundStyle(viewModel.selectedType.themeColor)
                        
                        // Live Status Indicator Dot
                        Circle()
                            .fill(viewModel.timerState == .running ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                            .shadow(
                                color: (viewModel.timerState == .running ? Color.green : Color.orange).opacity(isPulsing ? 0.9 : 0.3),
                                radius: isPulsing ? 6 : 2
                            )
                            .opacity(isPulsing ? 1.0 : 0.5)
                    }
                }
                .padding(.horizontal, 14)
                .frame(width: 360, height: 37)
                .background(Color.black)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                .shadow(color: Color.black.opacity(0.85), radius: 14, y: 5)
            }
            .buttonStyle(.plain)
            .padding(.top, 11)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.3, anchor: .top).combined(with: .opacity),
                removal: .scale(scale: 0.3, anchor: .top).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.timerState)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
                startEqualizerAnimation()
            }
        }
    }
    
    private func startEqualizerAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            guard musicService.isPlaying else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                eqHeights = [
                    CGFloat.random(in: 3...12),
                    CGFloat.random(in: 4...14),
                    CGFloat.random(in: 3...10)
                ]
            }
        }
    }
}

#Preview {
    let vm = TimerViewModel()
    vm.start()
    return ZStack(alignment: .top) {
        Color.gray.opacity(0.2).ignoresSafeArea()
        DynamicIslandView(viewModel: vm)
    }
}
