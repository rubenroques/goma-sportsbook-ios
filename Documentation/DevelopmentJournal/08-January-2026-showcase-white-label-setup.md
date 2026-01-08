## Date
08 January 2026

### Project / Branch
sportsbook-ios / feature/showcase-white-label

### Goals for this session
- Clone BetssonFranceLegacy into a new Showcase project for white-label demo purposes
- Prepare BetssonFranceLegacy for cleanup (keep only France-specific code)
- Set up Showcase with all clients for demo/showcase functionality

### Achievements
- [x] Created new branch `feature/showcase-white-label`
- [x] Created Showcase folder structure with Core, Clients, NotificationsService, Scripts
- [x] Copied all 9 clients from BetssonFranceLegacy (ATP, Betsson, Crocobet, DAZN, EveryMatrix, GOMASportRadar, GOMASports, Showcase, SportRadar)
- [x] Set up Showcase.xcodeproj (user created fresh project in Xcode)
- [x] Added Showcase.xcodeproj to Sportsbook.xcworkspace
- [x] Fixed duplicate file issues caused by modern Xcode auto-sync vs legacy manual group references:
  - Deleted unreferenced `Core/Screens/PreLive/Cells/EmptyCardTableViewCell.swift`
  - Deleted unreferenced `Core/Screens/Root/Sports/Cells/MatchWidgetCollectionViewCell.swift`
  - Deleted unreferenced `Core/Screens/Tips&Rankings/Tips/TipsListVC/RankingsListViewController.swift`
  - Deleted unreferenced `Core/Screens/PreLive/Cells/EmptyCardTableViewCell.xib`
- [x] Removed Xcode template folder conflict (Showcase/Showcase with duplicate AppDelegate)
- [x] Configured Info.plist and entitlements paths in build settings
- [x] Added all external SPM packages via Xcode (Firebase, Adyen, Adjust, Phrase, Optimove, etc.)
- [x] Fixed Swift 6 strict concurrency settings (removed SWIFT_APPROACHABLE_CONCURRENCY and SWIFT_DEFAULT_ACTOR_ISOLATION)
- [x] Kept SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY for better import checking

### Issues / Bugs Hit
- [x] Xcode modern project format (`PBXFileSystemSynchronizedRootGroup`) auto-includes ALL files in folders, exposing previously unreferenced duplicate files from legacy codebase
- [x] Swift 6 concurrency settings (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`) caused deinit isolation errors with legacy code
- [ ] Some files may still need explicit `import SweeterSwift` due to MEMBER_IMPORT_VISIBILITY

### Key Decisions
- **Clone-first approach**: Create Showcase before cleaning BetssonFranceLegacy (safer)
- **Showcase naming**: Project and main target both named "Showcase", based on GOMASports
- **Modern Xcode project**: Started with fresh Xcode project instead of copying legacy project.pbxproj
- **Duplicate file resolution**: Use BetssonFranceLegacy's project.pbxproj as source of truth for which duplicate files to keep
- **Swift concurrency**: Disabled strict Swift 6 actor isolation to maintain compatibility with legacy code

### Experiments & Notes
- BetssonFranceLegacy uses old Xcode group references (not file system synchronized) - many files in filesystem were not actually referenced in project
- Modern Xcode projects use `PBXFileSystemSynchronizedRootGroup` which auto-syncs all files in a folder
- This migration exposed "dead" files that were never compiled but existed in the filesystem
- Process to identify correct file: Search project.pbxproj for file reference UUID → find parent group → trace path

### Useful Files / Links
- [Showcase/Core/](../../Showcase/Core/) - Main app code
- [Showcase/Clients/](../../Showcase/Clients/) - All 9 client configurations
- [BetssonFranceLegacy/BetssonFranceLegacy.xcodeproj/project.pbxproj](../../BetssonFranceLegacy/BetssonFranceLegacy.xcodeproj/project.pbxproj) - Reference for file membership

### Next Steps
1. Complete Showcase build verification
2. Add remaining missing imports (SweeterSwift where needed)
3. Clean BetssonFranceLegacy - remove non-France client folders (ATP, Crocobet, DAZN, EveryMatrix, GOMASportRadar, GOMASports, Showcase, SportRadar)
4. Remove non-France targets from BetssonFranceLegacy project
5. Verify BetssonFranceLegacy France targets still build (Betsson PROD, Betsson UAT, NotificationsService, SportsbookTests)
6. Add SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY to BetssonCameroonApp
