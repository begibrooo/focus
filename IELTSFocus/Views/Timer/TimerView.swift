import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TimerViewModel()
    @State private var sessionNotes: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // IELTS Skill Selector (Disabled during active countdown)
                    skillPickerSection
                    
                    // Center Circular Timer
                    timerDisplaySection
                    
                    // Timer Action Controls
                    timerControlsSection
                    
                    // Focus Mode Shortcut Trigger
                    focusModeBanner
                    
                    // IELTS Band 8 Tip Card
                    band8TipCard
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("IELTS Focus")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showFrictionGate) {
                FrictionGateView(onConfirmExit: {
                    viewModel.confirmCancel()
                })
            }
            .sheet(isPresented: $viewModel.showCompletionSheet) {
                completionSheet
            }
        }
    }
    
    // MARK: - Skill Picker
    private var skillPickerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(IELTSSkill.allCases) { skill in
                    let isSelected = viewModel.selectedSkill == skill
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            viewModel.selectedSkill = skill
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: skill.systemImage)
                            Text(skill.displayName)
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isSelected ? skill.themeColor : Theme.cardBackground)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                        .shadow(color: isSelected ? skill.themeColor.opacity(0.3) : Color.clear, radius: 6, y: 3)
                    }
                    .disabled(viewModel.timerState == .running || viewModel.timerState == .paused)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Timer Center Display
    private var timerDisplaySection: some View {
        VStack(spacing: 12) {
            ZStack {
                CircularProgressView(
                    progress: viewModel.progress,
                    tintColor: viewModel.selectedSkill.themeColor
                )
                .frame(width: 270, height: 270)
                
                VStack(spacing: 6) {
                    Text(viewModel.selectedSkill.rawValue.uppercased())
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(viewModel.selectedSkill.themeColor)
                        .tracking(1.5)
                    
                    Text(viewModel.formattedTime)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    
                    Text(statusText)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 10)
        }
        .focusCardStyle()
    }
    
    private var statusText: String {
        switch viewModel.timerState {
        case .idle: return "Ready to Practice"
        case .running: return "Targeting Band 8.0"
        case .paused: return "Session Paused"
        case .completed: return "Session Finished!"
        }
    }
    
    // MARK: - Controls
    private var timerControlsSection: some View {
        HStack(spacing: 20) {
            if viewModel.timerState == .idle {
                Button {
                    viewModel.startTimer()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Session")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedSkill.themeColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: viewModel.selectedSkill.themeColor.opacity(0.35), radius: 8, y: 4)
                }
            } else {
                // Cancel / Stop Button (Triggers Friction Gate)
                Button {
                    viewModel.requestCancel()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.danger)
                        .frame(width: 60, height: 60)
                        .background(Theme.danger.opacity(0.12))
                        .clipShape(Circle())
                }
                
                // Play / Pause Button
                Button {
                    if viewModel.timerState == .running {
                        viewModel.pauseTimer()
                    } else {
                        viewModel.startTimer()
                    }
                } label: {
                    HStack {
                        Image(systemName: viewModel.timerState == .running ? "pause.fill" : "play.fill")
                        Text(viewModel.timerState == .running ? "Pause" : "Resume")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedSkill.themeColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
    
    // MARK: - Focus Mode Shortcut Banner
    private var focusModeBanner: some View {
        Button {
            FocusManager.shared.triggerFocusModeShortcut()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.indigo.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(Color.indigo)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Trigger 'Study Focus' Mode")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Runs Apple Shortcut to mute distractions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .focusCardStyle()
        }
    }
    
    // MARK: - Band 8 Tip Card
    private var band8TipCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Band 8.0 Strategy", systemImage: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
                
                Spacer()
                
                Button {
                    withAnimation {
                        viewModel.cycleTip()
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(viewModel.currentTip)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .focusCardStyle()
    }
    
    // MARK: - Completion Sheet
    private var completionSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.warning)
                    .padding(.top, 20)
                
                Text("Great Work!")
                    .font(.title.weight(.bold))
                
                Text("You completed your \(viewModel.selectedSkill.rawValue) practice session. This counts toward your IELTS 8.0 goal.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Reflection / Mistakes (Optional)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    
                    TextField("E.g., Made mistakes in T/F/NG; need to watch out for synonyms...", text: $sessionNotes, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color(uiColor: .tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    viewModel.saveCompletedSession(context: modelContext, notes: sessionNotes)
                    sessionNotes = ""
                } label: {
                    Text("Save & Finish")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Session Logged")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
