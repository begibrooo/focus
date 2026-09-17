import SwiftUI

struct DistractionApp: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let urlScheme: String
}

struct DistractionAllowanceView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Daily limits & strikes in AppStorage
    @AppStorage("gamePassesUsedToday") private var passesUsedToday: Int = 0
    @AppStorage("lastGamePassDate") private var lastGamePassDate: String = ""
    @AppStorage("slackerStrikes") private var slackerStrikes: Int = 0
    @AppStorage("disciplineXP") private var disciplineXP: Int = 120
    
    // Active Pass State in AppStorage so it survives backgrounding/closing
    @AppStorage("activePassTargetApp") private var activePassTargetApp: String = ""
    @AppStorage("activePassStartTime") private var activePassStartTime: Double = 0
    @AppStorage("activePassAllowedMinutes") private var activePassAllowedMinutes: Int = 0
    @AppStorage("isPassActive") private var isPassActive: Bool = false
    
    @State private var selectedMinutes: Int = 10
    @State private var selectedAppId: String = "instagram"
    @State private var remainingSeconds: Int = 600
    @State private var breakTimer: Timer? = nil
    
    // Return Check-In State
    @State private var showReturnCheckIn: Bool = false
    @State private var returnWasOnTime: Bool = true
    @State private var actualMinutesTaken: Int = 0
    
    private let minutePresets = [5, 10, 15, 20]
    private let maxDailyPasses: Int = 2
    
    private let supportedApps: [DistractionApp] = [
        DistractionApp(id: "instagram", name: "Instagram", icon: "camera.fill", color: .pink, urlScheme: "instagram://app"),
        DistractionApp(id: "tiktok", name: "TikTok", icon: "play.rectangle.fill", color: .cyan, urlScheme: "snssdk1233://"),
        DistractionApp(id: "youtube", name: "YouTube", icon: "play.tv.fill", color: .red, urlScheme: "youtube://"),
        DistractionApp(id: "x", name: "X / Twitter", icon: "bubble.left.and.bubble.right.fill", color: .blue, urlScheme: "twitter://"),
        DistractionApp(id: "telegram", name: "Telegram", icon: "paperplane.fill", color: .teal, urlScheme: "tg://"),
        DistractionApp(id: "games", name: "Mobile Games", icon: "gamecontroller.fill", color: .purple, urlScheme: "itms-apps://")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Status
                    headerSection
                    
                    // Daily Pass & Strike Counter Cards
                    statsStatusRow
                    
                    if isPassActive {
                        // Active Pass Countdown
                        activeBreakSection
                        
                        // End Early Button
                        Button {
                            completeAndReturnEarly()
                        } label: {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("Enough Slacking — Back to Study Now (+20 XP)")
                                    .fontWeight(.heavy)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    } else if passesUsedToday >= maxDailyPasses {
                        // Locked Out Card
                        lockedOutCard
                    } else if slackerStrikes >= 3 {
                        // Striken Out Card
                        strikesLockedCard
                    } else {
                        // App Selector
                        appPickerSection
                        
                        // Duration Selector
                        durationSelectorSection
                        
                        // Launch & Activate Button
                        Button {
                            activatePassAndLaunch()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.up.right.video.fill")
                                Text("Activate \(selectedMinutes)m Pass & Launch \(selectedAppName)")
                                    .fontWeight(.heavy)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedAppColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: selectedAppColor.opacity(0.3), radius: 8, y: 4)
                        }
                    }
                    
                    // Guided Access tip
                    guidedAccessTip
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Strict Bro's Game Pass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                checkDayReset()
                checkExistingPass()
            }
            .sheet(isPresented: $showReturnCheckIn) {
                returnCheckInSheet
            }
        }
    }
    
    // MARK: - Selected App Details
    private var selectedAppName: String {
        supportedApps.first(where: { $0.id == selectedAppId })?.name ?? "App"
    }
    
    private var selectedAppColor: Color {
        supportedApps.first(where: { $0.id == selectedAppId })?.color ?? .purple
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.purple)
            }
            .padding(.top, 4)
            
            Text("Strict Bro's Game Pass 🥊")
                .font(.title2.weight(.heavy))
            
            Text("No endless scrolling. Pick 1 app, pick your exact minutes. The second your pass expires, our siren fires and you return. Disobey, and strikes accumulate.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Stats Status Row
    private var statsStatusRow: some View {
        HStack(spacing: 12) {
            // Passes Remaining
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "ticket.fill")
                        .foregroundStyle(.purple)
                    Text("Daily Passes")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                Text("\(maxDailyPasses - passesUsedToday) left today")
                    .font(.subheadline.weight(.heavy))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            // Slacker Strikes
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(slackerStrikes > 0 ? .red : .orange)
                    Text("Slacker Strikes")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                Text("\(slackerStrikes) / 3 max")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(slackerStrikes > 0 ? .red : .primary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    // MARK: - App Picker Section
    private var appPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1. CHOOSE YOUR TARGET DISTRACTION:")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.secondary)
                .tracking(1.2)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(supportedApps) { app in
                    let isSelected = selectedAppId == app.id
                    Button {
                        selectedAppId = app.id
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: app.icon)
                                .font(.title3)
                                .foregroundStyle(app.color)
                                .frame(width: 28)
                            
                            Text(app.name)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(app.color)
                            }
                        }
                        .padding(12)
                        .background(isSelected ? app.color.opacity(0.12) : Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? app.color : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Duration Selector Section
    private var durationSelectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2. SET STRICT DURATION (DO NOT OVERTIME):")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.secondary)
                .tracking(1.2)
            
            HStack(spacing: 8) {
                ForEach(minutePresets, id: \.self) { mins in
                    let isSelected = selectedMinutes == mins
                    Button {
                        selectedMinutes = mins
                    } label: {
                        VStack(spacing: 2) {
                            Text("\(mins)m")
                                .font(.subheadline.weight(.heavy))
                            Text(mins <= 10 ? "Safe" : "Risky")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(mins <= 10 ? .green : .orange)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isSelected ? selectedAppColor : Color(uiColor: .secondarySystemGroupedBackground))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? selectedAppColor : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Active Break Countdown
    private var activeBreakSection: some View {
        VStack(spacing: 12) {
            Text("PASS RUNNING FOR \(activePassTargetApp.uppercased())")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.purple)
                .tracking(1.4)
            
            Text(formattedTime)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            Text("Enjoy your break. When this hits zero, the alarm sounds! Open IELTS Focus immediately to avoid a Slacker Strike.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Locked Out Cards
    private var lockedOutCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.slash.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text("Daily Passes Depleted (2/2)")
                .font(.headline.weight(.bold))
            
            Text("Strict Bro's rule: Max 2 passes per day. You already used both today. No more games until tomorrow. Band 8.0 requires discipline.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var strikesLockedCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "xmark.octagon.fill")
                .font(.system(size: 44))
                .foregroundStyle(.red)
            
            Text("PASS PRIVILEGES REVOKED (3 Strikes)")
                .font(.headline.weight(.heavy))
                .foregroundStyle(.red)
            
            Text("You broke your word 3 times by returning late. Strict Bro has locked your Game Pass. Complete 2 full IELTS sessions to clear your record.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Return Check-In Sheet
    private var returnCheckInSheet: some View {
        VStack(spacing: 20) {
            if returnWasOnTime {
                ZStack {
                    Circle().fill(Color.green.opacity(0.15)).frame(width: 80, height: 80)
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 40)).foregroundStyle(.green)
                }
                
                Text("Word Kept, Bro! 🏅")
                    .font(.title2.weight(.heavy))
                
                Text("You took \(actualMinutesTaken)m on a \(activePassAllowedMinutes)m pass and came right back to IELTS Focus. That is real discipline.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("+30 Discipline XP Awarded")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.green)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
            } else {
                ZStack {
                    Circle().fill(Color.red.opacity(0.15)).frame(width: 80, height: 80)
                    Image(systemName: "exclamationmark.octagon.fill").font(.system(size: 40)).foregroundStyle(.red)
                }
                
                Text("SLACKER DETECTED! 🚨")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(.red)
                
                Text("You took \(actualMinutesTaken)m on a \(activePassAllowedMinutes)m pass! That's \(actualMinutesTaken - activePassAllowedMinutes) extra minutes wasted on scrolling.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("+1 Slacker Strike Recorded | -50 XP")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Button {
                showReturnCheckIn = false
                dismiss()
            } label: {
                Text("Back to IELTS Preparation")
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(returnWasOnTime ? Color.green : Color.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(24)
    }
    
    // MARK: - Guided Access Tip
    private var guidedAccessTip: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.title3)
                .foregroundStyle(.purple)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Lock yourself down")
                    .font(.caption.weight(.bold))
                Text("Triple-click side button during IELTS study to prevent accidental swipes.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.purple.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var formattedTime: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    // MARK: - Logic & Actions
    
    private func checkDayReset() {
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
        let todayString = String(today)
        if lastGamePassDate != todayString {
            lastGamePassDate = todayString
            passesUsedToday = 0
        }
    }
    
    private func checkExistingPass() {
        guard isPassActive else { return }
        
        let elapsed = Int(Date().timeIntervalSince1970 - activePassStartTime)
        let totalAllowedSeconds = activePassAllowedMinutes * 60
        
        if elapsed > totalAllowedSeconds {
            // User returned after time expired!
            actualMinutesTaken = max(1, elapsed / 60)
            returnWasOnTime = false
            slackerStrikes = min(3, slackerStrikes + 1)
            disciplineXP = max(0, disciplineXP - 50)
            isPassActive = false
            NotificationService.shared.cancelDistractionBreakAlert()
            showReturnCheckIn = true
        } else {
            // Still in progress
            remainingSeconds = max(0, totalAllowedSeconds - elapsed)
            startCountdownTimer()
        }
    }
    
    private func activatePassAndLaunch() {
        passesUsedToday += 1
        activePassTargetApp = selectedAppName
        activePassAllowedMinutes = selectedMinutes
        activePassStartTime = Date().timeIntervalSince1970
        isPassActive = true
        remainingSeconds = selectedMinutes * 60
        
        // Schedule notification alarm
        NotificationService.shared.scheduleDistractionBreakAlert(afterMinutes: selectedMinutes)
        
        // Launch target app if possible
        if let app = supportedApps.first(where: { $0.id == selectedAppId }),
           let url = URL(string: app.urlScheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        
        startCountdownTimer()
    }
    
    private func startCountdownTimer() {
        breakTimer?.invalidate()
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func completeAndReturnEarly() {
        breakTimer?.invalidate()
        breakTimer = nil
        let elapsed = Int(Date().timeIntervalSince1970 - activePassStartTime)
        actualMinutesTaken = max(1, elapsed / 60)
        returnWasOnTime = true
        disciplineXP += 30
        isPassActive = false
        NotificationService.shared.cancelDistractionBreakAlert()
        showReturnCheckIn = true
    }
}

#Preview {
    DistractionAllowanceView()
}
