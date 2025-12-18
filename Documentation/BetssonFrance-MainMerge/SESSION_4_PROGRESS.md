# Session 4 Progress - 14 December 2025

## Summary
Continuing the BetssonFrance → Main merge. Fixed multiple SportRadar provider compilation errors.

---

## Completed Fixes

### 1. SportRadarModelMapper+Events.swift (Banner → EventBanner)
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Mapper/SportRadarModelMapper+Events.swift`

**Problem**: Mapper returned `Banner` (promotional type) but `BannerResponse` expects `[EventBanner]`

**Fix**: Changed mapper to return `EventBanner`:
- Renamed method from `banner()` to `eventBanner()`
- Changed return type from `Banner` to `EventBanner`
- Updated `bannerResponse()` to map to `EventBanner` array

**Why safe**: SportRadar's internal `SportRadarModels.Banner` structure already matches `EventBanner` fields. The promotional `Banner` model is for Goma CMS (BetssonCameroon) - completely separate use case.

---

### 2. UserWallet externalFreeBetBalances
**Files**:
- `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/User.swift`
- `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Mapper/SportRadarModelMapper+User.swift`

**Problem**: Mapper passed `externalFreeBetBalances` parameter that didn't exist in `UserWallet`

**Fix**:
- Added `externalFreeBetBalances: [ExternalFreeBetBalance]?` property to `UserWallet` struct
- Added `Hashable` conformance to `ExternalFreeBetBalance` struct (required for UserWallet's Hashable conformance)

---

### 3. CashbackBalance Type Mismatch
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Mapper/SportRadarModelMapper+User.swift`

**Problem**: `SportRadarModels.CashbackBalance.balance` is `Double?` but public `CashbackBalance.balance` expects `String?`

**Fix**: Added conversion in mapper: `balance: cashbackBalance.balance.map { String($0) }`

---

### 4. MarketGroup Missing `loaded` Parameter
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift`

**Problem**: `MarketGroup` init requires `loaded: Bool` parameter - missing in 3 locations

**Fix**: Added `loaded: true` to all MarketGroup initializations:
- Line 993 (fallback market group)
- Line 2356 (available market group)
- Line 2406 (bet builder market group)

---

### 5. Event Init Missing Parameters
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift`

**Problem**: Event init requires 4 additional parameters: `homeTeamLogoUrl`, `awayTeamLogoUrl`, `boostedMarket`, `promoImageURL`

**Fix**: Added missing parameters to Event initializations:
- Line 1844-1864 (outright event creation)
- Line 1596-1618 (new event from market info)

---

### 6. Optional Event Unwrapping (Type Annotation)
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift`

**Problem**: Compiler couldn't infer that `events` was `[Event]` after `compactMap`

**Fix**: Added explicit type annotation at line 1569:
```swift
.map { (events: [Event]) -> [Event] in
```

---

### 7. Added `customRequest` Method
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift`

**Problem**: `SportRadarManagedContentProvider` called `eventsProvider.customRequest()` but method didn't exist

**Fix**: Added generic method at end of class:
```swift
func customRequest<T: Codable>(endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
    return self.restConnector.request(endpoint)
}
```

---

### 8. Added `getTopCompetitionCountry` Method
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift`

**Problem**: `SportRadarManagedContentProvider` called `eventsProvider.getTopCompetitionCountry()` but method didn't exist

**Context**: In betsson-france worktree, this logic was inline in `getTopCompetitions()`. The main branch refactored it into `SportRadarManagedContentProvider` which needs to call it as a separate method.

**Fix**: Added method that matches the original inline implementation:
```swift
func getTopCompetitionCountry(competitionParentId: String) -> AnyPublisher<SportRadarModels.CompetitionParentNode, ServiceProviderError> {
    let endpoint = SportRadarRestAPIClient.getTopCompetitionCountry(competitionId: competitionParentId)
    let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.CompetitionParentNode>, ServiceProviderError> = self.restConnector.request(endpoint)
    return requestPublisher.map { response -> SportRadarModels.CompetitionParentNode in
        return response.data
    }
    .eraseToAnyPublisher()
}
```

---

## Remaining Errors

### Protocol Conformance Issues
The remaining errors are protocol conformance failures:

1. **SportRadarBettingProvider** does not conform to `BettingProvider`
2. **SportRadarEventsProvider** does not conform to `EventsProvider`

These are likely due to:
- New protocol methods added in main branch that SportRadar providers don't implement
- Method signature mismatches between protocol and implementation

### Next Steps
1. Compare `BettingProvider` protocol methods with `SportRadarBettingProvider` implementation
2. Compare `EventsProvider` protocol methods with `SportRadarEventsProvider` implementation
3. Add stub implementations returning `.notSupportedForProvider` for missing methods
4. Fix any signature mismatches

---

## Files Modified This Session

| File | Changes |
|------|---------|
| `SportRadarModelMapper+Events.swift` | Banner → EventBanner |
| `SportRadarModelMapper+User.swift` | CashbackBalance type conversion |
| `User.swift` | Added externalFreeBetBalances to UserWallet, Hashable to ExternalFreeBetBalance |
| `SportRadarEventsProvider.swift` | MarketGroup loaded, Event params, customRequest, getTopCompetitionCountry, type annotations |

---

## Build Status

**ServicesProvider**: Compiles with protocol conformance errors only
**RegisterFlow**: Blocked by ServicesProvider
**BetssonFranceLegacy**: Blocked by ServicesProvider + RegisterFlow + missing SDKs (TwintSDK, IdensicMobileSDK, AdjustSdk)
