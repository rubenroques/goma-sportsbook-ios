## Date
02 December 2025

### Project / Branch
betssonfrance-git-worktree / Sportsbook2.xcodeproj

### Goals for this session
- Diagnose and fix build failure in betssonfrance-git-worktree project
- Resolve "Missing package product 'FirebaseFirestoreSwift'" error

### Achievements
- [x] Identified root cause: FirebaseFirestoreSwift was removed in Firebase iOS SDK 11+ (merged into FirebaseFirestore)
- [x] Removed all FirebaseFirestoreSwift references from project.pbxproj (8 entries total)
- [x] Verified no source code imports FirebaseFirestoreSwift (safe removal)

### Issues / Bugs Hit
- Firebase SDK upgraded from 11 to 12, but project still referenced deprecated `FirebaseFirestoreSwift` product
- Xcode showed "Missing package product 'FirebaseFirestoreSwift'" error

### Key Decisions
- Direct removal of references from pbxproj file rather than Xcode UI (faster, more precise)
- No code changes needed since FirebaseFirestoreSwift was never imported in source files

### Experiments & Notes
- Firebase 11+ merged FirebaseFirestoreSwift functionality directly into FirebaseFirestore
- The worktree project had multiple Firebase SDK version constraints (some at 7.0.0, one at 12.0.0)
- Affected targets: "Betsson UAT" and "Betsson PROD"

### Removed References
From `Sportsbook2.xcodeproj/project.pbxproj`:
1. PBXBuildFile entries for FirebaseFirestoreSwift in Frameworks
2. Framework build phase references in both targets
3. Package product dependency entries in target configurations
4. XCSwiftPackageProductDependency entries

### Useful Files / Links
- `/Users/rroques/Desktop/GOMA/iOS/betssonfrance-git-worktree/Sportsbook2.xcodeproj/project.pbxproj`
- [Firebase iOS SDK Migration Notes](https://firebase.google.com/docs/ios/swift-migration)

### Next Steps
1. Open Xcode and clean build folder (Cmd+Shift+K)
2. Reset package caches (File -> Packages -> Reset Package Caches)
3. Build and verify project compiles successfully
4. Consider updating all Firebase package references to consistent version (currently mixed 7.0.0 and 12.0.0)
