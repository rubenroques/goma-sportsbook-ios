## Date
04 December 2025

### Project / Branch
BetssonCameroonApp / rr/feature/lang-switcher

### Goals for this session
- Fix architectural coupling: Bootstrap and Environment directly accessed `EveryMatrixUnifiedConfiguration.shared.defaultLanguage`
- Abstract language configuration behind ServicesProvider's public API
- App should only interact with `ServicesProvider.Client` and `Configuration`, not internal provider singletons

### Achievements
- [x] Added `language: String` property to `ServicesProvider.Configuration`
- [x] Added `withLanguage(_ language: String)` builder method to `Configuration.Builder`
- [x] Updated `Configuration` private init and legacy init to include language parameter (defaults to "en")
- [x] Added `setLanguage(_ language: String)` public method to `ServicesProvider.Client`
- [x] Updated `Client.init` to propagate language from Configuration to EveryMatrixUnifiedConfiguration
- [x] Updated `Client.configuration.didSet` to sync language changes
- [x] Removed direct `EveryMatrixUnifiedConfiguration` access from `Environment.swift`
- [x] Updated `Environment.swift` to use `.withLanguage(LanguageManager.shared.currentLanguageCode)` in builder chain
- [x] Updated `Bootstrap.restart()` to use `Env.servicesProvider.setLanguage()` instead of direct EveryMatrix access

### Issues / Bugs Hit
- [ ] Build verification pending - session ended before compilation test

### Key Decisions
- **Two-tier language configuration**: Initial setup via `Configuration.Builder().withLanguage()`, runtime changes via `Client.setLanguage()`
- **Default language**: "en" when not specified (backward compatible with legacy init)
- **EveryMatrix internal**: `EveryMatrixUnifiedConfiguration.shared.defaultLanguage` is now only mutated from within ServicesProvider, not from app code
- **Pattern consistency**: Follows existing `withEnvironment()`, `withDeviceUUID()`, `withClientBusinessUnit()` builder pattern

### Experiments & Notes
- `EveryMatrixUnifiedConfiguration` is still `public` but the intent is apps should not access it directly
- Future consideration: Make `EveryMatrixUnifiedConfiguration` `internal` once all apps are updated
- SportRadar language is currently hardcoded to "FR" - could be added to `setLanguage()` if needed

### Useful Files / Links

**Modified Files:**
- `Frameworks/ServicesProvider/Sources/ServicesProvider/Configuration/Configuration.swift` - Added language property and builder method
- `Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift` - Added setLanguage() and language propagation
- `BetssonCameroonApp/App/Boot/Environment.swift` - Removed direct EM access, uses .withLanguage()
- `BetssonCameroonApp/App/Boot/Bootstrap.swift` - Uses setLanguage() for runtime changes

**Architecture After Change:**
```
App Layer:
  LanguageManager.shared.currentLanguageCode
      ↓
  Configuration.Builder().withLanguage("fr")  ← Initial setup
      ↓
  Client.setLanguage("fr")                    ← Runtime change
      ↓
ServicesProvider (internal):
  EveryMatrixUnifiedConfiguration.shared.defaultLanguage  ← Hidden from app
```

### Next Steps
1. Build and verify compilation
2. Test language switching flow still works as expected
3. Consider making `EveryMatrixUnifiedConfiguration` internal in future PR
