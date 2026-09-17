import SwiftUI

struct DistractionAllowanceView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMinutes: Int = 10
    @State private var isBreakActive: Bool = false
    @State private var remainingSeconds: Int = 600
    @State private var breakTimer: Timer? = nil
    
    private let minutePresets = [5, 10, 15, 20, 30]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Banner
                    headerSection
                    
                    if !isBreakActive {
                        // Duration Selector
                        durationSelectorSection
                        
                        // Strict Commitment Button
                        Button {
                            startBreak()
                        } label: {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                Text("I Swear I'll Stop After \(selectedMinutes) Minutes")
                                    .fontWeight(.heavy)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    } else {
                        // Active Break Countdown
                        activeBreakSection
                        
                        // End Early Button
                        Button {
                            endBreak()
                        } label: {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("Enough Slacking — Back to Study Now")
                                    .fontWeight(.heavy)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    
                    // Screen Time Quick Helper
                    screenTimeTipSection
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Strict Bro's Game Pass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 76, height: 76)
                
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.purple)
            }
            .padding(.top, 8)
            
            Text("Strict Bro's Game Pass 🥊")
                .font(.title2.weight(.heavy))
            
            Text("You want to play games? Be real with yourself: does scrolling TikTok get you Band 8.0? Fine, take a timed pass. But when the buzzer sounds, phone goes face down.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Duration Selector
    private var durationSelectorSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose your allowance (don't push it bro):")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                ForEach(minutePresets, id: \.self) { mins in
                    let isSelected = selectedMinutes == mins
                    Button {
                        selectedMinutes = mins
                    } label: {
                        VStack(spacing: 2) {
                            Text("\(mins)m")
                                .font(.subheadline.weight(.heavy))
                            if mins >= 30 {
                                Text("risky")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.orange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isSelected ? Color.purple : Color(uiColor: .secondarySystemGroupedBackground))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
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
            Text("CLOCK IS TICKING BRO")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.purple)
                .tracking(1.4)
            
            Text(formattedTime)
                .font(.system(size: 54, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            Text("Enjoy your quick break. When this hits zero, the alarm will blast and you're back to IELTS prep. No snoozing.")
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
    
    // MARK: - Screen Time Helper
    private var screenTimeTipSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.title2)
                .foregroundStyle(.purple)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Lock yourself out for real")
                    .font(.subheadline.weight(.bold))
                Text("Open Screen Time to put strict 1-min App Limits on games & social.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Settings") {
                if let url = URL(string: "App-Prefs:root=SCREEN_TIME"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.caption.weight(.heavy))
            .foregroundStyle(.purple)
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private var formattedTime: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func startBreak() {
        remainingSeconds = selectedMinutes * 60
        isBreakActive = true
        
        NotificationService.shared.scheduleDistractionBreakAlert(afterMinutes: selectedMinutes)
        
        breakTimer?.invalidate()
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func endBreak() {
        breakTimer?.invalidate()
        breakTimer = nil
        isBreakActive = false
        NotificationService.shared.cancelDistractionBreakAlert()
        dismiss()
    }
}

#Preview {
    DistractionAllowanceView()
}
