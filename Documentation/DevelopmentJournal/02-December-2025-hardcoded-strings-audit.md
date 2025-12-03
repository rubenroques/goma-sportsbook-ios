## Date
02 December 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Audit hardcoded strings in BetssonCameroonApp
- Find hardcoded strings in GomaUI components used by BetssonCameroonApp
- Identify hardcoded "en" language parameters in API endpoints

### Achievements
- [x] Completed comprehensive audit of BetssonCameroonApp for hardcoded strings
- [x] Audited GomaUI components for user-facing hardcoded text
- [x] Verified API language configuration is properly dynamic
- [x] Documented all findings in plan file

### Issues / Bugs Hit
None - this was an audit session, no code changes made.

### Key Decisions
- **No fixes requested** - audit results are sufficient for now
- **API language handling is correct** - uses `localized("current_language_code")` pattern
- **GomaUI "?" placeholders are acceptable** - architectural pattern for image failure states
- **Debug screen strings are low priority** - PerformanceDebugViewController is internal-only

### Experiments & Notes

#### BetssonCameroonApp Findings (14 production strings)
| File | Line | String | Priority |
|------|------|--------|----------|
| MainTabBarViewController.swift | 734 | "Show Next Up Events" | High |
| MainTabBarViewController.swift | 745 | "Show In-Play Events" | High |
| FooterCollectionViewCell.swift | 25 | "Footer" | Medium |
| LoadingTimerOverlayView.swift | 290 | "Measuring performance..." | Low |
| PerformanceDebugViewController.swift | Multiple | 19 debug strings | Low |

#### Hardcoded "/en/" URLs in FooterTableViewCell.swift
Lines 59, 65, 68, 71, 74 contain static Betsson.com URLs with `/en/` path - should use localized URL keys.

#### GomaUI Placeholder Strings
- CasinoCategoryBarView.swift:172 - "Category Title"
- CasinoGameSearchedView.swift:157 - "?"
- CasinoGameImageView.swift:194 - "?"
- CasinoGameCardView.swift:120 - "?"
- RecentlyPlayedGamesCellView.swift:98 - "?"

These are in `renderPlaceholderState()` methods - acceptable pattern.

#### API Language Configuration (Correct)
- ViewModels use `localized("current_language_code")`
- ServicesProvider uses `EveryMatrixUnifiedConfiguration.shared.defaultLanguage`
- Fallback "en" in `EveryMatrixUnifiedConfiguration.swift:184` is appropriate

### Useful Files / Links
- [MainTabBarViewController](../../BetssonCameroonApp/App/Screens/MainTabBar/MainTabBarViewController.swift)
- [FooterTableViewCell](../../BetssonCameroonApp/App/Screens/NextUpEvents/FooterTableViewCell.swift)
- [EveryMatrixUnifiedConfiguration](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift)
- [Environment.swift](../../BetssonCameroonApp/App/Boot/Environment.swift) - where language is configured at startup

### Next Steps
1. (If needed) Localize MainTabBarViewController button titles
2. (If needed) Replace hardcoded /en/ URLs with localized keys
3. (If needed) Localize FooterCollectionViewCell "Footer" text
