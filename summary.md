# Golden Rules & Project Notes

## Core Engineering Principles
1. **Simplicity First (KISS)**: Prioritize simplicity over cleverness; zero external dependencies.
2. **Eliminate Redundancy (DRY)**: Centralize logic (services, view models) and reuse components cleanly.
3. **Build What’s Needed (YAGNI)**: Native SwiftUI + SwiftData, no unneeded remote backends.
4. **Single Responsibility**: Every module (Timer, Notifications, Focus Shortcuts, Persistence) has one clear job.
5. **Fail Fast & Explicitly**: Validate URL schemes, notification permissions, and timer states gracefully.
6. **Optimize for Readability**: Clean MVVM SwiftUI structure ready for Xcode.
7. **Verify Everything**: Always validate simulator runs before deploying to physical hardware.

---

## Deployment & Workflow Notes
- **Simulator First**: Test all UI, countdown timers, and friction gate interactions in the Xcode iOS Simulator before deploying to a physical device for faster iteration.
- **7-Day Sideload Refresh**: Re-sign and reinstall via AltStore or Sideloadly once a week to maintain certificate validity under a free Apple ID.
- **Future Upgrade Path**: If you transition to a paid Apple Developer account ($99/yr) later:
  - 7-day profile expiry is removed (1-year provisioning).
  - Unlocks eligibility to request the `FamilyControls` / `ManagedSettings` entitlement for native, system-enforced app shields.
