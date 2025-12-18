# Session 6 Progress - 15 December 2025

## Summary
Completed the BetssonFrance → Main merge. **"Betsson PROD" scheme now builds successfully!**

---

## Completed Fixes

### 1. Method Signature Mismatches (6 issues) - Client.swift Overloads

Added backward-compatible overloads to `Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`:

| Method | Issue | Fix |
|--------|-------|-----|
| `getEventSummary(eventId:)` | Missing `marketLimit` param | Added overload that delegates with `marketLimit: nil` |
| `getMarketGroups(forPreLiveEvent:)` | Missing variant | Added overload returning `ServiceProviderError` |
| `getMarketGroups(forLiveEvent:)` | Missing variant | Added overload returning `ServiceProviderError` |
| `getMarketGroups(forEvent:)` | Missing single-param variant | Added overload returning `ServiceProviderError` |
| `placeBetBuilderBet` | Extra `useFreebetBalance` param | Added overload accepting the param |
| `confirmBoostedBet` | Extra `detailedCode` param | Added overload accepting the param |
| `contactSupport` | Different signature (individual params vs form) | Added convenience overload with individual params |

---

### 2. BetGroupingType.system - Missing `numberOfBets` Parameter

**File**: `BetssonFranceLegacy/Core/Services/BetslipManager.swift`

**Lines**: 675, 932

**Fix**: Added `numberOfBets` parameter to both call sites:
```swift
// Before
BetGroupingType.system(identifier: systemBetType.id, name: systemBetType.name ?? "")

// After
BetGroupingType.system(identifier: systemBetType.id, name: systemBetType.name ?? "", numberOfBets: systemBetType.numberOfBets ?? 0)
```

---

### 3. Score.gamePart - Missing `index` Parameter

**Files**:
- `BetssonFranceLegacy/Core/Models/App/Scores.swift`
- `BetssonFranceLegacy/Core/Models/ModelMappers/ServiceProviderModelMapper+Scores.swift`
- `BetssonFranceLegacy/Core/Views/ScoreView.swift`

**Issue**: ServicesProvider's `Score.gamePart` now has `(index: Int?, home: Int?, away: Int?)` but BetssonFranceLegacy's local enum only had `(home: Int?, away: Int?)`

**Fix**:
- Updated local `Score` enum to include `index: Int?`
- Updated mapper to pass through the index
- Updated ScoreView pattern matching to ignore index with `_`

---

### 4. MatchDetailsViewModel - Type Mismatch in flatMap

**File**: `BetssonFranceLegacy/Core/Screens/MatchDetails/MatchDetailsViewModel.swift`

**Line**: 485

**Issue**: flatMap closure declared return type `AnyPublisher<[MarketGroup], Never>` but our new overloads return `ServiceProviderError`

**Fix**: Changed closure return type to `AnyPublisher<[MarketGroup], ServiceProviderError>`

---

### 5. simpleSignUp → signUp Migration

**File**: `BetssonFranceLegacy/Core/Services/UserSessionStore.swift`

**Line**: 287

**Issue**: `simpleSignUp(form:)` method no longer exists in Client.swift - replaced with unified `signUp(with: SignUpFormType)`

**Fix**:
```swift
// Before
Env.servicesProvider.simpleSignUp(form: form)

// After
Env.servicesProvider.signUp(with: .simple(form))
```

---

### 6. getEventsForEventGroup → getEventGroup Rename

**Files**:
- `BetssonFranceLegacy/Core/Screens/Home/TemplatesDataSources/ClientManagedHomeViewTemplateDataSource.swift:494`
- `BetssonFranceLegacy/Core/Screens/Home/TemplatesDataSources/DummyWidgetShowcaseHomeViewTemplateDataSource.swift:504`

**Issue**: Method renamed in main branch

**Fix**: Updated call sites (fixed manually by user)

---

### 7. getHomeSliders Missing + getCashbackSuccessBanner Bug

**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`

**Issues**:
1. `getHomeSliders()` method was completely missing from Client.swift
2. `getCashbackSuccessBanner()` incorrectly called `eventsProvider.getHomeSliders()` instead of `eventsProvider.getCashbackSuccessBanner()`

**Fix**:
- Added new `getHomeSliders()` method (lines 820-828)
- Fixed `getCashbackSuccessBanner()` to call the correct provider method (line 837)

---

## Files Modified This Session

### ServicesProvider Package
| File | Changes |
|------|---------|
| `Client.swift` | Added 7 overloads, added `getHomeSliders()`, fixed `getCashbackSuccessBanner()` bug |

### BetssonFranceLegacy
| File | Changes |
|------|---------|
| `BetslipManager.swift` | Added `numberOfBets` param to 2 call sites |
| `Scores.swift` | Added `index` to `gamePart` case |
| `ServiceProviderModelMapper+Scores.swift` | Updated mapper for new `index` param |
| `ScoreView.swift` | Updated pattern matching for `gamePart` |
| `MatchDetailsViewModel.swift` | Changed flatMap return type |
| `UserSessionStore.swift` | Migrated to `signUp(with:)` API |
| `ClientManagedHomeViewTemplateDataSource.swift` | Renamed method call (manual) |
| `DummyWidgetShowcaseHomeViewTemplateDataSource.swift` | Renamed method call (manual) |

---

## Build Status

| Scheme | Status |
|--------|--------|
| **Betsson PROD** | **BUILD SUCCEEDED** |
| ServicesProvider | Compiles |
| RegisterFlow | Compiles |
| BetssonFranceLegacy | Compiles |

---

## Next Steps

1. Test BetssonCameroonApp still builds (regression check)
2. Test other BetssonFranceLegacy schemes (Betsson UAT, Demo, etc.)
3. Runtime testing of affected features
4. Stage and commit all changes
5. Update MERGE_PROGRESS.md with final status
