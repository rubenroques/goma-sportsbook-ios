# Filters Architecture Report

## Executive Summary

The BetssonCameroonApp implements a sophisticated filtering system for sports events that leverages the EveryMatrix provider's tournament APIs. The architecture follows a modular MVVM pattern with dynamic filter configuration, enabling flexible filtering across sports, time ranges, tournaments, and countries.

## Core Architecture

### Filter System Components

The filter system consists of three main layers:

1. **Data Layer**: ServicesProvider framework with EveryMatrix tournament APIs
2. **Presentation Layer**: CombinedFiltersViewController with dynamic filter views
3. **Business Logic Layer**: CombinedFiltersViewModel managing filter state and data fetching

## Essential Files to Read

### 1. EveryMatrix Provider Implementation
**File**: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift`
- Lines 353-484: Tournament subscription and RPC methods
- Lines 389-401: `getPopularTournaments()` implementation
- Lines 404-416: `getTournaments()` implementation
- Lines 419-483: Tournament processing logic

### 2. Filter View Controller
**File**: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewController.swift`
- Lines 131-145: Initialization with filter configuration
- Lines 449-503: Dynamic filter view creation
- Lines 511-591: Filter callback setup and synchronization

### 3. Filter View Model
**File**: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModel.swift`
- Lines 48-97: `getAllLeagues()` - Fetches tournaments from EveryMatrix
- Lines 99-178: `setupAllLeagues()` - Processes and organizes tournament data
- Lines 595-741: Dynamic view model creation for filter widgets

### 4. Filter Models
**File**: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift`
- Contains the `AppliedEventsFilters` model structure

### 5. Filter Protocol
**File**: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModelProtocol.swift`
- Defines the protocol interface for filter view models

### 6. WAMP Router
**File**: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/WAMPClient/WAMPRouter.swift`
- Lines 22-23: Tournament RPC route definitions
- Lines 117-120: Tournament endpoint paths
- Lines 257-262: Tournament request parameters

### 7. Tournament Mapper
**File**: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+Tournaments.swift`
- Lines 12-42: Tournament DTO to domain model mapping

### 8. ServicesProvider Client
**File**: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`
- Lines 427-443: Public API for tournament fetching

### 9. Events Provider Protocol
**File**: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/EventsProvider.swift`
- Lines 64-66: Tournament method protocol definitions

## Tournament API Methods

### 1. Get Popular Tournaments (RPC)
```swift
func getPopularTournaments(forSportType: SportType, tournamentsCount: Int) -> AnyPublisher<[Tournament], ServiceProviderError>
```
- **Purpose**: Fetches the most popular tournaments for a sport
- **Location**: `EveryMatrixProvider.swift:389`
- **WAMP Route**: `/sports#popularTournaments`
- **Parameters**:
  - `sportType`: The sport to filter by
  - `tournamentsCount`: Number of tournaments to return (default: 10)

### 2. Get All Tournaments (RPC)
```swift
func getTournaments(forSportType: SportType) -> AnyPublisher<[Tournament], ServiceProviderError>
```
- **Purpose**: Fetches all available tournaments for a sport
- **Location**: `EveryMatrixProvider.swift:404`
- **WAMP Route**: `/sports#tournaments`
- **Parameters**:
  - `sportType`: The sport to filter by

### 3. Subscribe Popular Tournaments (Real-time)
```swift
func subscribePopularTournaments(forSportType: SportType, tournamentsCount: Int) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError>
```
- **Purpose**: Real-time subscription to popular tournament updates
- **Location**: `EveryMatrixProvider.swift:353`
- **Manager**: `PopularTournamentsManager`

### 4. Subscribe Sport Tournaments (Real-time)
```swift
func subscribeSportTournaments(forSportType: SportType) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError>
```
- **Purpose**: Real-time subscription to all tournament updates
- **Location**: `EveryMatrixProvider.swift:370`
- **Manager**: `SportTournamentsManager`

## Filter Configuration Structure

### Filter Widget Types

1. **Sports Filter** (`sportsFilter`)
   - Type: `.sportsFilter`
   - View: `SportGamesFilterView`
   - ViewModel: `SportGamesFilterViewModelProtocol`

2. **Time Filter** (`timeFilter`)
   - Type: `.timeFilter`
   - View: `TimeSliderView`
   - ViewModel: `TimeSliderViewModelProtocol`
   - Options: All, 1h, 8h, Today, 48h

3. **Sort By Filter** (`sortByFilter`)
   - Type: `.radioFilterBasic`
   - View: `SortFilterView`
   - Options: Popular, Upcoming, Favourites

4. **Leagues Filter** (`leaguesFilter`)
   - Type: `.radioFilterBasic`
   - View: `SortFilterView`
   - Data: Popular tournaments from EveryMatrix

5. **Popular Countries Filter** (`popularCountryLeaguesFilter`)
   - Type: `.radioFilterAccordion`
   - View: `CountryLeaguesFilterView`
   - Data: Tournaments grouped by popular countries

6. **Other Countries Filter** (`otherCountryLeaguesFilter`)
   - Type: `.radioFilterAccordion`
   - View: `CountryLeaguesFilterView`
   - Data: Tournaments grouped by non-popular countries

## Data Flow

### 1. Tournament Data Fetching

```
User Selects Sport → getAllLeagues(sportId)
                    ↓
    ┌───────────────────────────────────┐
    │  Parallel Tournament Fetching      │
    ├───────────────────────────────────┤
    │  • getTournaments()               │
    │  • getPopularTournaments()        │
    └───────────────────────────────────┘
                    ↓
    Publishers.Zip combines results
                    ↓
    setupAllLeagues() processes data
                    ↓
    ┌───────────────────────────────────┐
    │  Tournament Organization          │
    ├───────────────────────────────────┤
    │  • Popular Leagues List          │
    │  • Popular Country Groups        │
    │  • Other Country Groups          │
    └───────────────────────────────────┘
                    ↓
    Update Filter UI Components
```

### 2. Filter Synchronization

When a league is selected in any filter widget:

1. **Direct Selection** → `synchronizeLeagueSelection()`
2. **Updates All Related Widgets**:
   - Leagues Filter
   - Popular Countries Filter
   - Other Countries Filter
3. **Updates Applied Filters Model**

## Tournament Processing Logic

### Processing Steps (EveryMatrixProvider)

1. **Receive AggregatorResponse** from WAMP call
2. **Store entities** in temporary EntityStore
3. **Build Tournament objects** using TournamentBuilder
4. **Map to domain models** via EveryMatrixModelMapper
5. **Filter tournaments** with events > 0
6. **Return processed tournaments**

### Organization Logic (CombinedFiltersViewModel)

1. **Popular Leagues**:
   - Direct list from `getPopularTournaments()`
   - Includes "All Popular Leagues" option
   - Shows event counts

2. **Country Grouping**:
   - Groups tournaments by venue/country
   - Separates popular vs. other countries
   - Sorts alphabetically
   - Maintains expandable accordion structure

## Key Features

### Dynamic Filter Configuration
- Filters defined via `FilterConfiguration` model
- Context-based filter display (sports vs. casino)
- Runtime view model creation based on configuration

### Real-time Updates
- Support for both RPC (one-time) and subscription (real-time) modes
- Manager-based subscription lifecycle management
- Automatic cleanup on context switch

### Cross-Filter Synchronization
- League selection synchronized across multiple widgets
- Prevents duplicate selections
- Maintains consistent state

## Integration Points

### 1. ServicesProvider Layer
- EveryMatrix connector manages WAMP communication
- EntityStore handles DTO relationships
- Model mappers convert to domain objects

### 2. GomaUI Components
- `SportGamesFilterView` for sport selection
- `TimeSliderView` for time filtering
- `SortFilterView` for radio-based filters
- `CountryLeaguesFilterView` for accordion filters

### 3. Application Layer
- `AppliedEventsFilters` maintains filter state
- Filter callbacks trigger data refresh
- Results applied to event list queries

## Performance Considerations

1. **Parallel Fetching**: Uses `Publishers.Zip` for concurrent API calls
2. **Manager Lifecycle**: Proper cleanup of subscription managers
3. **Lazy Loading**: Filter views created on-demand
4. **Caching**: Tournament data cached during filter session

## Error Handling

- Service provider errors propagated through Combine pipeline
- Loading states managed via `isLoadingPublisher`
- Fallback to empty collections on failure
- User feedback through loading indicators

## Summary

The filter system successfully integrates EveryMatrix tournament APIs with a flexible, modular UI architecture. The implementation provides comprehensive filtering capabilities while maintaining clean separation of concerns and supporting both real-time and on-demand data fetching modes. The use of protocol-driven design and dynamic configuration enables easy extension and customization for different client requirements.