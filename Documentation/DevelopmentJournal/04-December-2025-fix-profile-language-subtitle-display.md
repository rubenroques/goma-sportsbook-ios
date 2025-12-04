## Date
04 December 2025

### Project / Branch
BetssonCameroonApp / rr/feature/lang-switcher

### Goals for this session
- Fix Profile screen language button subtitle always showing "French" regardless of user's language preference

### Achievements
- [x] Identified root cause: `localized("current_language_code")` uses device language, not app's forced language
- [x] Fixed `ProfileMenuListViewModel.swift` to use `LanguageManager.shared.currentLanguageCode`
- [x] Fixed `ProfileWalletViewModel.swift` to use `LanguageManager.shared.currentLanguageCode`

### Issues / Bugs Hit
- None

### Key Decisions
- **`localized()` stays simple**: The `localized()` function remains a thin wrapper for `NSLocalizedString` with no business logic
- **`LanguageManager` is the source of truth**: For querying "what language is the app using", always use `LanguageManager.shared.currentLanguageCode`
- **`current_language_code` key obsolete for queries**: The localization key `current_language_code` in `.strings` files is no longer reliable for determining app language when in-app language switching is enabled

### Experiments & Notes
- `localized("current_language_code")` returns from `Bundle.main` which respects **device** language settings
- When user forces a different language via `LanguageManager`, `Bundle.main` doesn't change - it still uses device language
- Phrase SDK and app restart handle making UI strings match the forced language, but `Bundle.main` behavior remains tied to device settings

### Useful Files / Links
- `BetssonCameroonApp/App/Screens/ProfileWallet/ProfileMenuListViewModel.swift` (line 39)
- `BetssonCameroonApp/App/Screens/ProfileWallet/ProfileWalletViewModel.swift` (line 154)
- `BetssonCameroonApp/App/Services/LanguageManager.swift`
- `BetssonCameroonApp/App/Tools/MiscHelpers/Localization.swift`
- Previous DJ: `03-December-2025-language-switching-full-implementation.md`

### Next Steps
1. Build and verify compilation
2. Test Profile screen shows correct language subtitle after language switch
3. Consider auditing other usages of `localized("current_language_code")` in codebase (grep found ~20 usages)
