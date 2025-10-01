## Date
01 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Understand EveryMatrix data flow for NextUp events (WebSocket → EntityStore → UI)
- Implement simulated pagination for pre-live matches (eventLimit-based)
- Add Load More button UI to MarketGroupCardsViewController
- Add footer section below matches list

### Achievements
- [x] Documented complete end-to-end data flow for NextUp events with EveryMatrix provider
- [x] Implemented pagination logic in PreLiveMatchesPaginator using PassthroughSubject pattern
- [x] Added hasMoreEvents publisher to NextUpEventsViewModel with proper state management
- [x] Created FooterCollectionViewCell with StyleProvider theming
- [x] Expanded MarketGroupCardsViewController to 3-section layout (matches, loadMore, footer)
- [x] Wired up pagination callbacks through MVVM-C pattern
- [x] Button shows/hides based on hasMoreEvents state (returns 0 items when false)
- [x] Loading state properly propagated from parent to child ViewModels

### Issues / Bugs Hit
- None - implementation went smoothly

### Key Decisions
- **Pagination Strategy**: Re-subscribe with increasing eventLimit (10→20→30) instead of true cursor-based pagination
  - EveryMatrix custom-matches-aggregator doesn't support traditional pagination
  - Server returns ALL events up to limit (duplicates handled by store.clear())
  - PassthroughSubject keeps ViewModel subscription alive during internal re-subscriptions
- **Section-based UI**: Used casino page pattern with conditional section rendering
  - Section 1 (loadMore) returns 0 items when hasMoreEvents=false to hide button
  - Cleaner than rebuilding entire snapshot or using isHidden flags
- **State Propagation**: Parent ViewModel pushes hasMoreEvents/isLoadingMore to all child ViewModels
  - Ensures all market group tabs show consistent pagination state
  - Avoids complex cross-ViewModel communication

### Architecture Notes

#### Data Flow: NextUp Events (EveryMatrix)
```
NextUpEventsViewController (UI Layer)
  ↓
NextUpEventsViewModel (Business Logic)
  ↓ loadEvents()
ServicesProvider.Client (Abstraction Layer)
  ↓ subscribeToFilteredPreLiveMatches(filters:)
EveryMatrixEventsProvider
  ↓ creates PreLiveMatchesPaginator
PreLiveMatchesPaginator (Subscription Manager)
  ↓ subscribe() → buildRouter() → eventLimit parameter
EveryMatrixConnector (WebSocket Layer)
  ↓ subscribe(router) via WAMPManager
WAMP Protocol
  ↓ Topic: /sports/4093/en/custom-matches-aggregator/1/all/all/0-24/POPULAR/NOT_LIVE/{eventLimit}/5
EveryMatrix Server
  ↓ INITIAL_DUMP message
WAMPSubscriptionContent<AggregatorResponse>
  ↓ handleSubscriptionContent()
EntityStore (Reactive Data Store)
  - stores flat DTOs (Match, Market, Outcome, BettingOffer)
  - handles UPDATE/DELETE/CREATE change records
  ↓ buildEventsGroups()
EveryMatrixModelMapper
  ↓ maps internal models to domain models
ViewModel.processMatches()
  ↓ updates allMatches, propagates to child ViewModels
UI Update via Combine Publishers
```

#### Pagination Implementation Pattern
**PreLiveMatchesPaginator**:
- Uses `PassthroughSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>` to keep external subscription alive
- Internal subscription recreated on pagination (unsubscribe → clear → resubscribe)
- `currentEventLimit` incremented by 10 each page
- End detection: `matchCount < currentEventLimit` → `hasMoreEvents = false`

**Key Properties**:
- `contentSubject`: Stable bridge for external subscribers
- `internalSubscriptionCancellable`: Manages WAMP lifecycle
- `currentEventLimit`: Mutable page size (10, 20, 30...)
- `isPaginationInProgress`: Guard against duplicate requests
- `hasMoreEvents`: End-of-data detection

### Experiments & Notes
- **PreviewUIViewController vs PreviewUIView**: GomaUI components should use PreviewUIViewController for better AutoLayout rendering in SwiftUI previews
- **SeeMoreButtonCollectionViewCell**: Reused existing GomaUI component instead of creating custom button
- **DiffableDataSource with conditional sections**: Returning 0 items for a section effectively hides it without breaking layout

### Useful Files / Links
- [PreLiveMatchesPaginator.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/PreLiveMatchesPaginator.swift) - Core pagination logic
- [NextUpEventsViewModel.swift](BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewModel.swift) - Parent ViewModel with hasMoreEvents publisher
- [MarketGroupCardsViewController.swift](BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewController.swift) - 3-section collection view
- [FooterCollectionViewCell.swift](BetssonCameroonApp/App/Screens/NextUpEvents/FooterCollectionViewCell.swift) - New footer cell
- [SeeMoreButtonCollectionViewCell.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SeeMoreButtonView/SeeMoreButtonCollectionViewCell.swift) - GomaUI load more button
- [CasinoCategoryGamesListViewController.swift](BetssonCameroonApp/App/Screens/Casino/CasinoCategoryGamesList/CasinoCategoryGamesListViewController.swift) - Reference pattern for load more button

### Next Steps
1. Test pagination in simulator with real EveryMatrix data
2. Consider adding pull-to-refresh for initial data reload
3. Add analytics events for pagination (track how many users load more pages)
4. Optimize button text (maybe show count like casino: "Load 10 more events")
5. Add loading skeleton during initial eventLimit=10 load
6. Consider prefetching next page when user scrolls to 80% of list
