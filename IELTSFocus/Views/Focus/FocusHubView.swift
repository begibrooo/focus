import SwiftUI

struct FocusHubView: View {
    @State private var showFrictionGate = false
    @State private var showingShortcutGuide = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Shield Card
                    heroDistractionShield
                    
                    // Quick Action Tools
                    quickActionsGrid
                    
                    // Cognitive Friction Tool
                    frictionChallengeBanner
                    
                    // Setup Instructions for Free iOS Sideloading
                    freeSideloadGuideCard
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Focus & Anti-Distraction")
            .sheet(isPresented: $showFrictionGate) {
                FrictionGateView(onConfirmExit: {
                    // Reset or dismiss
                })
            }
        }
    }
    
    // MARK: - Hero Card
    private var heroDistractionShield: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Zero-Distraction Environment")
                        .font(.title3.weight(.bold))
                    Text("Powered by native iOS Focus Mode & Screen Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                    .font(.system(size: 38))
                    .foregroundStyle(Theme.primary)
            }
            
            Divider()
            
            Text("Because this is sideloaded without paid Apple Developer entitlements, app blocking is enforced by your iPhone's native Screen Time and Focus Mode. Tap below to launch them immediately.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .focusCardStyle()
    }
    
    // MARK: - Quick Action Grid
    private var quickActionsGrid: some View {
        VStack(spacing: 12) {
            // Screen Time Deep Link
            Button {
                FocusManager.shared.openScreenTimeSettings()
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "hourglass.badge.plus")
                            .font(.title3)
                            .foregroundStyle(Color.purple)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Open Screen Time Settings")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("Configure App Limits on Games & Social Apps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    Image(systemName: "arrow.up.forward.app")
                        .foregroundStyle(.secondary)
                }
                .focusCardStyle()
            }
            
            // Shortcuts Focus Mode Launcher
            Button {
                FocusManager.shared.triggerFocusModeShortcut()
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.indigo.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "bolt.fill")
                            .font(.title3)
                            .foregroundStyle(Color.indigo)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trigger 'Study Focus' Shortcut")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("Runs your iOS Focus Mode to mute all notifications")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .focusCardStyle()
            }
        }
    }
    
    // MARK: - Friction Challenge Banner
    private var frictionChallengeBanner: some View {
        Button {
            showFrictionGate = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.warning.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "hand.raised.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.warning)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Emergency Friction Gate")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Craving social media? Take the 15s challenge")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .focusCardStyle()
        }
    }
    
    // MARK: - Sideload Guide Card
    private var freeSideloadGuideCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recommended 3-Minute Setup", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(Theme.accent)
            
            VStack(alignment: .leading, spacing: 10) {
                guideStep(
                    number: "1",
                    title: "Create 'Study Focus' Shortcut",
                    desc: "Open Apple Shortcuts app > Add action: 'Set Focus' > Choose Do Not Disturb or Study > Name the shortcut exactly 'Study Focus'."
                )
                
                guideStep(
                    number: "2",
                    title: "Set Screen Time App Limits",
                    desc: "Tap 'Open Screen Time Settings' above > App Limits > Add Limit for Social & Games > Set to 1 min with 'Block at end of limit'."
                )
                
                guideStep(
                    number: "3",
                    title: "AltStore 7-Day Auto-Refresh",
                    desc: "Keep AltServer running on your computer on the same Wi-Fi network to let AltStore renew your 7-day sideload certificate automatically."
                )
            }
        }
        .focusCardStyle()
    }
    
    private func guideStep(number: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Theme.primary)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
