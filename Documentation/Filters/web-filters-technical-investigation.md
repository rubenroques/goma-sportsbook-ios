# Filters Technical Investigation Report

## 1. Overview
The filter system operates on two main pages:
- **Upcoming Events**: `/en/sports`
- **Live Events**: `/en/sports/live`

Both pages share the same filter infrastructure with different data subscriptions.

## 2. Data Flow Architecture

### 2.1 Filter State Flow
```
User Interaction → Filter Selection → State Update → URL Update → API Call → Store Update → UI Render
```

### 2.2 Core State Management
**Location**: `src/composables/filters/sports/useFilters.js`

```javascript
// Active filter selections (reactive refs)
currentSelectedSportId    // e.g., '1' for football
currentSelectedTimeRange   // 'all', '1h', '8h', 'today', '48h'
currentSelectedSortBy      // 'popular', 'favourites', 'time'
currentSelectedLeague      // 'regionId|competitionId' format
currentSelectedCountryLeague // 'regionId|competitionId' format
```

## 3. Network Requests

### 3.1 Competition Data Loading
Triggered when sport selection changes:

**Request 1: Get Popular Leagues**
```javascript
// API: oddsApi.betting.getTopCompetitions()
// Endpoint: GET /api/betting/top-competitions
{
  sportId: '1',
  numberOfCompetitions: 10
}
// Response stored in: bettingStore.topCompetitions
```

**Request 2: Get All Competitions**
```javascript
// API: oddsApi.betting.getCompetitions()
// Endpoint: GET /api/betting/competitions
{
  sportId: '1'
}
// Response stored in: bettingStore.competitions
```

### 3.2 Event Subscription Requests

**Upcoming Events Subscription**
```javascript
// API: subscribeToPreLiveEvents()
// WebSocket subscription with parameters:
{
  sportId: '1',
  hoursInterval: '0-24',     // Derived from time_range
  topCompetitionIds: [101, 102, ...],
  sortBy: 'popular',
  regionId: 'all',           // Or specific region ID
  competitionId: 'all'       // Or specific competition ID
}
```

**Live Events Subscription**
```javascript
// API: subscribeToLiveEvents()
// Same structure as PreLiveEvents but for live matches
```

### 3.3 Time Range Mapping
```javascript
// UI Value → API Parameter
'all'   → 'all'
'1h'    → '0-1'
'8h'    → '0-8'
'today' → '0-24'
'48h'   → '0-48'
```

## 4. Data Models

### 4.1 Sport Model
```javascript
{
  id: '1',
  name: 'Football',
  order: 1,
  numberOfEvents: 150,
  numberOfLiveEvents: 12
}
```

### 4.2 Competition Model
```javascript
{
  id: '101',
  venueId: '10',              // Country/Region ID
  venueName: 'England',
  name: 'Premier League',
  translatedName: 'Premier League',
  numberOfEvents: 38,
  numberOfLiveEvents: 2
}
```

### 4.3 Filter Query Parameters
```javascript
// URL: /en/sports?sport_id=1&time_range=today&sort_by=popular&region_id=10&competition_id=101
{
  sport_id: '1',
  time_range: 'today',
  sort_by: 'popular',
  region_id: '10',        // Country ID
  competition_id: '101'   // League ID
}
```

### 4.4 Composite ID Format
Leagues and country selections use composite IDs:
```javascript
// Format: "regionId|competitionId"
'all|all'     // All regions, all competitions
'10|all'      // England, all competitions
'10|101'      // England, Premier League
```

## 5. Business Logic

### 5.1 Filter Application Flow

```javascript
// When user clicks "Apply" button
async function applyFilters() {
  // 1. Build query parameters from current selections
  const newQuery = {
    sport_id: currentSelectedSportId.value,
    time_range: currentSelectedTimeRange.value,
    sort_by: currentSelectedSortBy.value,
    region_id: parseCompositeId(selectedLeague)[0],
    competition_id: parseCompositeId(selectedLeague)[1]
  }
  
  // 2. Priority logic: CountryLeague overrides League
  if (selectedCountryLeague !== 'all|all') {
    // Use country/league selection
    [newQuery.region_id, newQuery.competition_id] = parseCompositeId(selectedCountryLeague)
  }
  
  // 3. Navigate with new parameters
  await router.push({ query: newQuery })
  
  // 4. Route change triggers subscription update
}
```

### 5.2 Sport Change Behavior
```javascript
function handleSportChange(newSportId) {
  // 1. Update sport selection
  currentSelectedSportId.value = newSportId
  
  // 2. Reset league selections
  currentSelectedLeague.value = 'all|all'
  currentSelectedCountryLeague.value = 'all|all'
  
  // 3. Load competitions for new sport
  loadCompetitionsData({ sportId: newSportId })
  
  // 4. Collapse any expanded accordions
  filterUI.collapseAllOptions('countryLeagues')
}
```

### 5.3 Dialog State Management
```javascript
// On dialog open
captureInitialDialogState() // Save current filter state

// On close without apply
if (hasFiltersChanged()) {
  resetFiltersToInitialState() // Revert changes
  if (sportChanged) {
    // Reload original sport's competitions
    loadCompetitionsData({ sportId: initialSportId })
  }
}

// On reset button
resetFiltersToDefaults() // Set all filters to defaults
```

### 5.4 Validation Rules

1. **Authentication-based validation**:
```javascript
// 'favourites' sort only available when logged in
if (sortBy === 'favourites' && !userLoggedIn) {
  sortBy = 'popular' // Fallback to default
}
```

2. **Competition validation**:
```javascript
// Validate selected competition exists for current sport
if (!competitions.find(c => c.id === selectedCompetitionId)) {
  selectedCompetitionId = 'all'
}
```

3. **Priority resolution**:
```javascript
// CountryLeague selection takes priority over League
if (countryLeagueSelected && leagueSelected) {
  league = 'all|all' // Reset league to default
}
```

## 6. Component Interaction Flow

### 6.1 User Opens Filter Dialog
```
FilterBar @click → openFiltersDialog() → FiltersDialog opens
                                       → captureInitialDialogState()
                                       → Load dynamic components
```

### 6.2 User Changes Sport
```
Sport selection → selectSport(id) → loadCompetitionsData(id)
                                  → Reset league selections
                                  → API calls (parallel):
                                    - getTopCompetitions()
                                    - getCompetitions()
                                  → Update store
```

### 6.3 User Applies Filters
```
Apply button → applyFilters() → Build query params
                              → router.push(query)
                              → Route change detected
                              → Trigger subscription:
                                - unsubscribe current
                                - subscribe with new params
                              → Update events in store
                              → Close dialog
```

## 7. Store Updates

### 7.1 Betting Store Structure
```javascript
// src/stores/betting.js
{
  sports: [],              // All available sports
  topCompetitions: [],     // Popular leagues for selected sport
  competitions: [],        // All competitions for selected sport
  events: [],             // Filtered events
  markets: {},            // Market data for events
  outcomes: {}            // Outcome data for markets
}
```

### 7.2 Data Update Flow
```
API Response → Store Patch → Computed Properties → UI Update
```

## 8. URL Persistence

Filters persist in URL query parameters, enabling:
- Direct linking to filtered views
- Browser back/forward navigation
- Bookmark specific filter combinations

Example URL:
```
/en/sports?sport_id=1&time_range=today&sort_by=popular&region_id=10&competition_id=101
```

## 9. Key Differences: Upcoming vs Live

| Aspect | Upcoming Events | Live Events |
|--------|-----------------|-------------|
| **Subscription** | `subscribeToPreLiveEvents()` | `subscribeToLiveEvents()` |
| **Event Counter** | `numberOfEvents` | `numberOfLiveEvents` |
| **Time Context** | Future matches | Current matches |
| **Default Time** | 'all' (all future) | 'all' (all live) |

## 10. Critical Implementation Details

### 10.1 Subscription Management
- Previous subscriptions cleaned up before new ones
- Prevents memory leaks and duplicate data
- Managed by `useSubscriptionManager` composable

### 10.2 Loading States
```javascript
loaderStore.isDataLoading = {
  sports: true,          // Loading sports list
  topCompetitions: true, // Loading popular leagues
  competitions: true,    // Loading all competitions
  events: true          // Loading filtered events
}
```

### 10.3 Error Handling
- Invalid selections revert to defaults
- Missing query params auto-populate
- API failures maintain previous state

### 10.4 Performance Optimizations
- Parallel API calls for competitions
- Dynamic component loading
- Debounced route updates
- Cached component instances