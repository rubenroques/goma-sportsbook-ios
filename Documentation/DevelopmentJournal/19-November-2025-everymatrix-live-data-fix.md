# Development Journal

## Date
19 November 2025

### Project / Branch
sportsbook-ios / rr/match_details_score

### Goals for this session
- Fix live data blocking issue in EveryMatrix provider
- Understand why InPlay list loses live updates when match details is open
- Implement proper data sharing between MatchDetailsManager and LiveMatchesPaginator

### Achievements
- [x] Identified root cause: `matchDetailsManager` lifecycle bug - never cleared when navigating away
- [x] Discovered missing `observeEventInfosForEvent()` implementation in MatchDetailsManager
- [x] Implemented Option A: Added missing method to MatchDetailsManager (lines 795-815)
- [x] Updated EveryMatrixEventsProvider to share data instead of blocking (lines 297-307)
- [x] Changed from blocking ALL events to checking specific match ID

### Issues / Bugs Hit
- **Original Bug**: Line 298 blocked ALL `subscribeToLiveDataUpdates()` calls when any match details was open
- **Incomplete Implementation**: Method `observeEventInfosForEvent()` was commented out (lines 301-306)
- **Lifecycle Issue**: `matchDetailsManager` only cleared when opening NEW match details, not when navigating away

### Key Decisions
- **Chose Option A over B/C**: Implement missing method instead of fixing lifecycle
  - Reason: Allows same match in both InPlay list AND match details without duplicate subscriptions
  - Shares existing WebSocket data from `matchDetailsAggregatorPublisher`
  - Consistent with SportRadar provider architecture
- **Used EventLiveDataBuilder**: Delegates transformation logic to shared builder for consistency across LiveMatchesPaginator and MatchDetailsManager
- **Specific Match Check**: `matchDetailsManager.matchId == id` prevents blocking unrelated matches

### Experiments & Notes
- **Data Flow Discovery**: Match details already receives EventInfo via `matchDetailsAggregatorPublisher` (line 64)
  - Navigation bar shows live status because Event model contains liveData from EventInfos
  - Two subscription types exist: full Event (match details) vs lightweight EventLiveData (InPlay list)
- **EntityStore Pattern**: `observeEventInfosForEvent()` already existed in EntityStore (line 263)
- **Architecture Insight**: EveryMatrix uses 2 data flows:
  - WebSocket (WAMP): 4-layer transformation (DTO → Builder → Internal → Domain)
  - REST APIs: 2-layer transformation (Internal → Domain)

### Useful Files / Links

**EveryMatrix (Modified):**
- [MatchDetailsManager](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/MatchDetailsManager.swift)
- [EveryMatrixEventsProvider](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixEventsProvider.swift)
- [LiveMatchesPaginator](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/LiveMatchesPaginator.swift)
- [EntityStore](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/Store/EntityStore.swift)
- [EventLiveDataBuilder](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/EventLiveDataBuilder.swift)
- [EveryMatrix CLAUDE.md](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md)

**SportRadar (Reference for Lifecycle Pattern):**
- [SportRadarEventsProvider](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift) - Lines 84-85, 118, 134, 1788-1845
- [SportRadarEventsPaginator](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/APIs/Events-Poseidon/EventsLists/SportRadarEventsPaginator.swift) - Lines 37-41

### Code Changes Summary

**File 1: MatchDetailsManager.swift** (lines 795-815)
```swift
/// Observe live data (EventInfo entities) for this match
func observeEventInfosForEvent(eventId: String) -> AnyPublisher<EventLiveData, Never> {
    return store.observeEventInfosForEvent(eventId: eventId)
        .map { [weak self] eventInfos in
            // Get match data for participant mapping
            let matchData = self?.store.get(EveryMatrix.MatchDTO.self, id: eventId)

            // Delegate to shared EventLiveDataBuilder
            return EventLiveDataBuilder.buildEventLiveData(
                eventId: eventId,
                from: eventInfos,
                matchData: matchData
            )
        }
        .eraseToAnyPublisher()
}
```

**File 2: EveryMatrixEventsProvider.swift** (lines 297-307)
```swift
// OLD (blocked ALL events):
if let matchDetailsManager = self.matchDetailsManager {
    return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
}

// NEW (shares data for specific match):
if let matchDetailsManager = self.matchDetailsManager, matchDetailsManager.matchId == id {
    return matchDetailsManager.observeEventInfosForEvent(eventId: id)
        .map { SubscribableContent.contentUpdate(content: $0) }
        .setFailureType(to: ServiceProviderError.self)
        .eraseToAnyPublisher()
}
```

### Architecture Analysis

**Why This Fix Works:**
1. **No Duplicate Subscriptions**: When same match is in InPlay AND match details, both use the same EntityStore data
2. **Proper Data Sharing**: MatchDetailsManager's WebSocket already receives EventInfos via matchDetailsAggregatorPublisher
3. **Unblocks Other Matches**: InPlay matches use LiveMatchesPaginator when not the match in details

**Previous Architecture Flaw:**
- Existence of `matchDetailsManager` blocked ALL live data requests
- Even matches NOT in details view lost live updates
- Navigation bar worked because it used full Event subscription, not `subscribeToLiveDataUpdates()`

**Future Consideration (Not Implemented):**
- Lifecycle cleanup still needed: `matchDetailsManager` should be cleared when view disappears
- Current implementation relies on creating new manager when opening different match details
- Consider adding public `clearMatchDetailsManager()` method for coordinator to call

**SportRadar's Superior Lifecycle Pattern (Reference Implementation):**

SportRadar implements automatic lifecycle management via weak subscription references:

```swift
// SportRadarEventsPaginator.swift (lines 37-41)
var isActive: Bool {
    return self.subscription != nil
}

weak var subscription: Subscription?  // 🔑 Weak reference
```

**How It Works:**
1. **ViewModel stores subscription**: When subscribing, ViewModel keeps strong reference to Subscription object
2. **Provider stores weak reference**: Provider's coordinator/paginator only keeps weak reference
3. **Automatic cleanup**: When ViewModel deallocates (view dismissed), subscription deallocates
4. **isActive becomes false**: Weak reference becomes nil, making `isActive` return false
5. **Provider self-cleans**: Next access filters out inactive coordinators automatically

```swift
// SportRadarEventsProvider.swift (lines 1788-1795)
func getValidEventDetailsCoordinators() -> [SportRadarEventDetailsCoordinator] {
    // Filter removes all coordinators where isActive == false (subscription deallocated)
    self.eventDetailsCoordinators = self.eventDetailsCoordinators.filter({ $0.value.isActive })
    return Array(self.eventDetailsCoordinators.values)
}

func getValidEventDetailsCoordinator(forKey key: String) -> SportRadarEventDetailsCoordinator? {
    // Same filter pattern - automatic garbage collection
    self.eventDetailsCoordinators = self.eventDetailsCoordinators.filter({ $0.value.isActive })
    return self.eventDetailsCoordinators[key]
}
```

**Applied Throughout SportRadar:**
- Lines 84-85: `private weak var liveSportsSubscription: Subscription?`
- Line 118: `.filter { $0.value.isActive }` for paginators
- Line 134: `.filter { $0.value.isActive }` for market coordinators
- Lines 1789-1845: All coordinator getters use filter pattern

**Why This Is Better:**
- ✅ **No manual cleanup**: ViewModel deinit automatically triggers cleanup
- ✅ **Memory safe**: Dead coordinators automatically garbage collected
- ✅ **No coordinator reference needed**: Provider doesn't need public `clear()` methods
- ✅ **MVVM-C compliant**: Follows "ViewModels own subscriptions" principle

**EveryMatrix Current Issue:**
- ❌ `matchDetailsManager` stored as strong reference (line 37: `private var matchDetailsManager: MatchDetailsManager?`)
- ❌ No `isActive` property - can't detect when subscription is dead
- ❌ Never filtered or cleaned up automatically
- ❌ Only cleared when opening a different match details (line 206: `matchDetailsManager?.unsubscribe()`)

**Recommended Future Work:**
Adopt SportRadar pattern for EveryMatrix:
1. Add `weak var subscription: Subscription?` to MatchDetailsManager
2. Add `var isActive: Bool { subscription != nil }` computed property
3. Store manager in dictionary like SportRadar: `private var matchDetailsManagers: [String: MatchDetailsManager] = [:]`
4. Filter on access: `matchDetailsManagers.filter { $0.value.isActive }`
5. Return first active manager matching the matchId

### Next Steps
1. **Test the fix**: Build and verify InPlay list gets live data when match details is open
2. **Verify duplicate handling**: Confirm same match in both views doesn't create conflicts
3. **Consider lifecycle fix**: Add proper cleanup when navigating away from match details
4. **Document pattern**: Update EveryMatrix CLAUDE.md with this data sharing pattern

### Remaining Questions
- ~~Should we implement Option B (lifecycle cleanup) in addition to Option A?~~ **ANSWERED**: Yes, should adopt SportRadar's weak subscription pattern for automatic lifecycle management
- ~~Does SportRadar provider handle this scenario differently?~~ **ANSWERED**: Yes, SportRadar uses weak subscription references + isActive filtering for automatic cleanup (documented above)
- Can we add unit tests to prevent regression of this blocking behavior?
- Should EveryMatrix adopt SportRadar's lifecycle pattern as next refactor?
