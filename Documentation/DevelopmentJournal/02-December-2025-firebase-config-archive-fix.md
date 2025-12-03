## Date
02 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Diagnose and fix crash on device launch (SIGABRT) for production builds
- Implement Firebase GoogleService-Info.plist best practices for multi-environment builds
- Release fixed build via tag-based CI/CD

### Achievements
- [x] Identified root cause: `GoogleService-Info.plist` missing from archive builds
- [x] Researched best practices for multi-environment Firebase config (Stack Overflow, Bright Inventions, WTTech)
- [x] Refactored Firebase config copy approach:
  - Created `App/SupportingFiles/Firebase/` folder with environment-specific plists
  - `GoogleService-Info-Production.plist` and `GoogleService-Info-Staging.plist`
  - Placeholder `GoogleService-Info.plist` that gets overwritten at build time
- [x] Updated run script to copy BEFORE "Copy Bundle Resources" phase (key fix)
- [x] Changed from `BUILT_PRODUCTS_DIR` to source directory copy approach
- [x] Used `${CONFIGURATION}` pattern matching (`*Production*`, `*Staging*`) instead of custom `APP_ENVIRONMENT`
- [x] Excluded environment-specific plists from bundle membership
- [x] Verified archives contain correct single `GoogleService-Info.plist`
- [x] Released `bcm-v0.3.2(3121)` via tag-based dual distribution

### Issues / Bugs Hit
- [x] Initial fix using `TARGET_BUILD_DIR` still didn't work for archives
- [x] Environment-specific plists were being bundled (bloat + security concern) - fixed with membership exceptions

### Key Decisions
- **Approach 1A chosen**: Copy to source directory before bundle resources (most reliable)
- **Script runs first** in build phases (before Sources, Frameworks, Resources)
- **Pattern matching on CONFIGURATION**: `*Production*` matches both `Debug-Production` and `Release-Production`
- **Build 3120 superseded**: Changed changelog to 3121 instead of adding new entry (3120 was broken)

### Experiments & Notes
- `BUILT_PRODUCTS_DIR` works for simulator but not archives
- `TARGET_BUILD_DIR` also unreliable for archives
- Copying to source then letting Xcode bundle normally is the most robust approach
- Xcode 16+ `fileSystemSynchronizedGroups` requires `membershipExceptions` to exclude files

### Useful Files / Links
- [project.pbxproj](../../BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj) - Run script and exclusions
- [CHANGELOG.yml](../../BetssonCameroonApp/CHANGELOG.yml) - Release notes
- [AUTO_DISTRIBUTE.md](../../BetssonCameroonApp/fastlane/AUTO_DISTRIBUTE.md) - Tag-based release docs
- [Stack Overflow - Different GoogleService-Info.plist for build schemes](https://stackoverflow.com/questions/37615405/use-different-googleservice-info-plist-for-different-build-schemes)
- [Bright Inventions - Google configuration per environment](https://brightinventions.pl/blog/ios-google-configuration-per-environment/)

### Firebase Config File Structure
```
App/SupportingFiles/
├── Firebase/
│   ├── GoogleService-Info-Production.plist  (excluded from bundle)
│   └── GoogleService-Info-Staging.plist     (excluded from bundle)
└── GoogleService-Info.plist                  (placeholder, included in bundle)
```

### Run Script (Copy Firebase Config)
```bash
# Runs FIRST in build phases (before Sources, Frameworks, Resources)
case "${CONFIGURATION}" in
    *Production*) cp ".../Firebase/GoogleService-Info-Production.plist" ".../GoogleService-Info.plist" ;;
    *Staging*)    cp ".../Firebase/GoogleService-Info-Staging.plist" ".../GoogleService-Info.plist" ;;
esac
```

### Next Steps
1. Monitor GitHub Actions for successful dual distribution
2. Verify app launches correctly on physical device from Firebase distribution
3. Consider cleaning up old `Misc-Prod/` and `Misc-Stg/` folders if no longer needed
