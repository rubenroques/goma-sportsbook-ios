## Date
10 January 2026

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Clean up git worktrees
- Apply environment-specific app icons from bet-at-home branch to main (BetssonCameroonApp)

### Achievements
- [x] Removed stale `goma-cashier` worktree and deleted merged branch `rr/goma_cashier`
- [x] Updated `bet-at-home` worktree - merged 111 commits from main
- [x] Resolved 4 merge conflicts in bet-at-home:
  - `PreviewUIView.swift` - removed redundant `@available(iOS 17.0, *)`
  - `PreviewUIViewController.swift` - same
  - `contents.xcworkspacedata` - kept all project refs (GomaPlatform + BetssonFrance + Showcase)
  - `BrandLogoImageResolver.swift` - kept at new `Navigation/MultiWidgetToolbarView/` location
- [x] Copied environment-specific app icons to main for BetssonCameroonApp:
  - `AppIcon-BetssonCM-UAT.appiconset` (with UAT indicator)
  - `AppIcon-BetssonCM-STG.appiconset` (with STG indicator)
  - `AppIcon-BetssonCM-PROD.appiconset` (clean production icon)
- [x] Updated `project.pbxproj` with environment-specific icon names for all 6 build configurations

### Issues / Bugs Hit
- None

### Key Decisions
- Excluded BetAtHome-specific assets from cherry-pick (only brought BetssonCM icons)
- Kept original `AppIcon-BetssonCM.appiconset` in place (unused but not removed)

### Useful Files / Links
- [BetssonCM Assets](BetssonCameroonApp/App/Resources/Assets/BetssonCM-Assets.xcassets/)
- [project.pbxproj](BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj)

### Next Steps
1. Verify icons in Xcode by running each scheme (UAT/Staging/Prod)
2. Commit changes to main
3. Consider removing unused `AppIcon-BetssonCM.appiconset` in future cleanup
