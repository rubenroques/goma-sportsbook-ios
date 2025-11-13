## Date
13 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Refactor breadcrumb navigation callbacks to use clean architecture (pass IDs up, coordinator assembles filters)
- Fix bug where breadcrumb navigation sends wrong location ID to filter endpoint (GB1 instead of 77)
- Understand why EveryMatrix location ID was being lost in mapping chain

### Achievements
- [x] Refactored MatchDetailsTextualViewModel to use two separate closures instead of passing complete AppliedEventsFilters
- [x] Changed callbacks from `onNavigateToHomeWithFilters((AppliedEventsFilters) -> Void)` to `onNavigateToNextUpWithCountry((String) -> Void)` and `onNavigateToNextUpWithLeague((String) -> Void)`
- [x] MainTabBarCoordinator now assembles filters using `currentFilters.sportId` to preserve user's current sport selection
- [x] Identified root cause: `Country.country(withName:)` string lookup was discarding EveryMatrix location ID "77"
- [x] Added optional `id: String?` field to SharedModels Country struct
- [x] Fixed EveryMatrixModelMapper to create Country directly from EveryMatrix.Location, preserving ID
- [x] Updated ServiceProviderModelMapper to use `venueCountry.id` instead of `iso2Code` for Location
- [x] Verified that `currentFilters` is always initialized (either from UserDefaults or default filters)

### Issues / Bugs Hit
- [x] **Wrong location ID in filter endpoint**: Breadcrumb sent `GB1` (ISO code) instead of `77` (EveryMatrix ID)
  - Root cause: `Country.country(withName: venue.name)` hardcoded lookup lost the numeric ID
  - Filter endpoint expected: `/sports/4093/en/custom-matches-aggregator/1/77/all/...`
  - Was sending: `/sports/4093/en/custom-matches-aggregator/1/GB1/all/...`

### Key Decisions
- **Clean callback architecture**: ViewModel passes raw IDs up the stack, Coordinator (with more context) assembles complete filters
  - Reason: Better separation of concerns - ViewModel shouldn't know about filter structure
  - MatchDetailsTextualViewModel just passes `countryId` or `leagueId`
  - MainTabBarCoordinator has access to `currentFilters.sportId` and builds `AppliedEventsFilters`
- **Add optional ID to Country instead of creating new VenueLocation type**
  - Reason: Simpler, backward compatible, semantically acceptable
  - Country already used for venue, just needed to preserve provider-specific ID
  - Made all Country init parameters have defaults to avoid breaking existing code
- **Direct Country creation instead of hardcoded lookup**
  - Old: `Country.country(withName: venue.name)` - string matching, lost ID
  - New: `Country(id: venue.id, name: venue.name, iso2Code: venue.code ?? "")` - direct mapping
  - Reason: Preserves all data from EveryMatrix instead of lossy string lookup

### Experiments & Notes
- Discovered that `currentFilters` is initialized at coordinator creation:
  - First checks UserDefaults for persisted filters from previous session
  - Falls back to `AppliedEventsFilters.defaultFilters` (Football, All leagues, Popular)
  - This means breadcrumb navigation will always have a valid sport filter
- Data flow for breadcrumb navigation:
  1. User taps "England" in breadcrumb
  2. MatchHeaderCompactView → MatchHeaderCompactViewModel.handleCountryTap()
  3. Calls `onCountryTapped?("77")`
  4. MatchDetailsTextualViewModel.handleCountryTapped(countryId: "77")
  5. Calls `onNavigateToNextUpWithCountry?("77")`
  6. MainTabBarCoordinator builds filters: `AppliedEventsFilters(sportId: currentFilters.sportId, leagueFilter: .allInCountry(countryId: "77"))`
  7. Applies filters and navigates to NextUp screen

### Useful Files / Links
- [Country.swift](../../Frameworks/SharedModels/Sources/SharedModels/Country.swift) - Added optional id field
- [EveryMatrixModelMapper+Events.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+Events.swift:42-50) - Direct Country creation from EveryMatrix.Location
- [ServiceProviderModelMapper+Events.swift](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Events.swift:72-75) - Use Country.id for Location
- [MatchDetailsTextualViewModel.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsTextualViewModel.swift:19-20) - Clean callback architecture
- [MainTabBarCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift:299-327) - Filter assembly with currentFilters.sportId
- [AppliedEventsFilters.swift](../../BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift:127-132) - Default filters definition

### Next Steps
1. **Test breadcrumb navigation in simulator**:
   - Tap country in breadcrumb → verify filter endpoint sends numeric ID (77 not GB1)
   - Verify NextUp shows correct filtered events with preserved sport filter
   - Test with different sport selections to confirm currentFilters.sportId is used
2. **Investigate sport.id returning "0"** (deferred from this session):
   - Check how Sport is mapped from EveryMatrix
   - Verify if SportBuilder is preserving the correct sport ID
3. **Consider refactoring other hardcoded Country lookups**:
   - Found 14 files still using `Country.country(withName:)` pattern
   - May need similar fixes in SportRadar and Goma providers
