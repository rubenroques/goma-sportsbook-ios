## Date
06 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Refactor current 2-environment setup (STG/PROD) to 3-environment model (STG/UAT/PROD)
- Rename current "Production" to "UAT" (internal testing via Firebase)
- Add new "Production" for client's App Store release (`com.betsson.cameroon`)

### Achievements
- [x] Added `.uat` case to `BuildEnvironment` enum in `TargetVariables.swift`
- [x] Updated `environmentType` and `serviceProviderEnvironment` switches to handle UAT
- [x] Updated XtremePush configuration in `AppDelegate.swift` for 3 environments
- [x] Fixed `BetssonCM Prod.xcscheme` - changed BuildableName from `Stg.app` to `Prod.app`
- [x] Created new `BetssonCM UAT.xcscheme` with Debug-UAT/Release-UAT configurations
- [x] Updated Firebase build script in `project.pbxproj` to handle `*UAT*` configuration
- [x] Renamed Fastlane PROD → UAT throughout (mappings, lanes, env variables)
- [x] Verified entitlements files exist and are correctly configured

### Issues / Bugs Hit
- None - clean implementation

### Key Decisions
- **UAT uses same backend as PROD** - both point to production APIs (same `EnvironmentType.prod`)
- **PROD not in Fastlane** - uses client's Apple account (`YGR6VMTFKF`), manual builds for now
- **XtremePush keys**:
  - STG: `OOCkZRKh35Kf3Xrv4Zw--rJ4Q1BFZJ2p`
  - UAT: `tymCbccp6pas_HwOgwuDRMJZ6Nn0m7Gr`
  - PROD: `OOCkZRKh35Kf3Xrv4Zw--rJ4Q1BFZJ2p`
- **Firebase Database URLs** (added by user):
  - STG/UAT: `https://goma-sportsbook-betsson-cm-prod.europe-west1.firebasedatabase.app`
  - PROD: `https://betsson-cameroon-default-rtdb.europe-west1.firebasedatabase.app`

### Experiments & Notes
- User cloned PROD configs in Xcode and renamed to UAT - cleaner approach than renaming everything
- Build configurations now organized in separate `Misc-STG/`, `Misc-UAT/`, `Misc-PROD/` folders

### Useful Files / Links
- [TargetVariables.swift](../../BetssonCameroonApp/App/SupportingFiles/TargetVariables.swift) - BuildEnvironment enum
- [AppDelegate.swift](../../BetssonCameroonApp/App/Boot/AppDelegate.swift) - XtremePush configuration
- [Fastfile](../../BetssonCameroonApp/fastlane/Fastfile) - Distribution lanes
- [project.pbxproj](../../BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj) - Build configurations

### Final Environment Configuration

| Environment | Scheme | Bundle ID | Team ID | Firebase plist |
|-------------|--------|-----------|---------|----------------|
| STG | BetssonCM Staging | `com.gomagaming.betssoncm.stg` | `422GNXXZJR` (GOMA) | GoogleService-Info-Staging.plist |
| UAT | BetssonCM UAT | `com.gomagaming.betssoncm.prod` | `422GNXXZJR` (GOMA) | GoogleService-Info-UAT.plist |
| PROD | BetssonCM Prod | `com.betsson.cameroon` | `YGR6VMTFKF` (Client) | GoogleService-Info-Production.plist |

### Fastlane Lanes
- `fastlane distribute_staging` / `fastlane keep_version_distribute_staging`
- `fastlane distribute_uat` / `fastlane keep_version_distribute_uat`
- `fastlane distribute_all` / `fastlane keep_version_distribute_all`

### Next Steps
1. Test building all three schemes in Xcode
2. Update `.env` file with `BETSSONCM_UAT_FIREBASE_APP_ID` value
3. Verify Firebase distribution works with new UAT lanes
4. Configure client's Apple Developer account signing when ready for App Store
