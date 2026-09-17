# Golden Rules & Project Notes

## Core Engineering Principles
1. **Simplicity First (KISS)**: Prioritize simplicity over cleverness; zero external dependencies.
2. **Eliminate Redundancy (DRY)**: Centralize logic (services, view models) and reuse components cleanly.
3. **Build What’s Needed (YAGNI)**: Native SwiftUI + SwiftData, no unneeded remote backends.
4. **Single Responsibility**: Every module (Timer, Notifications, Focus Shortcuts, Persistence) has one clear job.
5. **Fail Fast & Explicitly**: Validate URL schemes, notification permissions, and timer states gracefully.
6. **Optimize for Readability**: Clean MVVM SwiftUI structure ready for Xcode.
7. **Verify Everything**: Always validate builds and runs before deploying to physical hardware.

---

## Strict Bro Discipline & Anti-Escape Mechanisms
1. **Exam Lock (Apple Guided Access Mode)**:
   - Guided Access is the native iOS mechanism to physically disable the swipe-up home bar and hardware buttons.
   - Setup: iPhone Settings > Accessibility > Guided Access > ON (with Face ID).
   - In IELTS Focus: Triple-click the Side/Power button to lock down the screen during study sessions.
2. **Urgent Abandonment Alarm**:
   - Monitored via `@Environment(\.scenePhase)`. If backgrounded during an active session, a critical alarm notification is armed.
   - Returning after 10+ seconds incurs an in-app reprimand dialog, -25 Discipline XP penalty, and a Slacker Strike.
3. **Focus Mode Direct Setup**:
   - Supports 1-tap jump to native iOS Focus / Do Not Disturb settings (zero shortcut needed).
   - Includes 1-click shortcut creator (`shortcuts://create-shortcut`) to prevent "file doesn't exist" errors.
4. **Strict Bro Game Pass & Accountability Station**:
   - Supports 6 distraction apps: Instagram, TikTok, YouTube, Mobile Games, Telegram, X / Twitter.
   - Strictly limited to 2 passes per day max.
   - Direct launch via URL schemes (`instagram://`, `snssdk1233://`, `youtube://`, etc.).
   - Return Check-In modal awards +30 Discipline XP for on-time return or penalizes -50 XP + 1 Slacker Strike for overtime.
   - 3 strikes lock Game Pass privileges for 24 hours.

---

## Deployment & Sideloading Notes
- **IPA File**: `c:\FOCUS\IELTSFocus.ipa` (compiled automatically via GitHub Actions runner).
- **Sideloadly / AltStore**: Drag and drop `IELTSFocus.ipa` into Sideloadly connected to your iPhone 15 Pro Max.
- **7-Day Sideload Refresh**: Re-sign and reinstall via Sideloadly once a week under a free Apple ID.
