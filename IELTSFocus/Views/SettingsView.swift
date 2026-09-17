import SwiftUI

struct SettingsView: View {
    @AppStorage("focusShortcutName") private var focusShortcutName: String = "Study Focus"
    @AppStorage("enableFrictionGate") private var enableFrictionGate: Bool = true
    @AppStorage("enableVoiceCoach") private var enableVoiceCoach: Bool = true
    @AppStorage("enableSoundEffects") private var enableSoundEffects: Bool = true
    
    // Daily Study Reminder Settings
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled: Bool = false
    @AppStorage("dailyReminderHour") private var dailyReminderHour: Int = 19 // Default 7:00 PM
    @AppStorage("dailyReminderMinute") private var dailyReminderMinute: Int = 0
    
    @State private var reminderDate: Date = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showSetupGuide: Bool = false
    @State private var showDistractionAllowance: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Strict Bro Voice Coach & Audio FX
                Section {
                    Toggle("Strict Bro Voice Coach 🗣️", isOn: $enableVoiceCoach)
                    Toggle("Boxing Bells & Sound Effects 🔔", isOn: $enableSoundEffects)
                    
                    Button {
                        AudioService.shared.speakTestVoice()
                    } label: {
                        HStack {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundStyle(.blue)
                            Text("Test Voice Aloud (Hear Strict Bro)")
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    Button {
                        AudioService.shared.playStartBell()
                    } label: {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundStyle(.orange)
                            Text("Test Boxing Bell 🔔")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                } header: {
                    Text("Strict Bro Voice & Audio (Plays in Silent Mode)")
                } footer: {
                    Text("Strict Bro speaks tough love out loud when starting, pausing, and finishing sessions to keep you accountable.")
                }
                
                // Daily Study Reminder Section
                Section {
                    Toggle("Daily Study Reminder", isOn: $dailyReminderEnabled)
                        .onChange(of: dailyReminderEnabled) { _, newValue in
                            updateDailyReminder(enabled: newValue)
                        }
                    
                    if dailyReminderEnabled {
                        DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderDate) { _, newDate in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                dailyReminderHour = components.hour ?? 19
                                dailyReminderMinute = components.minute ?? 0
                                updateDailyReminder(enabled: true)
                            }
                    }
                } header: {
                    Text("Study Reminders")
                } footer: {
                    Text("The app will automatically ping you every day to complete your IELTS practice.")
                }
                
                // Game & Social Media Allowance
                Section {
                    Button {
                        showDistractionAllowance = true
                    } label: {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundStyle(.purple)
                            Text("Game & Social Media Pass")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("Set Budget")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Distraction Time Budget")
                } footer: {
                    Text("Decide how much time you want to spend on games or social media; the app will alert you when time is up.")
                }
                
                // Focus Mode Shortcut Configuration
                Section {
                    HStack {
                        Text("Shortcut Name")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("e.g. Study Focus", text: $focusShortcutName)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                    }
                    
                    Button {
                        FocusShortcutService.runShortcut(named: focusShortcutName)
                    } label: {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundStyle(.indigo)
                            Text("Test Shortcut Now")
                        }
                    }
                    
                    Button {
                        showSetupGuide = true
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(.blue)
                            Text("How to Create Shortcut")
                        }
                    }
                } header: {
                    Text("Focus Mode Integration")
                } footer: {
                    Text("The Study tab will trigger this shortcut using the shortcuts:// URL scheme to turn on your iOS Focus mode.")
                }
                
                // Friction Gate Section
                Section {
                    Toggle("Friction Gate on Early Exit", isOn: $enableFrictionGate)
                } header: {
                    Text("Anti-Distraction & Discipline")
                } footer: {
                    Text("When enabled, stopping an active session requires completing a 10-second unskippable cooldown and typing 'I choose to stay focused'.")
                }
                
                // Screen Time Shortcuts
                Section {
                    Button {
                        openScreenTimeSettings()
                    } label: {
                        HStack {
                            Image(systemName: "hourglass.badge.plus")
                                .foregroundStyle(.purple)
                            Text("Open Screen Time Settings")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("iOS App Blocking")
                } footer: {
                    Text("Jump directly to Screen Time settings to set 1-minute App Limits on social media and games.")
                }
                
                // IELTS Exam Target Info
                Section("IELTS Target") {
                    HStack {
                        Text("Target Overall Band")
                        Spacer()
                        Text("8.0")
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                var components = DateComponents()
                components.hour = dailyReminderHour
                components.minute = dailyReminderMinute
                reminderDate = Calendar.current.date(from: components) ?? Date()
            }
            .sheet(isPresented: $showSetupGuide) {
                ShortcutSetupGuideView(shortcutName: focusShortcutName.isEmpty ? "Study Focus" : focusShortcutName)
            }
            .sheet(isPresented: $showDistractionAllowance) {
                DistractionAllowanceView()
            }
        }
    }
    
    private func updateDailyReminder(enabled: Bool) {
        if enabled {
            NotificationService.shared.scheduleDailyReminder(hour: dailyReminderHour, minute: dailyReminderMinute)
        } else {
            NotificationService.shared.cancelDailyReminder()
        }
    }
    
    private func openScreenTimeSettings() {
        if let prefsUrl = URL(string: "App-Prefs:root=SCREEN_TIME"), UIApplication.shared.canOpenURL(prefsUrl) {
            UIApplication.shared.open(prefsUrl)
        } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

#Preview {
    SettingsView()
}
