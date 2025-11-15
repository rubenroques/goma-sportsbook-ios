# Filters Empty Leagues Bug Fix Session

## Date
14 November 2025

## Project / Branch
sportsbook-ios / rr/breadcrumb

## Goals for this session
- Diagnose why CombinedFiltersViewController shows empty leagues/countries sections
- Add comprehensive debug logging to track data flow through filter system
- Fix the root cause of empty filter data

## Achievements
- [x] Added comprehensive debug logs throughout CombinedFiltersViewModel data flow
- [x] Identified root cause: type mismatch in ViewModel refresh methods
- [x] Fixed type casting from Mock to Protocol types (3 locations)
- [x] Documented architectural code smell in TODO_TASKS.md
- [x] Verified data flow: 269 competitions fetched, 75 countries processed correctly

## Issues / Bugs Hit
- [x] **ViewModel Type Mismatch** - `refreshLeaguesFilterData()` and `refreshCountryLeaguesFilterData()` were casting to Mock types (`MockSortFilterViewModel`, `MockCountryLeaguesFilterViewModel`) but ViewModels were created as production types (`SortFilterViewModel`, `CountryLeaguesFilterViewModel`)
  - Symptom: All three error logs showed "ViewModel not found or wrong type"
  - Impact: League data fetched successfully (10 popular, 269 total) but never reached UI
  - Fix: Changed casts to protocol types (`SortFilterViewModelProtocol`, `CountryLeaguesFilterViewModelProtocol`)

## Key Decisions
- **Short-term fix**: Use protocol-based casting instead of concrete Mock types
  - Reasoning: Protocols define the `updateSortOptions` and `updateCountryLeagueOptions` methods
  - Both Mock and Production ViewModels implement these protocols
  - Maintains current architecture while fixing the bug

- **Long-term refactor needed**: Replace `dynamicViewModels: [String: Any]` with strongly-typed properties
  - Current architecture uses type erasure (`Any`) defeating Swift's type safety
  - Magic string keys ("leaguesFilter", "popularCountryLeaguesFilter") are fragile
  - Runtime casting required throughout - failures only discovered at runtime
  - Root cause: Over-engineered "configuration-driven" design that isn't actually being used
  - Added to TODO_TASKS.md for future cleanup

## Debug Logs Added

### ViewModel Initialization (lines 40-52)
```
[FILTERS_DEBUG] ========== CombinedFiltersViewModel INIT ==========
[FILTERS_DEBUG] Current filters - sportId: X, timeFilter: Y, sortType: Z, leagueFilter: W
[FILTERS_DEBUG] Context: sports, isLiveMode: false
[FILTERS_DEBUG] Calling getAllLeagues() on init
```

### League Fetching (lines 58-71)
```
[FILTERS_DEBUG] ========== getAllLeagues CALLED ==========
[FILTERS_DEBUG] Requested sportId parameter: 1 (or nil)
[FILTERS_DEBUG] Overriding with new sportId: FilterIdentifier.singleSport("1")
[FILTERS_DEBUG] Looking for sport: 1
[FILTERS_DEBUG] Available sports: 1:Football, 2:Basketball, ...
```

### Data Processing (lines 119-272)
```
[FILTERS_DEBUG] ========== setupAllLeagues START ==========
[FILTERS_DEBUG] Input - popularCompetitions: 10, sportCompetitions: 269
[FILTERS_DEBUG] Popular Leagues created: 11 (including 'All' option)
[FILTERS_DEBUG] Total events in popular leagues: 220
[FILTERS_DEBUG] VenueDict built with 75 countries/venues
[FILTERS_DEBUG]   - France (ID: fra): 12 leagues
[FILTERS_DEBUG] Final Results:
[FILTERS_DEBUG]   - popularLeagues: 11
[FILTERS_DEBUG]   - popularCountryLeagues: 5
[FILTERS_DEBUG]   - otherCountryLeagues: 70
```

### ViewModel Updates (lines 254-300)
```
[FILTERS_DEBUG] refreshLeaguesFilterData - updating leaguesFilter ViewModel
[FILTERS_DEBUG]   - Found leaguesFilter ViewModel, updating with 11 options
[FILTERS_DEBUG] refreshCountryLeaguesFilterData - updating country ViewModels
[FILTERS_DEBUG]   - Found popularCountryLeaguesFilter ViewModel, updating with 5 countries
[FILTERS_DEBUG]   - Found otherCountryLeaguesFilter ViewModel, updating with 70 countries
```

## Code Changes

### File: `BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModel.swift`

**Line 277** - Leagues Filter ViewModel Cast:
```swift
- if let leaguesViewModel = dynamicViewModels["leaguesFilter"] as? MockSortFilterViewModel {
+ if let leaguesViewModel = dynamicViewModels["leaguesFilter"] as? SortFilterViewModelProtocol {
```

**Line 288** - Popular Countries Filter ViewModel Cast:
```swift
- if let countryLeaguesViewModel = dynamicViewModels["popularCountryLeaguesFilter"] as? MockCountryLeaguesFilterViewModel {
+ if let countryLeaguesViewModel = dynamicViewModels["popularCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol {
```

**Line 295** - Other Countries Filter ViewModel Cast:
```swift
- if let otherCountryLeaguesViewModel = dynamicViewModels["otherCountryLeaguesFilter"] as? MockCountryLeaguesFilterViewModel {
+ if let otherCountryLeaguesViewModel = dynamicViewModels["otherCountryLeaguesFilter"] as? CountryLeaguesFilterViewModelProtocol {
```

## Architectural Analysis

### Current Architecture (Code Smell)
```swift
// Type erasure defeats Swift's type safety
var dynamicViewModels: [String: Any] = [:]

// Runtime casting required everywhere
if let vm = dynamicViewModels["leaguesFilter"] as? SortFilterViewModelProtocol {
    // ...
}
```

**Problems:**
1. Lost type safety - `Any` defeats Swift's strong typing
2. Runtime failures - type mismatches only discovered at runtime
3. Magic strings - no autocomplete, refactoring support, or typo detection
4. Fragile - easy to break when refactoring

### Why This Architecture Exists
- Designed to be "configuration-driven" for dynamic filter layouts
- FilterConfiguration defines widgets that can be added/removed/reordered
- Intent: Make it easy to modify filters without code changes

### Reality Check
- FilterConfiguration is **hardcoded** in `createFilterConfiguration()` (line 395)
- Filters are **sports-specific** and unlikely to change dramatically
- ViewController already knows about specific widget IDs (lines 564-640)
- **The "flexibility" isn't actually being used**

### Recommended Refactor (Future)
Replace with strongly-typed properties:
```swift
class CombinedFiltersViewModel {
    private(set) var sportsFilterViewModel: SportGamesFilterViewModelProtocol?
    private(set) var timeFilterViewModel: TimeSliderViewModelProtocol?
    private(set) var leaguesFilterViewModel: SortFilterViewModelProtocol?
    private(set) var popularCountriesViewModel: CountryLeaguesFilterViewModelProtocol?
    private(set) var otherCountriesViewModel: CountryLeaguesFilterViewModelProtocol?

    func refreshLeaguesFilterData() {
        leaguesFilterViewModel?.updateSortOptions(popularLeagues)  // ✅ No casting!
    }
}
```

**Benefits:**
- ✅ Compile-time type safety
- ✅ No runtime casting
- ✅ Autocomplete works
- ✅ Refactoring-friendly
- ✅ Clear, explicit dependencies

## Useful Files / Links
- [CombinedFiltersViewController](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewController.swift)
- [CombinedFiltersViewModel](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModel.swift)
- [AppliedEventsFilters](../../BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift)
- [FilterConfiguration Models](../../BetssonCameroonApp/App/Models/Events/Filters.swift)
- [SortFilterViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SortFilterView/SortFilterViewModelProtocol.swift)
- [CountryLeaguesFilterViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CountryLeaguesFilterView/CountryLeaguesFilterViewModelProtocol.swift)

## Data Flow Summary

```
User Opens Filters Modal
    ↓
MainTabBarCoordinator.showFilters()
    ↓
CombinedFiltersViewController.init(currentFilters, configuration)
    ↓
CombinedFiltersViewModel.init()
    ├─ createDynamicViewModels() → Creates production ViewModels
    └─ getAllLeagues()
        ↓
ServicesProvider RPC Calls (Parallel)
    ├─ getTournaments(forSportType: football) → 269 competitions
    └─ getPopularTournaments(count: 10) → 10 competitions
        ↓
setupAllLeagues(popular: 10, sport: 269)
    ├─ Build popularLeagues: [SortOption] (11 items)
    ├─ Group by venue → 75 countries
    ├─ Split into popularCountryLeagues (5) + otherCountryLeagues (70)
    └─ Call refresh methods
        ↓
refreshLeaguesFilterData() ✅ NOW WORKS
refreshCountryLeaguesFilterData() ✅ NOW WORKS
    ↓
UI Updates → Filters Populated
```

## Test Results

**Before Fix:**
```
[FILTERS_DEBUG] Received 10 popular competitions, 269 sport competitions
[FILTERS_DEBUG] Final Results:
[FILTERS_DEBUG]   - popularLeagues: 11
[FILTERS_DEBUG]   - popularCountryLeagues: 5
[FILTERS_DEBUG]   - otherCountryLeagues: 70
[FILTERS_DEBUG]   - ERROR: leaguesFilter ViewModel not found or wrong type
[FILTERS_DEBUG]   - ERROR: popularCountryLeaguesFilter ViewModel not found or wrong type
[FILTERS_DEBUG]   - ERROR: otherCountryLeaguesFilter ViewModel not found or wrong type
```
**Result:** Empty UI sections (data fetched but never reached views)

**After Fix:**
```
[FILTERS_DEBUG] Received 10 popular competitions, 269 sport competitions
[FILTERS_DEBUG] Final Results:
[FILTERS_DEBUG]   - popularLeagues: 11
[FILTERS_DEBUG]   - popularCountryLeagues: 5
[FILTERS_DEBUG]   - otherCountryLeagues: 70
[FILTERS_DEBUG]   - Found leaguesFilter ViewModel, updating with 11 options
[FILTERS_DEBUG]   - Found popularCountryLeaguesFilter ViewModel, updating with 5 countries
[FILTERS_DEBUG]   - Found otherCountryLeaguesFilter ViewModel, updating with 70 countries
```
**Result:** ✅ All filter sections populated correctly

## Next Steps
1. ~~Test filters in simulator to verify leagues/countries populate correctly~~ (Done - works!)
2. Monitor for any edge cases where data might be empty (e.g., sports with no competitions)
3. Consider removing debug logs once confirmed stable in production
4. Schedule refactor to replace `dynamicViewModels: [String: Any]` with strongly-typed properties (see TODO_TASKS.md)
5. Apply same pattern to InPlayEventsFilters if they use similar architecture
