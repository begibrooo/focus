# IELTS Focus — iOS App (Swift & SwiftUI)

A personal study-focus app designed to reach **IELTS 8.0** by combining structured practice timers with distraction shields (iOS Focus Mode, Screen Time deep links, and cognitive friction gates).

Designed specifically for **free sideloading** via AltStore or Sideloadly (no paid Apple Developer account needed, zero external dependencies, 100% on-device SwiftData persistence).

---

## Architecture & Project Structure

```
IELTSFocus/
├── IELTSFocusApp.swift              // App entry point with SwiftData ModelContainer
├── Models/
│   ├── IELTSSkill.swift             // IELTS modules (Listening, Reading, Writing 1 & 2, Speaking) & Band 8 tips
│   └── StudySession.swift           // SwiftData @Model for session tracking
├── Services/
│   ├── NotificationManager.swift    // UserNotifications for session end alerts
│   └── FocusManager.swift           // Deep links for Shortcuts & Screen Time
├── ViewModels/
│   ├── TimerViewModel.swift         // Observable timer countdown state machine
│   └── StatsViewModel.swift         // Streaks, weekly aggregates, skill metrics
├── Views/
│   ├── MainTabView.swift            // Primary Tab Navigation (Timer, Focus Shield, Log)
│   ├── Timer/
│   │   ├── TimerView.swift          // Main countdown view with Band 8 strategies
│   │   └── CircularProgressView.swift // Animated gradient progress ring
│   ├── Focus/
│   │   ├── FocusHubView.swift       // Screen Time deep link & Focus shortcut launcher
│   │   └── FrictionGateView.swift   // 15s cooldown & typing challenge screen
│   └── Stats/
│       ├── StatsView.swift          // Day streak counter, distribution bar, & session history
│       └── SessionRowView.swift     // Session entry row with delete actions
└── Utilities/
    └── Theme.swift                  // IELTS focus color palette & card styling
```

---

## 5-Minute Xcode Setup Instructions (Mac)

1. **Create New Project in Xcode**:
   - Open Xcode > **File** > **New** > **Project...**
   - Select **iOS** > **App**.
   - Project Name: `IELTSFocus`.
   - Interface: **SwiftUI**.
   - Language: **Swift**.
   - Storage: **SwiftData** (or None; our files define the schema directly).
   - Minimum Deployment Target: **iOS 17.0+**.

2. **Add the Source Files**:
   - Drag the `IELTSFocus` folder from this repo directly into the Xcode Project Navigator.
   - Choose *"Copy items if needed"* and check your app target.

3. **Configure Signing (Free Apple ID)**:
   - Click the top-level project in Xcode > Select the `IELTSFocus` target.
   - Go to **Signing & Capabilities**.
   - Check **Automatically manage signing**.
   - Under **Team**, select your **Personal Team** (your free Apple ID).
   - Xcode will generate a free provisioning profile valid for 7 days.

4. **Add URL Schemes in Info.plist (Optional for deep linking)**:
   - Under target **Info** > **URL Types**, you can register queries if needed.
   - In `LSApplicationQueriesSchemes`, add `shortcuts` and `app-prefs`.

---

## Sideloading to iPhone via AltStore / Sideloadly

### Option A: AltStore
1. Connect your iPhone to your Mac via USB / Wi-Fi.
2. In Xcode, select your physical iPhone as the build target and press **Run** (Cmd + R).
3. On your iPhone, go to **Settings > General > VPN & Device Management**, tap your Apple ID, and tap **Trust**.
4. Open **AltStore** on your iPhone. AltStore will automatically refresh the 7-day certificate whenever you are on the same Wi-Fi network as AltServer.

### Option B: Sideloadly / Direct .ipa export
1. In Xcode: **Product** > **Archive** > **Distribute App** > **Custom** > **Development**.
2. Export the `.ipa` file.
3. Drag the `.ipa` into **Sideloadly**, enter your free Apple ID credentials, and click **Start**.

---

## How the Core Features Work

1. **IELTS Presets**:
   - **Listening**: 40 min (30m audio simulation + 10m review)
   - **Reading**: 60 min (strict 3-passage simulation)
   - **Writing Task 1**: 20 min (report/letter)
   - **Writing Task 2**: 40 min (discursive essay)
   - **Speaking**: 15 min (Part 1, 2, 3 speed drills)
2. **Band 8.0 Tips**: Rotating strategies (collocations, T/F/NG rules, distractor awareness) display during countdowns.
3. **Local Notifications**: When the session ends, `UserNotifications` triggers a chime and completion message even if your phone was locked.
4. **Distraction Shield**:
   - **Screen Time**: Deep links into `App-Prefs:root=SCREEN_TIME` so you can set 1-minute App Limits on social media and games.
   - **Study Focus Mode**: Triggers Apple Shortcuts to switch on your iPhone's Do Not Disturb / Study focus.
5. **Friction Gate**: If you attempt to stop the timer early or crave a distraction, a 15-second breathing cooldown and verbatim typing affirmation screen challenges the impulse before letting you exit.
6. **Local Persistence & Streaks**: Every completed session is saved in SwiftData. Streaks and study hours compute automatically with zero internet or server connection.
