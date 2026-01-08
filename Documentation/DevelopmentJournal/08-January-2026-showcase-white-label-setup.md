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
- [x] Created Showcase folder structure from BetssonFranceLegacy
- [x] Set up Showcase.xcodeproj (fresh Xcode project with modern format)
- [x] Added Showcase.xcodeproj to Sportsbook.xcworkspace
- [x] Fixed duplicate file issues caused by modern Xcode auto-sync vs legacy manual group references:
  - Deleted unreferenced `Core/Screens/PreLive/Cells/EmptyCardTableViewCell.swift`
  - Deleted unreferenced `Core/Screens/Root/Sports/Cells/MatchWidgetCollectionViewCell.swift`
  - Deleted unreferenced `Core/Screens/Tips&Rankings/Tips/TipsListVC/RankingsListViewController.swift`
  - Deleted unreferenced `Core/Screens/PreLive/Cells/EmptyCardTableViewCell.xib`
- [x] Removed Xcode template folder conflict (Showcase/Showcase with duplicate AppDelegate)
- [x] Configured Info.plist and entitlements paths in build settings
- [x] Added all external SPM packages (Firebase, Adyen, Adjust, Phrase, Optimove, Kingfisher, Lottie, etc.)
- [x] Fixed Swift 6 strict concurrency settings (removed SWIFT_APPROACHABLE_CONCURRENCY and SWIFT_DEFAULT_ACTOR_ISOLATION)
- [x] Kept SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY for better import checking
- [x] Cleaned up structure: renamed Core → App, kept only 2 client targets (Showcase, DAZN)

### Final Project Structure
```
Showcase/
├── App/                    # Main app code (renamed from Core)
│   ├── Boot/               # AppDelegate, Bootstrap, Router, Environment
│   ├── Constants/          # Colors, Fonts, Theme, UserDefaults
│   ├── Models/             # App, EveryMatrixAPI, GGAPI, ModelMappers
│   ├── Protocols/          # ClientsProtocols, AggregatorRepository
│   ├── Resources/          # Animations, Assets, Fonts, Localization
│   ├── Screens/            # 40+ screens (Account, Betslip, Casino, etc.)
│   ├── Services/           # AppSession, BetslipManager, Networking
│   ├── Tools/              # Extensions, Helpers, SwiftUI utilities
│   └── Views/              # Reusable UI components
├── Clients/
│   ├── DAZN/               # DAZN client configuration
│   └── Showcase/           # Showcase (main demo) client configuration
└── Showcase.xcodeproj
```

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
- **Simplified clients**: Kept only Showcase and DAZN targets (instead of all 9 original clients)
- **Folder rename**: Core → App for cleaner, more standard naming

### Experiments & Notes
- BetssonFranceLegacy uses old Xcode group references (not file system synchronized) - many files in filesystem were not actually referenced in project
- Modern Xcode projects use `PBXFileSystemSynchronizedRootGroup` which auto-syncs all files in a folder
- This migration exposed "dead" files that were never compiled but existed in the filesystem
- Process to identify correct file: Search project.pbxproj for file reference UUID → find parent group → trace path

### Useful Files / Links
- [Showcase/App/](../../Showcase/App/) - Main app code
- [Showcase/Clients/](../../Showcase/Clients/) - Showcase and DAZN client configurations
- [BetssonFranceLegacy/BetssonFranceLegacy.xcodeproj/project.pbxproj](../../BetssonFranceLegacy/BetssonFranceLegacy.xcodeproj/project.pbxproj) - Reference for file membership

### Next Steps
1. Complete Showcase build verification
2. Add remaining missing imports (SweeterSwift where needed)
3. Clean BetssonFranceLegacy - remove non-France client folders
4. Remove non-France targets from BetssonFranceLegacy project
5. Verify BetssonFranceLegacy France targets still build
6. Add SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY to BetssonCameroonApp
