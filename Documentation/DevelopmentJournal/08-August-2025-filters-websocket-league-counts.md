## Date
08 August 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix ServicesProvider paginators to use customMatchesAggregatorPublisher for filtered subscriptions
- Fix Popular vs Other Countries categorization logic in filters
- Add missing WebSocket parameters to tournament RPC calls
- Implement correct league event counts based on screen type (live vs pre-live)

### Achievements
- [x] Updated PreLiveMatchesPaginator and LiveMatchesPaginator to use `customMatchesAggregatorPublisher` when filters are provided
- [x] Fixed Popular Countries logic - now only shows countries that have leagues in top 10 popular leagues
- [x] Added missing parameters to `getTournaments` and `getPopularTournaments` RPC calls (liveStatus, sortByPopularity, maxResults)
- [x] Implemented separate event counts for live and pre-live screens
- [x] Refactored property names from `.webAppValue` to `.serverRawValue` for clarity

### Issues / Bugs Hit
- [x] Paginators were ignoring filters and using simple endpoints instead of customMatchesAggregatorPublisher
- [x] Popular Countries included ALL countries with popular leagues instead of only those in top 10
- [x] League counts were showing combined (pre-live + live) instead of context-specific counts
- [ ] "Favorites" sort option should be hidden when user not logged in (deferred - no login system yet)

### Key Decisions
- Use `customMatchesAggregatorPublisher` WebSocket endpoint when filters are present, fallback to simple endpoints when not
- Separate `numberEvents` and `numberLiveEvents` in Competition model to preserve both values
- Add `isLiveMode` parameter to filter view models to determine which count to display
- Renamed `.webAppValue` to `.serverRawValue` since values are server requirements, not web app specific

### Experiments & Notes
- Discovered EveryMatrix WebSocket expects specific parameter formats:
  - `locationId`: "all" when no filter
  - `tournamentId`: "all" when no filter  
  - `hoursInterval`: "all", "0-1", "0-24", etc.
  - `sortEventsBy`: "POPULAR", "UPCOMING", "FAVORITES" (uppercase)
  - `liveStatus`: "LIVE", "NOT_LIVE", "BOTH"
- Special "{countryId}_all" format from UI needs to be parsed to set location filter

### Useful Files / Links
- [PreLiveMatchesPaginator](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/PreLiveMatchesPaginator.swift)
- [CombinedFiltersViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModel.swift)
- [AppliedEventsFilters+MatchesFilterOptions](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/AppliedEventsFilters+MatchesFilterOptions.swift)
- [WAMPRouter](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/WAMPClient/WAMPRouter.swift)
- [Competition Model](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Models/Events/Competition.swift)

### Technical Details

#### Filter Categorization Logic
**Popular Leagues**: Top 10 from `getPopularTournaments`
**Popular Countries**: Countries that have at least one league in top 10
**Other Countries**: Countries with no leagues in top 10

#### Event Count Display Rules
- **NextUpEvents/PreLive**: Show `numberOfEvents`
- **InPlayEvents/Live**: Show `numberOfLiveEvents`

#### WebSocket Filter Implementation
```swift
// Paginators now check for filters
if let filters = filters {
    router = WAMPRouter.customMatchesAggregatorPublisher(
        // ... use filter parameters
    )
} else {
    router = WAMPRouter.popularMatchesPublisher(
        // ... fallback to simple endpoint
    )
}
```

### Next Steps
1. Test filtered subscriptions with various filter combinations
2. Verify event counts display correctly in both live and pre-live contexts
3. Consider implementing user authentication to conditionally show "Favorites" filter
4. Monitor WebSocket performance with filtered vs unfiltered subscriptions
5. Add request cancellation for rapid sport changes in filter modal