import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage("focusShortcutName") private var focusShortcutName: String = "Study Focus"
    @AppStorage("enableFrictionGate") private var enableFrictionGate: Bool = true
    @AppStorage("disciplineXP") private var disciplineXP: Int = 120
    @AppStorage("slackerStrikes") private var slackerStrikes: Int = 0
    
    @State private var viewModel = TimerViewModel()
    @State private var showSetupGuide: Bool = false
    @State private var showFrictionGate: Bool = false
    @State private var showDistractionAllowance: Bool = false
    @State private var showExamLockGuide: Bool = false
    @State private var showFocusOptionsDialog: Bool = false
    
    // Background tracking
    @State private var backgroundedAt: Date? = nil
    @State private var showAbandonmentBust: Bool = false
    @State private var abandonmentDuration: Int = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Session Type Picker
                    sessionPickerSection
                    
                    // Circular Progress Timer Ring
                    CircularTimerView(
                        progress: viewModel.progress,
                        formattedTime: viewModel.formattedTime,
                        sessionType: viewModel.selectedType,
                        timerState: viewModel.timerState
                    )
                    .frame(width: 270, height: 270)
                    .padding(.vertical, 4)
                    
                    // Controls (Start / Pause / Resume / Cancel)
                    controlsSection
                    
                    // Exam Lock (Guided Access) Helper Banner
                    examLockBanner
                    
                    // Strict Bro's Game Pass Banner
                    breakPassBanner
                    
                    // Focus Mode Shortcut Trigger Banner
                    focusModeBanner
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("IELTS Focus 🔒")
            .sheet(isPresented: $viewModel.showCompletionView) {
                SessionCompleteView(sessionType: viewModel.selectedType) {
                    saveCompletedSession()
                    viewModel.dismissCompletion()
                }
            }
            .sheet(isPresented: $showSetupGuide) {
                ShortcutSetupGuideView(shortcutName: focusShortcutName.isEmpty ? "Study Focus" : focusShortcutName)
            }
            .sheet(isPresented: $showExamLockGuide) {
                ExamLockGuideView()
            }
            .sheet(isPresented: $showFrictionGate) {
                FrictionGateView(
                    onConfirmExit: {
                        viewModel.cancel()
                    },
                    onStayInSession: {
                        viewModel.resume()
                    }
                )
            }
            .sheet(isPresented: $showDistractionAllowance) {
                DistractionAllowanceView()
            }
            .confirmationDialog(
                "Lock In Focus Mode 🛡️",
                isPresented: $showFocusOptionsDialog,
                titleVisibility: .visible
            ) {
                Button("Option A: Open iOS Focus / DND Settings (1-Tap)") {
                    FocusShortcutService.openFocusSettings()
                }
                Button("Option B: Run '\(focusShortcutName)' Shortcut") {
                    let triggered = FocusShortcutService.runShortcut(named: focusShortcutName)
                    if !triggered {
                        showSetupGuide = true
                    }
                }
                Button("Option C: Create Shortcut in Shortcuts App") {
                    FocusShortcutService.openCreateShortcut()
                }
                Button("View Shortcut Setup Instructions") {
                    showSetupGuide = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Select an option to silence incoming notifications. To avoid 'file doesn't exist' errors, use Option A or create the shortcut first in Option C.")
            }
            .alert("🚨 BRO, YOU ABANDONED THE APP!", isPresented: $showAbandonmentBust) {
                Button("I'm Back (No Excuses)", role: .cancel) { }
            } message: {
                Text("You left IELTS Focus for \(abandonmentDuration) seconds while your timer was running! Strict Bro detected this. Triple-click your side button for Exam Lock so you can't swipe away!")
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(to: newPhase)
            }
        }
    }
    
    // MARK: - Scene Phase / Abandonment Monitor
    private func handleScenePhaseChange(to phase: ScenePhase) {
        if phase == .background {
            if viewModel.timerState == .running {
                backgroundedAt = Date()
                NotificationService.shared.scheduleAbandonmentWarning()
            }
        } else if phase == .active {
            if let bgDate = backgroundedAt, viewModel.timerState == .running {
                let elapsed = Int(Date().timeIntervalSince(bgDate))
                NotificationService.shared.cancelAbandonmentWarning()
                backgroundedAt = nil
                
                if elapsed >= 10 {
                    abandonmentDuration = elapsed
                    disciplineXP = max(0, disciplineXP - 25)
                    slackerStrikes = min(3, slackerStrikes + 1)
                    showAbandonmentBust = true
                }
            } else {
                NotificationService.shared.cancelAbandonmentWarning()
                backgroundedAt = nil
            }
        }
    }
    
    private func handleCancelTap() {
        if enableFrictionGate && (viewModel.timerState == .running || viewModel.timerState == .paused) {
            viewModel.pause()
            showFrictionGate = true
        } else {
            viewModel.cancel()
        }
    }
    
    private func saveCompletedSession() {
        let newSession = StudySession(
            date: Date(),
            sessionType: viewModel.selectedType,
            durationMinutes: viewModel.selectedType.durationMinutes
        )
        modelContext.insert(newSession)
        disciplineXP += 50
    }
    
    // MARK: - Exam Lock Banner (Guided Access)
    private var examLockBanner: some View {
        Button {
            showExamLockGuide = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(Color.red)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Exam Lock (Triple-Click)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.primary)
                        Text("CAN'T CLOSE")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Text("Guided Access physically disables the swipe-up home bar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Strict Bro's Break Pass Banner
    private var breakPassBanner: some View {
        Button {
            showDistractionAllowance = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "gamecontroller.fill")
                        .foregroundStyle(Color.purple)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Strict Bro's Game Pass 🥊")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.primary)
                        Text("MAX 2/DAY")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.purple)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Text("Instagram, TikTok, Games. Timed pass with return check-in.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Focus Mode Shortcut Banner
    private var focusModeBanner: some View {
        Button {
            showFocusOptionsDialog = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.indigo.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundStyle(Color.indigo)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Lock In Focus Mode 🛡️")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text("1-Tap DND Settings or Shortcuts automation")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Session Type Picker
    private var sessionPickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pick Your Battle (Target Band 8.0)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(IELTSSessionType.allCases) { type in
                        let isSelected = viewModel.selectedType == type
                        
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.selectedType = type
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: type.icon)
                                Text("\(type.rawValue) (\(type.durationMinutes)m)")
                                    .font(.subheadline.weight(.heavy))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(isSelected ? type.themeColor : Color(uiColor: .secondarySystemGroupedBackground))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .clipShape(Capsule())
                            .shadow(color: isSelected ? type.themeColor.opacity(0.3) : Color.clear, radius: 6, y: 3)
                        }
                        .disabled(viewModel.timerState == .running || viewModel.timerState == .paused)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Controls Section
    private var controlsSection: some View {
        HStack(spacing: 16) {
            if viewModel.timerState == .idle {
                Button {
                    viewModel.start()
                } label: {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text("Lock In: Start \(viewModel.selectedType.rawValue)")
                            .fontWeight(.heavy)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedType.themeColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            } else {
                // Cancel Button (Protected by Friction Gate if enabled)
                Button {
                    handleCancelTap()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .frame(width: 56, height: 56)
                        .background(Color.red.opacity(0.12))
                        .clipShape(Circle())
                }
                
                // Pause / Resume Button
                Button {
                    if viewModel.timerState == .running {
                        viewModel.pause()
                    } else {
                        viewModel.resume()
                    }
                } label: {
                    HStack {
                        Image(systemName: viewModel.timerState == .running ? "pause.fill" : "play.fill")
                        Text(viewModel.timerState == .running ? "Pause" : "Resume (No Slacking)")
                            .fontWeight(.heavy)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedType.themeColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(.top, 4)
    }
}

#Preview {
    StudyView()
}
