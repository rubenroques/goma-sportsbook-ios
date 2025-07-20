## Date
20 July 2025

### Project / Branch
sportsbook-ios / feature/custom-matches-aggregator

### Goals for this session
- Implement custom-matches-aggregator WebSocket topic support for iOS app
- Achieve parity with web app's filter implementation
- Replace legacy popularMatchesPublisher/liveMatchesPublisher with filtered system
- Maintain backward compatibility and clean architecture

### Achievements
- [x] Created enum-based filter system (MatchesFilterOptions with TimeRange, SortBy, LocationFilter, TournamentFilter)
- [x] Added customMatchesAggregatorPublisher case to WAMPRouter with full parameter support
- [x] Updated PreLiveMatchesPaginator and LiveMatchesPaginator to use custom-matches-aggregator
- [x] Implemented MatchesFilterOptions.noFilters() for backward compatibility
- [x] Added filtered subscription methods to EventsProvider protocol
- [x] Updated EveryMatrix provider with subscribeToFilteredPreLiveMatches/subscribeToFilteredLiveMatches
- [x] Added stub implementations to GomaProvider and SportRadarEventsProvider (return notSupportedForProvider)
- [x] Updated Client.swift public API with new filtered subscription methods
- [x] Integrated view models (NextUpEventsViewModel, InPlayEventsViewModel) to use filtered subscriptions
- [x] Fixed module boundary violations by moving GeneralFilterSelection extensions to Core module
- [x] Successful build with all protocol conformance issues resolved

### Issues / Bugs Hit
- [x] ~~Module boundary violation: GeneralFilterSelection extension in ServicesProvider~~
- [x] ~~Protocol conformance errors: GomaProvider and SportRadarEventsProvider missing filtered methods~~
- [x] ~~Build error: Extension file not included in Xcode project (resolved by manual addition)~~

### Key Decisions
- **Enum-based filter system**: Used strongly-typed enums instead of string literals for better type safety
- **MatchesFilterOptions.noFilters()**: Provides clean default behavior, avoiding legacy topic fallback
- **Separate live/prelive functions**: Maintained architectural separation as requested by user
- **Filter conversion in Core module**: Placed GeneralFilterSelection extensions in CombinedFilters folder for logical grouping
- **Fail gracefully**: Non-EveryMatrix providers return .notSupportedForProvider for filtered methods

### Experiments & Notes
- Web app uses custom-matches-aggregator/{sportId}/{locationId}/{tournamentId}/{hoursInterval}/{sortEventsBy}/{liveStatus}/{eventLimit}/{mainMarketsLimit}/{optionalUserId?}
- Filter parameter mapping matches web app exactly:
  - Time: 'all', '0-1', '0-8', '0-24', '0-48'
  - Sort: 'POPULAR', 'UPCOMING', 'FAVORITES' 
  - Live status: 'LIVE' vs 'NOT_LIVE'
- Always uses custom-matches-aggregator topic now (no legacy fallback)

### Useful Files / Links
- [WAMPRouter.swift](../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/WAMPClient/WAMPRouter.swift) - Added customMatchesAggregatorPublisher case
- [MatchesFilterOptions.swift](../ServicesProvider/Sources/ServicesProvider/Models/MatchesFilterOptions.swift) - Core filter enum system
- [GeneralFilterSelection+MatchesFilterOptions.swift](../Core/Screens/NextUpEvents/CombinedFilters/GeneralFilterSelection+MatchesFilterOptions.swift) - Filter conversion extensions
- [PreLiveMatchesPaginator.swift](../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/PreLiveMatchesPaginator.swift) - Updated to use custom-matches-aggregator
- [LiveMatchesPaginator.swift](../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/LiveMatchesPaginator.swift) - Updated to use custom-matches-aggregator
- [EventsProvider.swift](../ServicesProvider/Sources/ServicesProvider/Protocols/EventsProvider.swift) - Added filtered subscription methods
- [Client.swift](../ServicesProvider/Sources/ServicesProvider/Client.swift) - Public API for filtered subscriptions

### Next Steps
1. **Test functionality**: Verify same matches appear with no filters applied (current filter storage defaults)
2. **Test filter changes**: Verify real-time filter updates work correctly
3. **Add filter reactivity**: Consider adding automatic subscription refresh when filters change
4. **Architecture improvement**: Implement better filter state management (move away from Env.filterStorage global state)
5. **User ID support**: Test favorites filtering with optional user ID parameter
6. **Performance testing**: Compare WebSocket traffic between old and new implementations

### Architecture Notes for Future
- Current `Env.filterStorage.currentFilterSelection` violates MVVM principles
- Consider dependency injection pattern for filter state management
- Proposed: FilterStateProviding protocol with MockFilterStateProvider for testing
- Benefits: Better testability, clearer dependencies, thread safety