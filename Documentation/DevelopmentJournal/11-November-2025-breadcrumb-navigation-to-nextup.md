## Date
11 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Implement breadcrumb tap navigation from match details to NextUp events screen
- Apply country/league filters when navigating back
- Maintain current sport filter when applying breadcrumb filters

### Achievements
- [x] Researched complete filter architecture (AppliedEventsFilters, LeagueFilterIdentifier, MatchesFilterOptions)
- [x] Mapped EveryMatrix WebSocket filter capabilities (location, tournament, sport, time, sort)
- [x] Identified coordinator navigation flow (MainTabBarCoordinator → NextUpEventsCoordinator)
- [x] Added `onNavigateToHomeWithFilters` closure to MatchDetailsTextualViewModel
- [x] Implemented `handleCountryTapped()` and `handleLeagueTapped()` helper methods
- [x] Wired breadcrumb callbacks in `setupBindings()`
- [x] Connected navigation closure in MainTabBarCoordinator.showMatchDetail

### Issues / Bugs Hit
- [ ] **Missing import**: `FilterIdentifier` not in scope - need `import SharedModels`
- [ ] **Incorrect sport ID source**: Using `match.sport.id` instead of coordinator's `currentFilters.sportId`
- [ ] **Incorrect FilterIdentifier syntax**: `.singleSport("1")` should be `.singleSport(id: "1")`
- [ ] **Poor naming**: "Home" terminology is vague - should be "NextUpEvents"

### Key Decisions
- **Always navigate to NextUp**: Regardless of match status (live/pre-live), always go to NextUp tab
- **Ignore nil IDs**: If country/league ID is nil, ignore tap (no navigation)
- **Use coordinator's sport filter**: Pass `currentFilters.sportId` from coordinator instead of extracting from match
  - Reason: Match's sport might not match what user is currently filtering by
  - Example: User filters by Football, then navigates to Tennis match via search → breadcrumb should preserve Football filter
- **Filter structure**:
  - Country tap → `.allInCountry(countryId)` (all leagues in that country)
  - League tap → `.singleLeague(id)` (specific league only)

### Experiments & Notes
- Discovered that filters use enum-based identifiers (`FilterIdentifier`, `LeagueFilterIdentifier`)
- EveryMatrix WebSocket custom-matches-aggregator endpoint format:
  ```
  /sports/{operatorId}/{lang}/custom-matches-aggregator/{sportId}/{locationId}/{tournamentId}/{hoursInterval}/{sortEventsBy}/{liveStatus}/{eventLimit}/{mainMarketsLimit}
  ```
- MainTabBarCoordinator stores `currentFilters: AppliedEventsFilters` loaded from UserDefaults
- Filter conversion layer: `AppliedEventsFilters` → `MatchesFilterOptions` (UI model → Service model)

### Useful Files / Links
- [AppliedEventsFilters](../../../BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift) - UI filter model
- [FilterIdentifier](../../../Frameworks/SharedModels/Sources/SharedModels/FilterIdentifier.swift) - Sport filter enum (`.all`, `.singleSport(id:)`)
- [LeagueFilterIdentifier](../../../Frameworks/SharedModels/Sources/SharedModels/LeagueFilterIdentifier.swift) - League filter enum (`.all`, `.allInCountry(countryId:)`, `.singleLeague(id:)`)
- [MatchesFilterOptions](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/MatchesFilterOptions.swift) - Service layer filter model
- [MainTabBarCoordinator](../../../BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift:803-812) - `applyFilters()` method
- [MatchDetailsTextualViewModel](../../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsTextualViewModel.swift) - Match details screen logic
- [NextUpEventsViewModel](../../../BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewModel.swift:136-155) - Filter update logic

### Next Steps
1. **Fix compilation errors**:
   - Add `import SharedModels` to MatchDetailsTextualViewModel
   - Pass `currentFilters.sportId` from MainTabBarCoordinator to MatchDetailsTextualViewModel init
   - Fix FilterIdentifier syntax: `.singleSport(id: "...")` (add `id:` label)
2. **Refactor naming**:
   - Rename `onNavigateToHomeWithFilters` → `onNavigateToNextUpWithFilters`
   - Rename `navigateToHomeWithCountryFilter` → `navigateToNextUpWithCountryFilter`
   - Rename `navigateToHomeWithLeagueFilter` → `navigateToNextUpWithLeagueFilter`
3. **Test breadcrumb navigation**:
   - Tap country in breadcrumb → verify NextUp shows all leagues in that country with current sport
   - Tap league in breadcrumb → verify NextUp shows that specific league with current sport
   - Verify filter state persists across app restarts (UserDefaults)
4. **Consider future enhancements**:
   - Add analytics tracking for breadcrumb navigation
   - Consider adding loading state during filter application
   - Evaluate if we should also support InPlay navigation (currently always NextUp)
