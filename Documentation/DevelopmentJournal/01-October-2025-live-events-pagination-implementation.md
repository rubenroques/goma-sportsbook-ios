## Date
01 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Add pagination support to LiveMatchesPaginator (mirror PreLiveMatchesPaginator implementation)
- Implement pagination UI for InPlay events screen (Load More button + footer)
- Wire pagination callbacks from ViewController → ViewModel → ServicesProvider
- Ensure backend pagination API is complete and exposed through Client

### Achievements
- [x] Refactored LiveMatchesPaginator to support pagination with PassthroughSubject bridge pattern
- [x] Added `currentEventLimit` increment logic (10→20→30...) with max limit of 100
- [x] Implemented `loadNextPage()` with guards and state management
- [x] Added end-of-data detection (matchCount < currentEventLimit)
- [x] Added pagination state properties to InPlayEventsViewModel (hasMoreEvents, isLoadingMore)
- [x] Implemented `loadNextPage()` method in InPlayEventsViewModel using `requestFilteredLiveMatchesNextPage()`
- [x] Updated `processMatches()` to propagate pagination state to child ViewModels
- [x] Wired `onLoadMoreTapped` callback in InPlayEventsViewController
- [x] Added missing `requestFilteredLiveMatchesNextPage()` public method to Client.swift
- [x] Fixed parameter naming in LiveMatchesPaginator init (`numberOfEvents` → `initialEventLimit`)
- [x] Updated EveryMatrixProvider call sites to use new parameter name

### Issues / Bugs Hit
- **Build error**: `Value of type 'Client' has no member 'requestFilteredLiveMatchesNextPage'`
  - **Root cause**: Method existed in EventsProvider protocol and EveryMatrixProvider implementation, but was not exposed in Client.swift public API
  - **Fix**: Added public method to Client.swift:338-344
- **Build error**: `Extra argument 'numberOfEvents' in call`
  - **Root cause**: Changed LiveMatchesPaginator parameter name but didn't update call sites
  - **Fix**: Updated EveryMatrixProvider.swift lines 67, 73, 141, 147 to use `initialEventLimit`

### Key Decisions
- **Mirror PreLive implementation**: Used exact same pattern from PreLiveMatchesPaginator for consistency
  - PassthroughSubject bridge keeps external subscription alive during internal re-subscriptions
  - Replacement strategy with `store.clear()` prevents duplicate events
  - Same pagination constants: `eventLimitIncrement = 10`, `maxEventLimit = 100`
- **Reuse existing UI**: MarketGroupCardsViewController already had 3-section layout from NextUp implementation
  - No UI changes needed for InPlay - Load More button and footer already implemented
  - Only needed to wire callback and add ViewModel logic
- **Parallel structure**: InPlay pagination exactly mirrors NextUp pagination
  - NextUp: `requestFilteredPreLiveMatchesNextPage()`
  - InPlay: `requestFilteredLiveMatchesNextPage()`
  - Same state management, same UI, same user experience

### Architecture Notes

#### Pagination Flow (LiveMatchesPaginator)
```
User taps Load More
  ↓
InPlayEventsViewController.onLoadMoreTapped
  ↓
InPlayEventsViewModel.loadNextPage()
  ↓
Client.requestFilteredLiveMatchesNextPage(filters)
  ↓
EventsProvider.requestFilteredLiveMatchesNextPage(filters)
  ↓
EveryMatrixProvider.requestFilteredLiveMatchesNextPage(filters)
  ↓
LiveMatchesPaginator.loadNextPage()
  ↓ increment currentEventLimit (10→20)
  ↓ cancel old WAMP subscription
  ↓ clear store
  ↓ subscribe with new limit
  ↓
New data flows through contentSubject
  ↓
ViewModel.processMatches() receives update
  ↓ reset isLoadingMore = false
  ↓ propagate hasMoreEvents to child ViewModels
  ↓
UI updates (Load More button hides if hasMoreEvents = false)
```

#### PassthroughSubject Bridge Pattern
**Problem**: Need to re-subscribe to WAMP with different `eventLimit` parameter, but ViewModel has a single long-lived subscription.

**Solution**: Two-layer subscription architecture
- **External layer**: ViewModel subscribes to `contentSubject.eraseToAnyPublisher()` (stable, never breaks)
- **Internal layer**: Paginator creates/destroys WAMP subscriptions as needed
- All WAMP data flows through `contentSubject.send()` to external subscribers

**Benefits**:
- ViewModel subscription remains alive during pagination
- Paginator can recreate WAMP connections with new parameters
- Clean separation of concerns

### Experiments & Notes
- **End-of-data detection**: Server returns ALL N events when requesting limit=N, so we detect end by checking `matchCount < currentEventLimit`
- **State propagation**: Parent ViewModel pushes `hasMoreEvents`/`isLoadingMore` to all child ViewModels to ensure consistent UI state across market group tabs
- **Section-based visibility**: Load More button controlled by returning 0 items for `loadMoreButton` section when `hasMoreEvents = false` - cleaner than isHidden flags

### Useful Files / Links
- [LiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/LiveMatchesPaginator.swift) - Core pagination logic for live matches
- [PreLiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/PreLiveMatchesPaginator.swift) - Reference implementation
- [InPlayEventsViewModel.swift](../../BetssonCameroonApp/App/Screens/InPlayEvents/InPlayEventsViewModel.swift) - Added pagination state and loadNextPage()
- [InPlayEventsViewController.swift](../../BetssonCameroonApp/App/Screens/InPlayEvents/InPlayEventsViewController.swift) - Wired onLoadMoreTapped callback
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Public API (added requestFilteredLiveMatchesNextPage)
- [EventsProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/EventsProvider.swift) - Protocol definition
- [EveryMatrixProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift) - Implementation

### Previous Session Reference
- [01-October-2025-pagination-load-more-ui.md](./01-October-2025-pagination-load-more-ui.md) - NextUp pagination implementation (PreLive matches)

### Next Steps
1. Test pagination in simulator with real EveryMatrix live data
2. Verify Load More button appears/hides correctly for both NextUp and InPlay
3. Test edge cases:
   - What happens when server has exactly 10/20/30 events?
   - Does end-of-data detection work correctly?
   - Are loading states properly handled during pagination?
4. Consider adding analytics events for pagination usage tracking
5. Optimize button text to show count (e.g., "Load 10 more events")
6. Add error handling UI for pagination failures
7. Test with slow network to ensure loading state works correctly
