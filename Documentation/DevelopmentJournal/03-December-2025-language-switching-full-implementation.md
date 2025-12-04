## Date
03 December 2025

### Project / Branch
BetssonCameroonApp / rr/feature/lang-switcher

### Goals for this session
- Implement full language switching with app restart
- Configure Phrase SDK with locale override (like BetssonFrance)
- Update EveryMatrix API language configuration on language change
- Preserve user session through app restart

### Achievements
- [x] Refactored TopBarContainerViewModel to properly encapsulate languageSelectorViewModel (MVVM-C fix)
- [x] Created `LanguageManager` singleton service for language preference management
- [x] Updated `localized()` function to use language-specific bundles based on user preference
- [x] Configured Phrase SDK with `localeOverride` based on LanguageManager (matches BetssonFrance pattern)
- [x] Implemented `Bootstrap.restart()` method for coordinated app restart
- [x] Added `cancelAllSubscriptions()` to AppStateManager for clean shutdown
- [x] Implemented `disconnect()` in ServicesProvider.Client to properly close socket connections
- [x] Added `reset()` method to SportTypeStore for clean state on restart
- [x] Wired SceneDelegate to listen for language change notifications
- [x] Connected LanguageSelectorViewModel to LanguageManager for actual language switching
- [x] Updated Environment.swift to use LanguageManager instead of localized()

### Issues / Bugs Hit
- [ ] Build verification pending - session ended before compilation test

### Key Decisions
- **LanguageManager singleton**: Central service for language preference with UserDefaults persistence
- **Notification-based restart**: `Notification.Name.languageDidChange` triggers coordinated app restart
- **Full splash restart**: User sees splash screen during language switch (consistent with cold launch)
- **Session preservation**: Auth tokens in UserSessionStore survive restart (not affected by language change)
- **Phrase SDK locale override**: Using `phraseConfiguration.localeOverride` like BetssonFrance does
- **MVVM-C fix**: TopBarContainerController now uses parent ViewModel interface, not direct child access

### Experiments & Notes
- Investigated BetssonFrance Phrase SDK setup - they use `localeOverride = "fr-FR"` to force French
- Language flow: User selects → LanguageManager stores → posts notification → SceneDelegate calls Bootstrap.restart() → Phrase reconfigured → EveryMatrix language updated → services disconnected → new AppStateManager/AppCoordinator created → splash shown → services reconnect with new language

### Useful Files / Links

**New Files Created:**
- `BetssonCameroonApp/App/Services/LanguageManager.swift` - Central language preference manager

**Modified Files:**
- `BetssonCameroonApp/App/Tools/MiscHelpers/Localization.swift` - Uses LanguageManager for bundle selection
- `BetssonCameroonApp/App/Boot/AppDelegate.swift` - Phrase SDK configured with localeOverride
- `BetssonCameroonApp/App/Boot/Bootstrap.swift` - Added restart() method with Phrase reconfiguration
- `BetssonCameroonApp/App/Boot/AppStateManager.swift` - Added cancelAllSubscriptions() cleanup
- `BetssonCameroonApp/App/Boot/SceneDelegate.swift` - Listens for language change notification
- `BetssonCameroonApp/App/Boot/Environment.swift` - Uses LanguageManager for initial language
- `BetssonCameroonApp/App/ViewModels/LanguageSelectorViewModel.swift` - Triggers LanguageManager on selection
- `BetssonCameroonApp/App/Services/SportTypeStore.swift` - Added reset() for clean state
- `BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerController.swift` - MVVM-C fix
- `BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerViewModel.swift` - Encapsulated child VM
- `Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift` - Implemented disconnect()

**Previous Session:**
- `Documentation/DevelopmentJournal/03-December-2025-language-selector-ui-implementation.md` - UI implementation

### Next Steps
1. Build and verify compilation
2. Test floating overlay presentation from top bar
3. Test full screen presentation from Profile menu
4. Verify session preservation (user stays logged in)
5. Test API calls use new language code in paths
6. Test socket reconnections with new language
7. Verify language preference persists across app kills
