## Date
28 November 2025

### Project / Branch
BetssonCameroonApp / rr/bugfix/match_detail_blinks

### Goals for this session
- Find all hardcoded user-facing strings in BetssonCameroonApp
- Check for existing localization keys to avoid duplicates
- Replace hardcoded strings with `localized()` calls
- Add new localization keys for both English and French

### Achievements
- [x] Searched entire BetssonCameroonApp for hardcoded strings (40+ instances found)
- [x] Identified 13 existing localization keys that could be reused (ok, cancel, retry, error, etc.)
- [x] Added 10 new localization keys to both en.lproj and fr.lproj Localizable.strings
- [x] Updated 15 source files to use localized strings
- [x] Fixed language settings alert in TopBarContainerController and ProfileWalletCoordinator
- [x] Fixed notifications screen (title, loading states, error messages)
- [x] Fixed casino error alerts in 4 view controllers
- [x] Fixed match details loading and error states
- [x] Fixed first deposit promotions screens (welcome message, deposit title, cancel button)
- [x] Fixed sports search navigation title
- [x] Fixed combined filters apply button
- [x] Fixed win boost format string with proper String(format:) placeholder
- [x] Fixed notification coordinator alert button

### Issues / Bugs Hit
- None - straightforward localization task

### Key Decisions
- Reuse existing keys instead of creating duplicates (13 keys already existed)
- Keep duplicated language settings alert code in 2 files (user decision: just localize, don't extract)
- Skip debug/development code localization (PerformanceDebugVC, PreviewUIView, etc.)
- Use format placeholder `%d%%` for WIN BOOST percentage instead of string concatenation

### Experiments & Notes
- Existing localization uses `localized()` function from `Localization.swift` (wraps NSLocalizedString)
- Some files use `LocalizationProvider.string()` from GomaUI - both work but `localized()` is the app-level standard
- French translations provided for all new keys

### New Localization Keys Added
| Key | English | French |
|-----|---------|--------|
| `set_your_app_language` | "Set Your App Language" | "Définir la langue de l'application" |
| `language_settings_message` | "Continue to Settings..." | "Accédez aux Paramètres..." |
| `open_settings` | "Open Settings" | "Ouvrir les paramètres" |
| `welcome_to_betsson` | "Welcome to Betsson!" | "Bienvenue chez Betsson !" |
| `loading_notifications` | "Loading notifications..." | "Chargement des notifications..." |
| `loading_markets` | "Loading markets..." | "Chargement des marchés..." |
| `search_sports` | "Search Sports" | "Rechercher Sports" |
| `notification_action` | "Notification Action" | "Action de notification" |
| `win_boost_format` | "WIN BOOST (%d%%)" | "WIN BOOST (%d%%)" |
| `win_boost_none` | "WIN BOOST (NONE)" | "WIN BOOST (AUCUN)" |

### Useful Files / Links
- [English Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings)
- [French Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/fr.lproj/Localizable.strings)
- [Localization.swift](../../BetssonCameroonApp/App/Tools/MiscHelpers/Localization.swift)
- [TopBarContainerController.swift](../../BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerController.swift)
- [NotificationsViewController.swift](../../BetssonCameroonApp/App/Screens/Notifications/NotificationsViewController.swift)

### Files Modified
1. `en.lproj/Localizable.strings` - Added 10 new keys
2. `fr.lproj/Localizable.strings` - Added 10 new keys with French translations
3. `TopBarContainerController.swift` - Language settings alert
4. `ProfileWalletCoordinator.swift` - Language settings alert + error alerts
5. `NotificationsViewController.swift` - Title, loading, error states
6. `NotificationsCoordinator.swift` - Alert button
7. `CasinoCategoriesListViewController.swift` - Error alert
8. `CasinoCategoryGamesListViewController.swift` - Error alert
9. `CasinoGamePrePlayViewController.swift` - Error alert
10. `CasinoGamePlayViewController.swift` - Error alert
11. `MatchDetailsTextualViewController.swift` - Loading label + error alert
12. `MarketsTabSimpleViewController.swift` - Error alert
13. `FirstDepositPromotionsViewController.swift` - Welcome message
14. `DepositVerificationViewController.swift` - Deposit title + cancel button
15. `DepositBonusViewController.swift` - Deposit title + cancel button
16. `SportsSearchViewController.swift` - Navigation title
17. `CombinedFiltersViewController.swift` - Apply button
18. `BetInfoSubmissionViewModel.swift` - Win boost format

### Next Steps
1. Run build to verify no compilation errors
2. Test app in both English and French to verify strings display correctly
3. Consider extracting duplicate language settings alert code in future refactor
