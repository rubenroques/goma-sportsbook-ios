# Events Filtering System Analysis Report
## Betsson Cameroon App - In-Play and Next-Up Events

**Generated:** September 4, 2025  
**Scope:** Complete analysis of filtering functionality for in-play and next-up events screens  
**Project:** BetssonCameroonApp (`sportsbook-ios/BetssonCameroonApp/`)

---

## Executive Summary

This report provides a comprehensive analysis of the events filtering system implemented in the Betsson Cameroon app. The system supports real-time filtering of both in-play (live) and next-up (pre-live) events through a sophisticated architecture involving UI components, view models, service abstractions, and WebSocket-based backend communication.

### Key Findings:
- **Dual Architecture**: Separate but similar implementations for in-play and next-up events
- **Real-time Updates**: WebSocket-based subscriptions with automatic filter application
- **Dynamic Configuration**: Filter interface built from configuration objects
- **Multi-provider Support**: Abstracted through ServicesProvider layer
- **Persistent State**: Filter preferences saved to UserDefaults

---

## System Architecture Overview

### Core Components

```
UI Layer
├── NextUpEventsViewController/InPlayEventsViewController
├── CombinedFiltersViewController (Modal Filter Interface)
└── Individual Filter Views (SportGamesFilterView, TimeSliderView, etc.)

Business Logic Layer
├── NextUpEventsViewModel/InPlayEventsViewModel
├── CombinedFiltersViewModel
└── AppliedEventsFilters (Filter State Model)

Service Layer
├── ServicesProvider.Client
├── MatchesFilterOptions (Service Layer Filter Model)
└── EventsProvider Protocol

Backend Communication
├── EveryMatrixProvider (WAMP WebSocket)
├── PreLiveMatchesPaginator/LiveMatchesPaginator
└── WAMPRouter (Endpoint Definitions)
```

## Filter Models and Data Flow

### Primary Filter Models

#### **AppliedEventsFilters**
**Location:** `BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift:10`

```swift
public struct AppliedEventsFilters: Codable, Equatable {
    var sportId: String           // Selected sport ID
    var timeFilter: TimeFilter    // Time range filter
    var sortType: SortType        // Sort preference
    var leagueId: String          // League/tournament selection
}
```

**Supported Values:**
- **TimeFilter:** `.all`, `.oneHour`, `.eightHours`, `.today`, `.fortyEightHours`
- **SortType:** `.popular`, `.upcoming`, `.favorites`
- **SportId:** String representation of sport (e.g., "1" for Football)
- **LeagueId:** `"all"`, specific league ID, or `"{countryId}_all"` format

#### **MatchesFilterOptions** 
**Location:** `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/MatchesFilterOptions.swift:157`

Service layer model that converts UI filters to backend-compatible format:

```swift
public struct MatchesFilterOptions: Equatable {
    public let sportId: String
    public let timeRange: TimeRange
    public let sortBy: SortBy 
    public let location: LocationFilter
    public let tournament: TournamentFilter
    public let optionalUserId: String?
}
```

### Filter Conversion Logic

**Conversion Process** (`AppliedEventsFilters+MatchesFilterOptions.swift:13`):

| UI Filter | Backend Parameter | Example Values |
|-----------|------------------|----------------|
| `timeFilter.rawValue` | `timeRange.serverRawValue` | `"all"`, `"0-1"`, `"0-8"`, `"0-24"`, `"0-48"` |
| `sortType.rawValue` | `sortBy.serverRawValue` | `"POPULAR"`, `"UPCOMING"`, `"FAVORITES"` |
| `sportId` | `sportId` | `"1"`, `"2"`, `"3"` |
| `leagueId` | `tournament`/`location` | Complex mapping (see below) |

**League ID Mapping Logic:**
```swift
if leagueId.hasSuffix("_all") {
    // Country-specific: "{countryId}_all" → location: .specific(countryId), tournament: .all
    let countryId = String(leagueId.dropLast(4))
    location = .specific(countryId)
    tournament = .all
} else if leagueId == "all" || leagueId == "0" || leagueId.isEmpty {
    // No filters: location: .all, tournament: .all
    location = .all
    tournament = .all  
} else {
    // Specific league: location: .all, tournament: .specific(leagueId)
    location = .all
    tournament = .specific(leagueId)
}
```

## Endpoints and Backend Communication

### WebSocket Subscription Endpoints

The system uses **WAMP (WebSocket Application Messaging Protocol)** for real-time event subscriptions.

#### **Next-Up Events (Pre-Live)**

**With Filters Applied:**
```
/sports/4093/en/custom-matches-aggregator/{sportId}/{locationId}/{tournamentId}/{hoursInterval}/{sortEventsBy}/NOT_LIVE/{eventLimit}/{mainMarketsLimit}[/{userId}]
```

**Without Filters (Fallback):**
```
/sports/4093/en/popular-matches-aggregator-main/{sportId}/{matchesCount}/5
```

**Implementation:** `PreLiveMatchesPaginator.swift:79`

#### **In-Play Events (Live)**

**With Filters Applied:**
```
/sports/4093/en/custom-matches-aggregator/{sportId}/{locationId}/{tournamentId}/{hoursInterval}/{sortEventsBy}/LIVE/{eventLimit}/{mainMarketsLimit}[/{userId}]
```

**Without Filters (Fallback):**
```
/sports/4093/en/live-matches-aggregator-main/{sportId}/{matchesCount}/5
```

**Implementation:** `LiveMatchesPaginator.swift:72`

### RPC Call Endpoints

#### **Tournament/League Data**

**Popular Tournaments:**
- **Endpoint:** `/sports#popularTournaments`
- **Parameters:** `lang`, `sportId`, `liveStatus`, `sortByPopularity`, `maxResults`
- **Usage:** Loads top leagues for filter modal

**All Tournaments:**  
- **Endpoint:** `/sports#tournaments`
- **Parameters:** `lang`, `sportId`, `liveStatus`, `sortByPopularity`
- **Usage:** Loads complete tournament hierarchy for filter modal

**Implementation:** `CombinedFiltersViewModel.swift:73` and `CombinedFiltersViewModel.swift:82`

### Example Endpoint Calls

**Next-Up Events with Time + Sort Filters:**
```
/sports/4093/en/custom-matches-aggregator/1/all/all/0-24/POPULAR/NOT_LIVE/10/5
```
- Sport: Football (1)
- Location: All countries  
- Tournament: All leagues
- Time: Today (0-24 hours)
- Sort: Popular
- Status: Pre-live only
- Event Limit: 10
- Markets Limit: 5

**In-Play Events with League Filter:**
```
/sports/4093/en/custom-matches-aggregator/1/all/12345/all/UPCOMING/LIVE/10/5/user123
```
- Sport: Football (1)
- Location: All countries
- Tournament: Specific league (12345)
- Time: All times
- Sort: Upcoming
- Status: Live only
- Event Limit: 10  
- Markets Limit: 5
- User ID: user123

## Filter Application Logic and Timing

### Filter Trigger Events

#### **1. Initial Screen Load**
**Next-Up Events:**
```swift
// NextUpEventsViewModel.swift:99
init(sport: Sport, servicesProvider: ServicesProvider.Client, appliedFilters: AppliedEventsFilters = AppliedEventsFilters.defaultFilters)
```
- Loads with default filters: `sport: "1", time: .all, sort: .popular, league: "all"`
- Immediately calls `loadEvents()` → `subscribeToFilteredPreLiveMatches()`

**In-Play Events:**  
```swift
// InPlayEventsViewModel.swift:98
init(sport: Sport, servicesProvider: ServicesProvider.Client)
```
- Initializes filters based on provided sport
- Immediately calls `loadEvents()` → `subscribeToFilteredLiveMatches()`

#### **2. Sport Selection Changes**
**Implementation:** `updateSportType()` in both ViewModels

**Process:**
1. Cancel existing WebSocket subscription
2. Clear all current match data  
3. Update `appliedFilters.sportId`
4. Update UI components (pill selector)
5. Trigger `reloadEvents(forced: true)`

**Code Reference:** `NextUpEventsViewModel.swift:116`, `InPlayEventsViewModel.swift:116`

#### **3. Filter Modal Interactions**  
**Modal Workflow:** `CombinedFiltersViewController.swift:136`

**States:**
- `initialFilters`: Filters when modal opened
- `temporaryFilters`: Current selections (not yet applied)  
- `viewModel.appliedFilters`: Currently active filters

**User Actions:**
- **Apply:** `applyButtonTapped()` → Save to UserDefaults → `onApply?(temporaryFilters)` → Modal closes
- **Reset:** `resetButtonTapped()` → Reset to `AppliedEventsFilters.defaultFilters` → Update UI only
- **Close:** `closeButtonTapped()` → Restore `initialFilters` → Modal closes

#### **4. Direct Filter Updates**
**Implementation:** `updateFilters()` in both ViewModels

**Process:**
1. Check if filters actually changed (`guard appliedFilters != filters`)
2. Cancel existing subscription
3. Clear all state (matches, market groups, view models)  
4. Update internal `appliedFilters`
5. Update sport if changed
6. Trigger `reloadEvents(forced: true)`

**Code Reference:** `NextUpEventsViewModel.swift:136`, `InPlayEventsViewModel.swift:156`

### Real-time Subscription Management

#### **Subscription Lifecycle**
```swift
// Example from NextUpEventsViewModel.swift:231
preLiveMatchesCancellable = servicesProvider.subscribeToFilteredPreLiveMatches(filters: filterOptions)
    .receive(on: DispatchQueue.main)
    .sink { completion in
        print("subscribeToFilteredPreLiveMatches \(completion)")
    } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
        switch subscribableContent {
        case .connected(let subscription):
            // WebSocket connection established
        case .contentUpdate(let content):
            // New event data received
            let matches = ServiceProviderModelMapper.matches(fromEventsGroups: content)
            self?.processMatches(matches, mainMarkets: mainMarkets)
        case .disconnected:
            // WebSocket disconnected
        }
    }
```

#### **Filter Change Impact**
Every filter modification triggers:
1. **Immediate subscription cancellation** - `preLiveMatchesCancellable?.cancel()`
2. **State clearing** - All matches, market groups, and UI state reset
3. **New subscription creation** - With updated filter parameters
4. **Loading state** - UI shows loading indicator until new data arrives

## Filter Modal Architecture

### Dynamic Configuration System

**Filter Configuration** (`Filters.swift:10`):
```swift
public struct FilterConfiguration: Codable {
    let widgets: [FilterWidget]           // Available filter components
    let filtersByContext: [FilterContext] // Context-specific widget arrangements
}
```

**Widget Types:**
- `sportsFilter` → `SportGamesFilterView` (Grid of sport options)
- `timeFilter` → `TimeSliderView` (Slider with time ranges)  
- `radioFilterBasic` → `SortFilterView` (Radio button list)
- `radioFilterAccordion` → `CountryLeaguesFilterView` (Expandable country/league hierarchy)

### Filter Modal Components

#### **Sports Filter**
- **View:** `SportGamesFilterView` (from GomaUI)
- **Data:** Active sports from `Env.sportsStore.getActiveSports()`
- **Behavior:** Single selection, triggers league data refresh

#### **Time Filter**  
- **View:** `TimeSliderView` (from GomaUI)
- **Options:** All, 1h, 8h, Today, 48h
- **Behavior:** Slider interface with discrete time ranges

#### **Sort Filter**
- **View:** `SortFilterView` (from GomaUI)  
- **Options:** Popular, Upcoming, Favourites
- **Behavior:** Radio button selection

#### **League Filters** (3 separate sections)
- **Popular Leagues:** Top tournaments for current sport
- **Popular Countries:** Countries with popular tournaments (expandable)
- **Other Countries:** Remaining countries with tournaments (expandable)
- **Behavior:** Cross-synchronized selection (selecting in one updates others)

### Filter Data Loading

#### **Tournament Data Fetching** (`CombinedFiltersViewModel.swift:51`)
```swift
func getAllLeagues(sportId: String? = nil) {
    // Parallel RPC calls
    let sportTournamentsPublisher = servicesProvider.getTournaments(forSportType: sportType)
    let popularTournamentsPublisher = servicesProvider.getPopularTournaments(forSportType: sportType, tournamentsCount: 10)
    
    Publishers.Zip(sportTournamentsPublisher, popularTournamentsPublisher)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] sportCompetitions, popularCompetitions in
            self?.setupAllLeagues(popularCompetitions: popularCompetitions, sportCompetitions: sportCompetitions)
        }
}
```

**Data Processing:**
1. **Popular Leagues:** Direct mapping from `popularCompetitions`
2. **Country Grouping:** Group `sportCompetitions` by venue/country
3. **Hierarchy Building:** Create expandable country → leagues structure
4. **Count Calculation:** Event counts per league (live vs pre-live)

## State Management and Persistence

### UserDefaults Storage
```swift
// CombinedFiltersViewController.swift:373
UserDefaults.standard.set(codable: temporaryFilters, forKey: "AppliedEventsFilters")
```

**Storage Details:**
- **Key:** `"AppliedEventsFilters"`
- **Format:** JSON via `Codable` protocol
- **Scope:** App-wide filter preferences
- **Persistence:** Survives app restarts

### Cross-Component Synchronization

#### **League Selection Synchronization**
**Implementation:** `synchronizeLeagueSelection()` (`CombinedFiltersViewController.swift:642`)

When user selects a league in any filter section:
1. Update `temporaryFilters.leagueId`
2. Synchronize selection across all league filter views:
   - Popular Leagues filter
   - Popular Countries filter  
   - Other Countries filter
3. Update button states (Apply/Reset availability)

#### **Filter State Validation**
```swift
// CombinedFiltersViewController.swift:290
private func updateButtonStates() {
    // Apply button: enabled only if filters changed from initial and not loading
    let hasChanges = temporaryFilters != initialFilters
    applyButton.isEnabled = hasChanges && !isLoading
    
    // Reset button: enabled only if not at defaults  
    let isAtDefaults = temporaryFilters == AppliedEventsFilters.defaultFilters
    resetButton.isEnabled = !isAtDefaults
}
```

## Error Handling and Edge Cases

### Subscription Error Handling
```swift
// Both ViewModels handle subscription errors
.sink { completion in
    switch completion {
    case .finished:
        print("Subscription completed successfully")
    case .failure(let error):
        print("Subscription failed: \(error)")
        // Could trigger retry logic or fallback behavior
    }
}
```

### Tournament Loading Errors
```swift
// CombinedFiltersViewModel.swift:77
.catch { error -> AnyPublisher<[Competition], Never> in
    print("Sport tournaments failed: \(error)")
    return Just([]).eraseToAnyPublisher() // Return empty array on error
}
```

### Filter Compatibility
- **Backward Compatibility:** `AppliedEventsFilters` uses custom `Codable` implementation to handle old key names
- **Default Fallbacks:** All filter enums provide default values for invalid data
- **Validation:** Filter models validate enum values during decoding

## Performance Considerations

### Subscription Management
- **Single Active Subscription:** Only one WebSocket subscription per screen at a time
- **Immediate Cleanup:** Previous subscriptions cancelled before creating new ones
- **Memory Management:** Weak references used throughout to prevent retain cycles

### Data Processing
- **Background Processing:** Tournament data processed on background queues where possible
- **Incremental Updates:** WebSocket provides incremental updates rather than full reloads
- **UI Throttling:** Main thread updates batched through Combine publishers

### Caching Strategy
- **In-Memory Storage:** Tournament data cached in ViewModels during modal session
- **Persistent Filters:** Last applied filters cached in UserDefaults
- **Sports Data:** Sports list cached globally in `Env.sportsStore`

## Integration Points

### ServicesProvider Architecture
The filtering system integrates with the broader ServicesProvider architecture:

- **Provider Abstraction:** `EventsProvider` protocol supports multiple backends (EveryMatrix, SportRadar, Goma)
- **Current Implementation:** EveryMatrix provider via WAMP WebSocket
- **Alternative Providers:** Goma and SportRadar providers available for different clients

### GomaUI Components
Filter modal built entirely with GomaUI components:

- **SportGamesFilterView:** Sport selection grid
- **TimeSliderView:** Time range slider
- **SortFilterView:** Radio button groups
- **CountryLeaguesFilterView:** Expandable tournament hierarchy

## Recommendations

### Potential Improvements

1. **Error Recovery:** Add automatic retry logic for failed subscriptions
2. **Offline Support:** Cache filter options for offline browsing
3. **Performance:** Implement filter debouncing for rapid changes
4. **UX Enhancement:** Add filter preview (match count) before applying
5. **Analytics:** Track filter usage patterns for optimization

### Code Quality
- **Test Coverage:** Add unit tests for filter conversion logic
- **Documentation:** Expand inline documentation for complex filter mappings
- **Type Safety:** Consider using enums instead of String IDs where possible

---

## Conclusion

The Betsson Cameroon app implements a sophisticated, real-time filtering system that effectively handles complex user requirements while maintaining excellent performance and user experience. The architecture successfully separates concerns between UI, business logic, and backend communication, making it maintainable and extensible for future enhancements.

The dual implementation for in-play and next-up events provides consistent behavior while accommodating the different requirements of live vs pre-live event filtering. The dynamic configuration system allows for flexible filter interfaces, and the WebSocket-based real-time updates ensure users always see current data.

**Key Strengths:**
- Real-time filter application via WebSocket subscriptions  
- Persistent filter state across app sessions
- Dynamic, configuration-driven filter interface
- Comprehensive error handling and fallback mechanisms
- Clean separation between UI models and service layer models

The system is well-architected for the current requirements and positioned for future enhancements as the product evolves.