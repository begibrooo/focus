import SwiftUI

struct FrictionGateView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onConfirmExit: () -> Void
    let onStayInSession: () -> Void
    
    @State private var countdown: Int = 10
    @State private var userInput: String = ""
    
    private let targetPhrase = "I am disciplined and I will not throw away my IELTS 8.0"
    
    private var isPhraseMatched: Bool {
        userInput.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(targetPhrase) == .orderedSame
    }
    
    private var canExit: Bool {
        countdown == 0 && isPhraseMatched
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Alert Icon & Strict Message
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "exclamationmark.octagon.fill")
                                .font(.system(size: 46))
                                .foregroundStyle(.red)
                        }
                        
                        Text("Bro... Are You Serious? 🛑")
                            .font(.title2.weight(.heavy))
                        
                        Text("You told yourself you're getting Band 8.0 this year, and you want to quit mid-session? Stop running away when it gets difficult. Lock in.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                    // Unskippable 10-Second Cooldown
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color.red.opacity(0.2), lineWidth: 6)
                                .frame(width: 84, height: 84)
                            
                            Text("\(countdown)")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.red)
                        }
                        
                        Text(countdown > 0 ? "Strict Bro Cooldown: Think about your future..." : "Timer over. Admit it below:")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Tough Love Typing Challenge
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Type this affirmation to confirm you're quitting:")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        Text("\"\(targetPhrase)\"")
                            .font(.callout.weight(.bold))
                            .foregroundStyle(.orange)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        TextField("Type exact phrase here...", text: $userInput)
                            .padding(12)
                            .background(Color(uiColor: .tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        if !userInput.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: isPhraseMatched ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(isPhraseMatched ? "Phrase verified. Ready to face the music." : "Doesn't match yet. Spell it out.")
                            }
                            .font(.caption)
                            .foregroundStyle(isPhraseMatched ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            onStayInSession()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text("You're Right Bro, I'm Staying In")
                                    .fontWeight(.heavy)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        Button(role: .destructive) {
                            onConfirmExit()
                            dismiss()
                        } label: {
                            Text("I'm Quitting Anyway (I Know I'm Slacking)")
                                .fontWeight(.semibold)
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(canExit ? Color.red.opacity(0.15) : Color.secondary.opacity(0.08))
                                .foregroundStyle(canExit ? Color.red : Color.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canExit)
                    }
                    .padding(.top, 4)
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Strict Bro Check")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(true)
            .onAppear {
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    FrictionGateView(onConfirmExit: {}, onStayInSession: {})
}
