## Date
28 November 2025

### Project / Branch
BetssonCameroonApp / main (casino feature enhancement)

### Goals for this session
- Enable landscape rotation for CasinoGamePlayViewController (casino game webview)
- Keep the rest of the app portrait-only
- Implement decoupled solution without singletons

### Achievements
- [x] Updated project.pbxproj to allow landscape orientations (4 build configs)
- [x] Created Notification+Orientation.swift extension for decoupled communication
- [x] Updated AppDelegate with notification observers and orientation delegate method
- [x] Updated CasinoGamePlayViewController with orientation overrides and notification posting

### Issues / Bugs Hit
- None - implementation went smoothly

### Key Decisions
- **Notification-based approach** instead of singleton or direct AppDelegate access
  - CasinoGamePlayViewController posts `.landscapeOrientationRequested` / `.portraitOrientationRequested`
  - AppDelegate observes and maintains private `allowsLandscape` state
  - Neither side knows about the other - fully decoupled via NotificationCenter
- **Rejected alternatives:**
  - Singleton OrientationManager - user didn't want global mutable state
  - Direct AppDelegate static flag - user didn't want screens accessing AppDelegate directly
  - Modal presentation approach - would have required coordinator changes
  - Custom UINavigationController - more invasive change

### Experiments & Notes
- iOS orientation control works via intersection of:
  1. Info.plist supported orientations (app capability)
  2. AppDelegate's `supportedInterfaceOrientationsFor:` delegate
  3. ViewController's `supportedInterfaceOrientations` property
- When a VC is presented modally with `.fullScreen`, iOS queries that VC directly (bypasses AppDelegate)
- For pushed VCs, the navigation controller's orientation is used

### Useful Files / Links
- [CasinoGamePlayViewController](../BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoGamePlayViewController.swift)
- [AppDelegate](../BetssonCameroonApp/App/Boot/AppDelegate.swift)
- [Notification+Orientation](../BetssonCameroonApp/App/Extensions/Notification+Orientation.swift)
- [project.pbxproj](../BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj)

### Next Steps
1. Test rotation behavior on physical device
2. Verify UI adapts properly to landscape layout in casino webview
3. Consider adding rotation animation if needed
