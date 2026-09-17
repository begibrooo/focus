import SwiftUI

struct FrictionGateView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onConfirmExit: () -> Void
    
    @State private var cooldownSeconds: Int = 15
    @State private var timerActive: Bool = true
    @State private var userInput: String = ""
    @State private var isBreathingIn: Bool = false
    
    private let targetPhrase = "I choose my IELTS 8.0 goal over momentary distraction."
    
    private var isTextMatched: Bool {
        userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == targetPhrase.lowercased()
    }
    
    private var canExit: Bool {
        cooldownSeconds == 0 && isTextMatched
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Warning Icon
                    ZStack {
                        Circle()
                            .fill(Theme.warning.opacity(0.15))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.warning)
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 8) {
                        Text("Pause Before You Give In")
                            .font(.title2.weight(.bold))
                        
                        Text("Distraction is temporary; your IELTS 8.0 certificate is life-changing. Take 15 seconds to breathe.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Breathing Visualizer & Cooldown
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(Theme.primary.opacity(0.2), lineWidth: 4)
                                .frame(width: 110, height: 110)
                                .scaleEffect(isBreathingIn ? 1.15 : 0.95)
                                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isBreathingIn)
                            
                            VStack(spacing: 2) {
                                Text("\(cooldownSeconds)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.primary)
                                
                                Text("seconds")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(height: 120)
                        
                        Text(cooldownSeconds > 0 ? "Breathe slowly while the timer counts down..." : "Timer complete. Complete the phrase below:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .focusCardStyle()
                    
                    // Typing Friction Gate
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Type this affirmation to unlock exit:")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        Text("\"\(targetPhrase)\"")
                            .font(.callout.weight(.medium))
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        TextField("Type exact phrase here...", text: $userInput, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(uiColor: .tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        if !userInput.isEmpty {
                            HStack {
                                Image(systemName: isTextMatched ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(isTextMatched ? Theme.success : Theme.danger)
                                Text(isTextMatched ? "Phrase matches perfectly." : "Phrase does not match yet.")
                                    .font(.caption)
                                    .foregroundStyle(isTextMatched ? Theme.success : Theme.danger)
                            }
                        }
                    }
                    .focusCardStyle()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Stay Focused (Keep Studying)")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.success)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        Button(role: .destructive) {
                            onConfirmExit()
                            dismiss()
                        } label: {
                            Text("Give In & Leave Session")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canExit ? Theme.danger.opacity(0.12) : Color.secondary.opacity(0.08))
                                .foregroundStyle(canExit ? Theme.danger : Color.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canExit)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Friction Gate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isBreathingIn = true
                startCooldown()
            }
        }
    }
    
    private func startCooldown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if cooldownSeconds > 0 {
                cooldownSeconds -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}
