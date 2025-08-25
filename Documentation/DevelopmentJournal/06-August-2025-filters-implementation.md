## Date
06 August 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix infinite loading spinner in filters modal
- Implement filter functionality for NextUpEvents and InPlayEvents screens
- Connect filter UI to actual data filtering
- Ensure filter state persistence across navigation

### Achievements
- [x] Fixed EveryMatrix RPC response decoding for tournament fetching
- [x] Created generic `RPCResponse` model to handle RPC vs subscription responses
- [x] Implemented filter state management at coordinator level
- [x] Connected filters to ServicesProvider filtered subscription methods
- [x] Added filter synchronization between sport selector and filter modal
- [x] Optimized filter updates to skip when unchanged
- [x] Added `storeRecords()` helper to EntityStore for cleaner code

### Issues / Bugs Hit
- [x] EveryMatrix `getTournaments`/`getPopularTournaments` failing due to response model mismatch
- [x] Filters not being applied to actual data fetching
- [x] Filter selections lost when navigating between screens
- [ ] Apply/Reset buttons not disabled when appropriate
- [ ] Cancel button doesn't restore original filters
- [ ] League filter doesn't reset when sport changes
- [ ] No UserDefaults persistence for filters

### Key Decisions
- Store filter state at `RootTabBarCoordinator` level for persistence
- Use existing `MatchesFilterOptions` for ServicesProvider integration
- Create separate `RPCResponse` model for RPC calls vs `AggregatorResponse` for subscriptions
- Apply filters only when explicitly confirmed (Apply button)
- Add Equatable conformance to `AppliedEventsFilters` for change detection

### Experiments & Notes
- Discovered RPC responses have different structure than subscription responses:
  - RPC: `{ version: String, format: "BASIC", records: [...] }`
  - Subscription: `{ version: String, messageType: String, format: String, records: [...] }`
- Filter conversion flow: `AppliedEventsFilters` ↔ `MatchesFilterOptions`
- Tournament fetching happens immediately on sport change in filter modal for better UX

### Useful Files / Links
- [AppliedEventsFilters Model](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift)
- [CombinedFiltersViewController](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewController.swift)
- [MatchesFilterOptions](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Models/MatchesFilterOptions.swift)
- [EveryMatrix RPCResponse](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Response/RPCResponse.swift)
- [RootTabBarCoordinator](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Coordinators/RootTabBarCoordinator.swift)

### Next Steps
1. Implement temporary filter state in modal (don't apply until Apply clicked)
2. Add Apply/Reset button enable/disable logic based on changes
3. Fix Cancel button to properly restore original filters
4. Reset league to "all" when sport changes
5. Add UserDefaults persistence for filter state
6. Fix Reset button to not apply immediately
7. Add "All" option for country league selections
8. Implement loading state for Apply button
9. Add proper request cancellation for tournament fetches

### Technical Details

#### Filter Data Flow
```
User Action → CombinedFiltersViewController → RootTabBarCoordinator 
    → Child Coordinators → ViewModels → ServicesProvider
```

#### Key Components Modified
- **RootTabBarCoordinator**: Added `currentFilters` property and filter management
- **NextUpEventsViewModel**: Updated to use `subscribeToFilteredPreLiveMatches`
- **InPlayEventsViewModel**: Updated to use `subscribeToFilteredLiveMatches`
- **EveryMatrixProvider**: Fixed RPC response handling for tournaments
- **EntityStore**: Added `storeRecords()` bulk storage method

#### Filter Types Supported
- **Sport**: Synchronized with sport selector
- **Time Range**: All, 1h, 8h, Today, 48h
- **Sort By**: Popular, Upcoming, Favorites
- **League/Tournament**: Specific league or all leagues

### Outstanding Requirements (from Q&A)
- Apply button disabled when no changes
- Reset button disabled when already at defaults
- Cancel restores original state without applying changes
- League resets to "all" when sport changes
- UserDefaults persistence across app launches
- "All" option for country-level league selection
- Loading state management during tournament fetching
- Proper request cancellation for rapid sport changes