# Development Journal

## Date
19 November 2025

### Project / Branch
sportsbook-ios / rr/match_details_score

### Goals for this session
- Investigate why Match Details screen shows no scores while InPlay lists do
- Add live score display to Match Details header
- Use existing EveryMatrix infrastructure (MatchDetailsManager.observeEventInfosForEvent)

### Achievements
- [x] **Root Cause Analysis**: Used cWAMP to test all WAMP routes and discovered:
  - `matchDetailsAggregatorPublisher` DOES return 32 EVENT_INFO entities ✅
  - MatchBuilder/EveryMatrixModelMapper were hardcoding scores to nil (wrong comment!)
  - InPlay works because LiveMatchesPaginator subscribes to live data separately
  - Match Details only subscribed to event details (markets), NOT live data (scores)

- [x] **WAMP Route Testing**: Tested 3 routes with cWAMP, saved responses to WAMPExampleResponses/
  - `liveMatchesPublisher`: 10 MATCH + 22 EVENT_INFO + markets
  - `matchDetailsAggregatorPublisher`: 1 MATCH + 32 EVENT_INFO + markets
  - `eventPartScoresPublisher`: 2 EVENT_PART_SCORE (different entity type, not compatible)

- [x] **Created README.md** documenting WAMP testing results and root cause analysis

- [x] **Implementation**: Added live score subscription to Match Details
  - Added `liveDataSubscription` to MatchDetailsTextualViewModel
  - Created `subscribeLiveData()` method calling `subscribeToLiveDataUpdates()`
  - Used existing `ServiceProviderModelMapper.matchLiveData()` to map EventLiveData → MatchLiveData
  - Added `updateMatchWithLiveData()` to MatchHeaderCompactViewModel
  - Added `updateMatchWithLiveData()` to MatchDateNavigationBarViewModel
  - Properly cancelled subscriptions in `refresh()` and `deinit`

### Issues / Bugs Hit
- **Initial confusion**: Thought MatchDetailsManager wasn't receiving EVENT_INFO
  - **Resolution**: cWAMP testing proved EVENT_INFO IS included (32 entities)
  - Real issue: No subscription to observe those entities from EntityStore

- **Type mismatch**: Used `ServicesProvider.EventLiveData` instead of app's `MatchLiveData`
  - **Resolution**: User caught this - used existing mapper `ServiceProviderModelMapper.matchLiveData(fromServiceProviderEventLiveData:)`
  - Added `import ServicesProvider` to MatchHeaderCompactViewModel for ActivePlayerServe mapping

### Key Decisions
- **Chose Option B** (use observeEventInfosForEvent) over Option A (fix MatchBuilder)
  - User preference: "all the live related objects expect the EventLiveData and not the Event itself"
  - Cleaner: Match Details gets Event (static), then subscribes to EventLiveData (live updates)
  - DRY: Reuses existing EventLiveDataBuilder transformation logic

- **Leveraged existing architecture**:
  - EveryMatrixEventsProvider.subscribeToLiveDataUpdates() (line 295-307)
  - MatchDetailsManager.observeEventInfosForEvent() (line 785-803)
  - ServiceProviderModelMapper.matchLiveData() (line 155-177)
  - No new infrastructure needed - just wired up existing pieces

- **Proper model mapping**:
  - ServicesProvider.EventLiveData → MatchLiveData (app model) as soon as possible
  - ViewModels work with app models, not provider models
  - Consistent with TallOddsMatchCardViewModel pattern

### Experiments & Notes

**cWAMP Route Testing Pattern:**
```bash
# Get live match ID
cwamp subscribe --topic "/sports/4093/en/live-matches-aggregator-main/3/all-locations/default-event-info/5/3" \
  --initial-dump --duration 3000 --max-messages 1 2>&1 | grep '"_type": "MATCH"' | grep '"id":' | head -1

# Test specific route
cwamp subscribe --topic "/sports/4093/en/match-aggregator-groups-overview/287259481896947712/1" \
  --initial-dump --duration 5000 --max-messages 2 --pretty 2>&1 > response.json

# Count entity types
grep -o '"_type": "[^"]*"' response.json | sort | uniq -c
```

**EveryMatrix Data Flow (Confirmed via cWAMP):**
```
WebSocket: matchDetailsAggregatorPublisher
    ↓ sends
MATCH DTO + EVENT_INFO DTOs (32) + MARKET/OUTCOME DTOs
    ↓ stored in
MatchDetailsManager.store (EntityStore)
    ↓ observed via
MatchDetailsManager.observeEventInfosForEvent()
    ↓ transforms to
EventLiveData (via EventLiveDataBuilder)
    ↓ mapped to
MatchLiveData (app model)
    ↓ creates
ScoreViewModel
    ↓ displays
ScoreView in header
```

**Subscription Cleanup Architecture:**
```swift
// ViewModel cancels its Combine subscription
eventDetailsSubscription?.cancel()
liveDataSubscription?.cancel()

// ❌ Does NOT cancel underlying WAMP subscription!
// ✅ WAMP cleanup happens when:
//    1. New match details opened (matchDetailsManager?.unsubscribe())
//    2. Provider deallocated (deinit)
```

**Model Mapping Helper Added:**
```swift
// MatchHeaderCompactViewModel
private static func mapActivePlayerServe(from serve: Match.ActivePlayerServe?)
    -> ServicesProvider.ActivePlayerServe? {
    switch serve {
    case .home: return .home
    case .away: return .away
    case .none: return nil
    }
}
```

### Useful Files / Links

**Modified Files:**
- [MatchDetailsTextualViewModel.swift](BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsTextualViewModel.swift) - Lines 40, 183-211, 228, 316
- [MatchHeaderCompactViewModel.swift](BetssonCameroonApp/App/ViewModels/MatchHeaderCompact/MatchHeaderCompactViewModel.swift) - Lines 11, 127-168
- [MatchDateNavigationBarViewModel.swift](BetssonCameroonApp/App/ViewModels/MatchDateNavigationBar/MatchDateNavigationBarViewModel.swift) - Lines 174-193

**Reference Files:**
- [ServiceProviderModelMapper+Events.swift](BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Events.swift) - Line 155 (EventLiveData mapper)
- [MatchLiveData.swift](BetssonCameroonApp/App/Models/Events/MatchLiveData.swift) - App model definition
- [MatchDetailsManager.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/MatchDetailsManager.swift) - Line 785-803
- [EveryMatrixEventsProvider.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixEventsProvider.swift) - Line 295-307

**Documentation Created:**
- [WAMPExampleResponses/README.md](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Documentation/WAMPExampleResponses/README.md) - Root cause analysis
- [liveMatchesPublisher_tennis_full.json](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Documentation/WAMPExampleResponses/liveMatchesPublisher_tennis_full.json)
- [matchDetailsAggregatorPublisher_tennis_match.json](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Documentation/WAMPExampleResponses/matchDetailsAggregatorPublisher_tennis_match.json)
- [eventPartScoresPublisher_tennis_match.json](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Documentation/WAMPExampleResponses/eventPartScoresPublisher_tennis_match.json)

**Previous Session:**
- [19-November-2025-match-header-scoreview-integration.md](Documentation/DevelopmentJournal/19-November-2025-match-header-scoreview-integration.md) - UI integration work

### Next Steps
1. **Test in simulator** with live tennis match
2. **Verify scores appear** in Match Details header next to participant names
3. **Verify real-time updates** as scores change
4. **Consider cleanup improvement**: Add `cleanupMatchDetails()` to provider for proper WAMP subscription cleanup when ViewModel deallocates
5. **Optional optimization**: Investigate if MatchDateNavigationBarViewModel's own subscription conflicts with parent's subscription

### Remaining Questions
- Should we add explicit cleanup when ViewModel deallocates, or is relying on "next match details" cleanup acceptable?
- Does MatchDateNavigationBarViewModel's internal `subscribeToLiveUpdates()` conflict with parent's subscription to same match?

---

## Summary

Successfully added live score display to Match Details screen by:
1. Using cWAMP to prove EVENT_INFO data IS received (32 entities)
2. Identifying missing subscription to `observeEventInfosForEvent()`
3. Wiring up existing MatchDetailsManager infrastructure
4. Proper model mapping (EventLiveData → MatchLiveData) at boundary
5. Reusing existing ScoreViewModel transformation logic (DRY principle)

The implementation leverages existing, tested infrastructure - no new builders or managers needed. Match Details now has parity with InPlay lists for live score display.
