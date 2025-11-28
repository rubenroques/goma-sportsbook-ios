## Date
26 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Migrate `[LIVE_SCORE]` and `[SPORT_DEBUG]` print statements to GomaLogger
- Migrate `[TallOddsMatchCardViewModel]` print statements to GomaLogger
- Enable runtime control to disable noisy debug logs

### Achievements
- [x] Migrated 47 print statements with `[LIVE_SCORE]` and `[SPORT_DEBUG]` prefixes
- [x] Migrated 7 print statements with `[TallOddsMatchCardViewModel]` prefix (new category: `TALL_CARD`)
- [x] Added variadic `disableCategories()` and `enableCategories()` methods to GomaLogger

### Files Modified

**GomaLogger Framework:**
- `Frameworks/GomaLogger/Sources/GomaLogger/GomaLogger.swift` - Added variadic category methods

**ServicesProvider Framework:**
- `Frameworks/ServicesProvider/.../EventLiveDataBuilder.swift` - 22 prints migrated to `LIVE_SCORE`
- `Frameworks/ServicesProvider/.../LiveMatchesPaginator.swift` - 5 prints migrated to `LIVE_SCORE`

**BetssonCameroonApp:**
- `BetssonCameroonApp/.../ScoreViewModel.swift` - 14 prints (4 `SPORT_DEBUG`, 10 `LIVE_SCORE`)
- `BetssonCameroonApp/.../TallOddsMatchCardViewModel.swift` - 11 prints (6 `SPORT_DEBUG`, 5 `LIVE_SCORE`) + 7 prints to `TALL_CARD`

### Category Mapping

| Old Prefix | Subsystem | Category |
|------------|-----------|----------|
| `[LIVE_SCORE]` | `.realtime` | `"LIVE_SCORE"` |
| `[SPORT_DEBUG]` | `.realtime` | `"SPORT_DEBUG"` |
| `[TallOddsMatchCardViewModel]` | `.ui` | `"TALL_CARD"` |

### Key Decisions
- Used `.realtime` subsystem for live score and sport debug logs (match data flow)
- Used `.ui` subsystem for ViewModel lifecycle logs (`TALL_CARD`)
- Shortened `[TallOddsMatchCardViewModel]` to `TALL_CARD` for consistency with other tags
- Added variadic methods for bulk enable/disable operations

### New GomaLogger API

```swift
// Disable multiple categories at once
GomaLogger.disableCategories("LIVE_SCORE", "TALL_CARD", "SPORT_DEBUG")

// Re-enable them
GomaLogger.enableCategories("LIVE_SCORE", "TALL_CARD")
```

### Useful Files / Links
- [GomaLogger.swift](../../Frameworks/GomaLogger/Sources/GomaLogger/GomaLogger.swift)
- [EventLiveDataBuilder.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/EventLiveDataBuilder.swift)
- [TallOddsMatchCardViewModel.swift](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/TallOddsMatchCardViewModel.swift)
- [ScoreViewModel.swift](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/ScoreViewModel.swift)
- [Previous GomaLogger v1 implementation](./20-November-2025-gomalogger-v1-implementation.md)

### Next Steps
1. Continue migrating other print statement patterns (e.g., `[SSEDebug]`, `[SERVICEPROVIDER]`)
2. Consider adding a debug menu toggle for log categories
3. Document all category names in a central reference
