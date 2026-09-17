import SwiftUI

struct ShortcutSetupGuideView: View {
    @Environment(\.dismiss) private var dismiss
    let shortcutName: String
    
    @State private var testStatus: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Banner
                    HStack(spacing: 16) {
                        Image(systemName: "bolt.badge.automatic.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.indigo)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("1-Minute Setup")
                                .font(.title3.weight(.bold))
                            Text("Why did you see 'File / Shortcut doesn't exist'?")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.indigo)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.indigo.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    Text("Apple Shortcuts requires you to create the shortcut once before our app can trigger it. Or you can simply turn on Do Not Disturb directly:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Quick Action 1: Instant No-Shortcut Option
                    Button {
                        FocusShortcutService.openFocusSettings()
                    } label: {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Option A: Instant iOS Focus Settings")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                Text("No shortcut needed. Turn on Do Not Disturb with 1 tap.")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Quick Action 2: 1-Tap Create in Shortcuts App
                    Button {
                        FocusShortcutService.openCreateShortcut()
                    } label: {
                        HStack {
                            Image(systemName: "plus.square.fill")
                                .foregroundStyle(.indigo)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Option B: Tap to Create '\(shortcutName)'")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Text("Opens Apple Shortcuts ready to add 'Set Focus'.")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(Color.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // Steps
                    VStack(alignment: .leading, spacing: 14) {
                        Text("3 STEPS TO CREATE IN APPLE SHORTCUTS:")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(.secondary)
                            .tracking(1.2)
                        
                        stepRow(
                            stepNumber: "1",
                            title: "Tap + New Action",
                            description: "In the Shortcuts app, tap the '+' to add an action."
                        )
                        
                        stepRow(
                            stepNumber: "2",
                            title: "Add 'Set Focus'",
                            description: "Search for 'Set Focus' and choose your 'Study' or 'Do Not Disturb' Focus mode."
                        )
                        
                        stepRow(
                            stepNumber: "3",
                            title: "Rename to '\(shortcutName)'",
                            description: "Tap the shortcut title at top, select Rename, and name it exactly '\(shortcutName)'."
                        )
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Test Shortcut Button
                    Button {
                        let success = FocusShortcutService.runShortcut(named: shortcutName)
                        if success {
                            testStatus = "Triggered! If it opened Shortcuts, you're set."
                        } else {
                            testStatus = "Could not launch. Please create it first in Shortcuts."
                        }
                    } label: {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Test Running '\(shortcutName)'")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.primary.opacity(0.06))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if let status = testStatus {
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Focus Mode Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func stepRow(stepNumber: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(stepNumber)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Color.indigo)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    ShortcutSetupGuideView(shortcutName: "Study Focus")
}
