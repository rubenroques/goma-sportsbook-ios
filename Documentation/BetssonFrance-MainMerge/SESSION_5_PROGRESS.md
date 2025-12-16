# Session 5 Progress - 15 December 2025

## Summary
Continued BetssonFrance → Main merge. Focused on fixing protocol conformance issues in SportRadar providers and adding missing Client methods.

---

## Completed Fixes

### 1. SportRadarBettingProvider Protocol Conformance

**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarBettingProvider.swift`

#### Signature Fixes (3 methods)

| Method | Issue | Fix |
|--------|-------|-----|
| `placeBets` | Missing 6 optional params | Added: `currency: String?, username: String?, userId: String?, oddsValidationType: String?, ubsWalletId: String?, betBuilderOdds: Double?` |
| `confirmBoostedBet` | Extra `detailedCode` param not in protocol | Changed signature to match protocol, pass `nil` internally |
| `placeBetBuilderBet` | Extra `useFreebetBalance` param not in protocol | Changed signature to match protocol, default to `false` internally |

#### Missing Methods Added (9 methods)
All return `.notSupportedForProvider`:

```swift
func getCashedOutBetsHistory(pageIndex:startDate:endDate:)
func calculateUnifiedBettingOptions(betType:selections:stakeAmount:)
func subscribeToCashoutValue(betId:)
func executeCashout(request:)
func updateTicketOdds(betId:)
func getTicketQRCode(betId:)
func getSocialSharedTicket(shareId:)
func deleteTicket(betId:)
func updateTicket(betId:betTicket:)
```

---

### 2. SportRadarEventsProvider Protocol Conformance

**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift`

#### Signature Fixes (2 methods)

| Method | Issue | Fix |
|--------|-------|-----|
| `getMarketGroups(forEvent:)` | Missing 2 params | Added: `includeMixMatchGroup: Bool, includeAllMarketsGroup: Bool` |
| `getHighlightedLiveEvents` | Returns `[Event]` not `Events` | Changed return type to `Events` (typealias for `[Event]`), wrapped result in proper type |

#### Missing Methods Added (35+ methods)
All return `.notSupportedForProvider`. Categories:

**Filtered Matches (4)**:
- `subscribeToFilteredPreLiveMatches(filters:)`
- `subscribeToFilteredLiveMatches(filters:)`
- `requestFilteredPreLiveMatchesNextPage(filters:)`
- `requestFilteredLiveMatchesNextPage(filters:)`

**Ended Matches (2)**:
- `subscribeEndedMatches(forSportType:)`
- `requestEndedMatchesNextPage(forSportType:)`

**Sport Types (2)**:
- `subscribeSportTypes()`
- `checkServicesHealth()`

**Tournaments (4)**:
- `subscribePopularTournaments(forSportType:tournamentsCount:)`
- `subscribeSportTournaments(forSportType:)`
- `getPopularTournaments(forSportType:tournamentsCount:)`
- `getTournaments(forSportType:)`

**Betting Offer Resolution (3)**:
- `subscribeToEventOnListsBettingOfferAsOutcomeUpdates(bettingOfferId:)`
- `getBettingOfferReference(forOutcomeId:)`
- `getEventWithSingleOutcome(bettingOfferId:)`

**Event Subscriptions (5)**:
- `subscribeToMarketGroups(eventId:)`
- `subscribeToMarketGroupDetails(eventId:marketGroupKey:)`
- `subscribeToEventAndSecondaryMarkets(withId:)`
- `subscribeToEventWithSingleOutcome(eventId:outcomeId:)`
- `subscribeToEventWithBalancedMarket(eventId:marketIdentifier:)`

**Search & Load (3)**:
- `getMultiSearchEvents(query:resultLimit:page:isLive:)`
- `loadEventsFromBookingCode(bookingCode:)`
- `getEventGroup(withId:)`

**Highlighted Events (1)**:
- `getHighlightedLiveEventsPointers(eventCount:userId:)`

**User Favorites (3)**:
- `getUserFavorites()`
- `addUserFavorite(eventId:)`
- `removeUserFavorite(eventId:)`

**News & Tips (4)**:
- `getNews()`
- `addFavoriteItem(favoriteId:type:)`
- `deleteFavoriteItem(favoriteId:type:)`
- `getFeaturedTips(page:limit:topTips:followersTips:friendsTips:userId:homeTips:)`

**Recommendations (2)**:
- `getRecommendedMatch(userId:isLive:limit:)`
- `getComboRecommendedMatch(userId:isLive:limit:)`

**Event Summary (1)**:
- `getEventSummary(eventId:marketLimit:)` - delegates to existing `getEventSummary(eventId:)`

---

### 3. Wheel/WinBoost Methods Added

**Problem**: BetssonFranceLegacy uses `Env.servicesProvider.getWheelEligibility()` and related methods that exist in the betsson-france `ServicesProviderClient` but not in main's `Client`.

#### Files Modified:

**PrivilegedAccessManagerProvider Protocol**:
`Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/PrivilegedAccessManager.swift`

Added 3 new protocol methods:
```swift
func getWheelEligibility(gameTransId: String) -> AnyPublisher<WheelEligibility, ServiceProviderError>
func wheelOptIn(winBoostId: String, optInOption: String) -> AnyPublisher<WheelOptInData, ServiceProviderError>
func getGrantedWinBoosts(gameTransIds: [String]) -> AnyPublisher<[GrantedWinBoosts], ServiceProviderError>
```

**Client.swift**:
`Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`

Added 3 corresponding public methods that delegate to `privilegedAccessManager`.

**EveryMatrixPAMProvider**:
`Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixPAMProvider.swift`

Added stub implementations returning `.notSupportedForProvider`.

**GomaProvider**:
`Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/GomaProvider.swift`

Added stub implementations returning `.notSupportedForProvider`.

**SportRadarPrivilegedAccessManager**: Already had implementations (from betsson-france branch).

---

### 4. CashbackBalance Type Fix

**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Cashback/CashbackBalance.swift`

**Problem**: Main branch had `balance: String?` but BetssonFrance expects `Double?` (and SportRadar API sends Double)

**Fix**:
- Changed `CashbackBalance.balance` from `String?` to `Double?`
- Updated initializer parameter type
- Kept custom decoder but flipped priority: tries `Double` first, then `String→Double` conversion as fallback
- Updated mapper in `SportRadarModelMapper+User.swift` to pass `Double?` directly (removed String conversion)

---

## Remaining Issues

### 1. Events Type Issue
**Error**: `Events(events: validEvents)` - extraneous argument label

**Root Cause**: `Events` is a typealias for `[Event]`, not a struct with an `events` property.

**Fix Needed**: Change to just `validEvents` (the array is already `Events` type)

### 2. BetssonFranceLegacy Type Inference Issues
The build shows many "cannot infer type of closure parameter" errors in BetssonFranceLegacy. These are cascading errors caused by ServicesProvider not compiling - once ServicesProvider compiles, these should resolve.

### 3. Missing SDKs
BetssonFranceLegacy still blocked by missing SDKs:
- TwintSDK
- IdensicMobileSDK
- AdjustSdk

---

## Files Modified This Session

| File | Changes |
|------|---------|
| `SportRadarBettingProvider.swift` | Fixed 3 signatures, added 9 stub methods |
| `SportRadarEventsProvider.swift` | Fixed 2 signatures, added 35+ stub methods |
| `PrivilegedAccessManager.swift` | Added 3 wheel/winboost protocol methods |
| `Client.swift` | Added 3 wheel/winboost public methods |
| `EveryMatrixPAMProvider.swift` | Added 3 wheel/winboost stub methods |
| `GomaProvider.swift` | Added 3 wheel/winboost stub methods |
| `CashbackBalance.swift` | Changed `balance` from `String?` to `Double?` |
| `SportRadarModelMapper+User.swift` | Removed String conversion for cashback balance |

---

## Build Status

**ServicesProvider**: Nearly compiles - just the `Events` type issue remaining
**RegisterFlow**: Blocked by ServicesProvider
**BetssonFranceLegacy**: Blocked by ServicesProvider + missing SDKs

---

## Next Steps

1. Fix the `Events(events:)` initializer issue - just use `validEvents` directly
2. Verify ServicesProvider compiles
3. Address any remaining type inference issues in BetssonFranceLegacy
4. Handle missing SDK dependencies (TwintSDK, IdensicMobileSDK, AdjustSdk)
