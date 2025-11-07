## Date
07 November 2025

### Project / Branch
BetssonCameroonApp / betsson-cm

### Goals for this session
- Fix Phrase SDK compilation error after library update to Swift concurrency
- Enable French and English localization (lock to only these languages)
- Fix language switcher button opening Settings root instead of app settings

### Achievements
- [x] Updated Phrase SDK integration from callback-based API to async/await pattern
- [x] Enabled both French and English in `TargetVariables.supportedLanguages`
- [x] Commented out `setupSupportedLanguages()` to allow iOS automatic language picker
- [x] Created `SettingsBundleHelper.swift` for Settings.bundle defaults registration
- [x] Fixed Settings.bundle not appearing in iOS Settings app
- [x] Language switcher now correctly opens app settings page (verified on real iPhone)

### Issues / Bugs Hit
- [x] ~~Phrase SDK breaking change: `updateTranslation` changed from callback to async/await~~
  - **Error**: `Trailing closure passed to parameter of type 'String' that does not accept a closure`
  - **Root cause**: Phrase SDK 5.1.0+ uses `async throws` instead of callback closure
  - **Solution**: Wrapped call in `Task {}` block with `try await`

- [x] ~~Language switcher opening Settings root page instead of app settings~~
  - **Root cause**: Settings.bundle not registered in UserDefaults on first launch
  - **Solution**: Created `SettingsBundleHelper` to register defaults programmatically
  - **iOS Behavior**: Settings.bundle is "lazy loaded" - doesn't exist until registered or manually visited

- [x] ~~iOS automatic language picker not appearing~~
  - **Root cause**: `AppStateManager.setupSupportedLanguages()` was overriding `AppleLanguages` in UserDefaults
  - **Solution**: Commented out the override to let iOS manage language selection
  - **Note**: iOS 13+ provides automatic per-app language picker when `knownRegions` is configured

### Key Decisions
- **Phrase SDK pattern**: Used BetssonFranceApp's modern async/await implementation as reference
  - Calls `applyPendingUpdates()` when translations change (new in SDK 5.1.0+)
  - Returns boolean indicating if translations actually updated
  - Better error handling with specific error types

- **Language strategy**: Rely on iOS automatic language picker instead of manual override
  - Commented out `setupSupportedLanguages()` (Option B - for testing)
  - Can be fully removed later if testing confirms no issues
  - `TargetVariables.supportedLanguages` kept for documentation purposes

- **Settings.bundle registration**: Implement best practice pattern for immediate Settings app recognition
  - Register defaults on every app launch (required by iOS)
  - Update dynamic values (version/build) from Info.plist
  - Prepared for future settings additions (automatic handling)

### Experiments & Notes
- **iOS Simulator vs Real Device**: Settings.bundle features are notoriously broken/unreliable in simulator
  - Language picker doesn't appear in simulator
  - `UIApplication.openSettingsURLString` opens random Settings pages
  - **Always test Settings.bundle on real devices** - this is a known iOS limitation

- **Localization architecture discovered**:
  - BetssonCameroonApp: Modern, simpler (but was using old Phrase API)
  - BetssonFranceApp: Has client-specific localization overrides via `TargetVariables.localizationOverrides`
  - Both use Phrase SDK for OTA translation updates

- **Settings.bundle current state**:
  - Only contains display-only version field (hardcoded "1.0.0(1000)")
  - Now dynamically updated from Info.plist
  - No user-editable preferences yet (ready for future additions)

### Useful Files / Links
- [AppDelegate.swift](BetssonCameroonApp/App/Boot/AppDelegate.swift:40-56) - Phrase SDK async/await integration
- [AppStateManager.swift](BetssonCameroonApp/App/Boot/AppStateManager.swift:133-139) - Commented language override
- [SettingsBundleHelper.swift](BetssonCameroonApp/App/Boot/SettingsBundleHelper.swift) - New helper for defaults registration
- [TargetVariables.swift](BetssonCameroonApp/App/SupportingFiles/TargetVariables.swift:66-68) - Supported languages config
- [Settings.bundle/Root.plist](BetssonCameroonApp/App/SupportingFiles/Settings.bundle/Root.plist) - Settings configuration
- [TopBarContainerController.swift](BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerController.swift:296-325) - Language switcher alert

### Research Findings
- **UIApplication.openSettingsURLString** DOES open app's settings page (not root) - when Settings.bundle is registered
- **iOS automatic language picker** appears in Settings → [App] → Preferred Language (iOS 13+)
  - Only works when `knownRegions` configured AND `AppleLanguages` not manually overridden
  - User can choose between supported languages or System default
- **Official deep link options** (App Store safe):
  - `UIApplication.openSettingsURLString` → App settings page
  - `UIApplication.openNotificationSettingsURLString` → App notifications settings (iOS 16+)
- **Unofficial schemes** (`prefs:root=`, `App-Prefs:`) → App Store rejection risk

### Next Steps
1. Monitor Phrase SDK updates in production (verify async/await works correctly)
2. Consider fully removing `setupSupportedLanguages()` method if no issues arise
3. Add user-editable preferences to Settings.bundle when needed (theme, odds format, etc.)
4. Test language switching flow end-to-end on real devices with both French and English
5. Update Settings.bundle with proper preferences when product requirements are defined
