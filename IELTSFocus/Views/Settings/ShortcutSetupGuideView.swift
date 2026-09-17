import SwiftUI

struct ShortcutSetupGuideView: View {
    @Environment(\.dismiss) private var dismiss
    let shortcutName: String
    
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
                            Text("Automate Do Not Disturb / Focus Mode")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.indigo.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    Text("Follow these 4 quick steps to create the shortcut in Apple's built-in Shortcuts app:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Steps
                    VStack(spacing: 16) {
                        stepRow(
                            stepNumber: "1",
                            title: "Open Shortcuts App",
                            description: "Open the built-in Shortcuts app on your iPhone or tap the button below."
                        )
                        
                        stepRow(
                            stepNumber: "2",
                            title: "Tap + (New Shortcut)",
                            description: "Tap the '+' icon at the top right of the Shortcuts app to create a new action."
                        )
                        
                        stepRow(
                            stepNumber: "3",
                            title: "Add 'Set Focus' Action",
                            description: "Search for 'Set Focus' in the actions search bar. Set it to turn your 'Study' or 'Do Not Disturb' Focus mode 'On'."
                        )
                        
                        stepRow(
                            stepNumber: "4",
                            title: "Rename to '\(shortcutName)'",
                            description: "Tap the shortcut title at the top, select 'Rename', and name it exactly: '\(shortcutName)'."
                        )
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Direct Link Button
                    Button {
                        FocusShortcutService.openShortcutsApp()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.forward.app")
                            Text("Open Shortcuts App Now")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.top, 8)
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
