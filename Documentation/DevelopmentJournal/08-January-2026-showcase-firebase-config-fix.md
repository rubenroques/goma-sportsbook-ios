## Date
08 January 2026

### Project / Branch
sportsbook-ios / feature/showcase-white-label

### Goals for this session
- Diagnose and fix Showcase app black screen issue
- Configure correct Firebase settings for Showcase target

### Achievements
- [x] Diagnosed black screen root cause: Firebase Realtime Database connection failing
  - `Bootstrap.boot()` waits for `maintenanceModePublisher` to emit `.off`
  - If Firebase never connects, `.unknown` case does nothing → window never visible
- [x] Fixed GoogleService-Info.plist: Replaced with correct plist (bundle ID: `com.gomagaming.goma`)
- [x] Fixed bundle identifier: Updated Showcase target from `com.gomagaming.Showcase` to `com.gomagaming.goma`
- [x] Fixed Firebase Realtime Database URL: Changed from BetssonFrance URL to `https://goma-sportsbook.europe-west1.firebasedatabase.app/`
- [x] Showcase app now launches successfully

### Issues / Bugs Hit
- [x] Black screen on launch - Firebase was misconfigured (wrong bundle ID, wrong database URL)
- [ ] Missing fonts warning in logs: CircularStd-Bold.ttf, CircularStd-Book.ttf, Inconsolata-Regular.ttf (non-blocking, XIB references)
- [ ] App group entitlement warnings: "client is not entitled" (non-blocking)

### Key Decisions
- Used `com.gomagaming.goma` as bundle ID to match existing Firebase project
- Firebase Database URL: `https://goma-sportsbook.europe-west1.firebasedatabase.app/`

### Experiments & Notes
- Bootstrap flow analysis:
  ```
  AppDelegate.didFinishLaunching
    → Bootstrap.boot()
      → businessSettingsSocket.connectAfterAuth()
      → maintenanceModePublisher.sink {
          .on → showMaintenanceScreen
          .off → makeKeyAndVisible() ← window becomes visible here
          .unknown → break (does nothing!)
        }
  ```
- If Firebase Auth fails or Database doesn't respond, app stays on black screen indefinitely
- The XIB files reference CircularStd fonts but only Roboto fonts are in the bundle (cosmetic issue)

### Useful Files / Links
- [TargetVariables.swift](../../Showcase/Clients/Showcase/TargetVariables.swift) - Firebase URL config
- [GoogleService-Info.plist](../../Showcase/Clients/Showcase/Misc/GoogleService-Info.plist) - Firebase config
- [Bootstrap.swift](../../Showcase/App/Boot/Bootstrap.swift) - App boot flow
- [RealtimeSocketClient.swift](../../Showcase/App/Services/RealtimeSocketClient.swift) - Firebase RTDB connection
- [Previous Session: Assets & Cleanup](./08-January-2026-showcase-assets-and-cleanup.md)

### Next Steps
1. Consider adding timeout fallback in Bootstrap to show UI even if Firebase is slow
2. Fix or remove CircularStd font references from XIB files
3. Configure app group entitlements if needed for Showcase
4. Test full app functionality with correct Firebase backend
