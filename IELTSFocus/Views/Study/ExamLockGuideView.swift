import SwiftUI

struct ExamLockGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.15))
                                .frame(width: 76, height: 76)
                            
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 38))
                                .foregroundStyle(.red)
                        }
                        
                        Text("Exam Lock Mode 🔒")
                            .font(.title2.weight(.heavy))
                        
                        Text("iOS sandbox prevents apps from trapping you, BUT Apple has an official unbreakable solution: **Guided Access**. Triple-click your side button to physically lock your iPhone 15 Pro Max inside IELTS Focus.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    
                    // Quick Action: Open Accessibility Settings
                    Button {
                        openAccessibilitySettings()
                    } label: {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("1-Tap: Open iOS Accessibility Settings")
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                        }
                        .padding()
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // 3 Easy Setup Steps
                    VStack(alignment: .leading, spacing: 16) {
                        Text("HOW TO ENABLE (ONE TIME SETUP):")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(.secondary)
                            .tracking(1.2)
                        
                        stepCard(
                            number: "1",
                            title: "Turn ON Guided Access",
                            bodyText: "In iPhone Settings, go to **Accessibility** > scroll to **Guided Access** > toggle it **ON**.",
                            icon: "hand.tap.fill"
                        )
                        
                        stepCard(
                            number: "2",
                            title: "Set Passcode / Face ID",
                            bodyText: "Tap 'Passcode Settings' and turn on **Face ID** so only you can unlock it when the exam is over.",
                            icon: "faceid"
                        )
                        
                        stepCard(
                            number: "3",
                            title: "Triple-Click Side Button in IELTS Focus",
                            bodyText: "Whenever you start a study session, **triple-click the side/power button**. The home swipe bar will freeze. You CANNOT leave.",
                            icon: "iphone.radiowaves.left.and.right"
                        )
                    }
                    
                    // Strict Bro Reminder
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Strict Bro's Rule:")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.orange)
                            Text("If you swipe out of IELTS Focus without Exam Lock, our **Abandonment Siren** will blast your speakers in 10 seconds. You have been warned.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Exam Lock Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Got It") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func stepCard(number: String, title: String, bodyText: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 32, height: 32)
                Text(number)
                    .font(.subheadline.weight(.heavy))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: icon)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                
                Text(LocalizedStringKey(bodyText))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func openAccessibilitySettings() {
        let candidateURLs = [
            "App-Prefs:root=ACCESSIBILITY",
            "prefs:root=ACCESSIBILITY",
            UIApplication.openSettingsURLString
        ]
        
        for urlString in candidateURLs {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
    }
}

#Preview {
    ExamLockGuideView()
}
