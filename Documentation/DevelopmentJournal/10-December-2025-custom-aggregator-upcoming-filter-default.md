## Date
10 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Change custom aggregator default filter from "Popular with All time" to "Upcoming with 24h"
- Update tooltip display to show "Upcoming" instead of "Popular"
- Both NextUpEvents (pre-live) and InPlayEvents (live) screens affected

### Achievements
- [x] Changed `MatchesFilterOptions.swift` defaults from `.all`/`.popular` to `.today`/`.upcoming`
- [x] Changed `AppliedEventsFilters.swift` `defaultFilters` to use `.today` and `.upcoming`
- [x] Updated `PillSelectorBarViewModel.swift` tooltip pill from "Popular" (flame icon) to "Upcoming" (timelapse icon)
- [x] Verified translations already exist: EN="Upcoming", FR="À venir"

### Files Modified
1. `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/MatchesFilterOptions.swift`
   - `init` default params: `timeRange: .today`, `sortBy: .upcoming`
   - `noFilters` static method: same changes

2. `BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift`
   - `defaultFilters`: `timeFilter: .today`, `sortType: .upcoming`

3. `BetssonCameroonApp/App/ViewModels/PillSelectorBarViewModel.swift`
   - Pill id: `"popular"` → `"upcoming"`
   - Pill title: `localized("popular")` → `localized("upcoming")`
   - Pill icon: `"flame_bar_icon"` → `"timelapse_icon"`

### Data Flow Summary
```
PillSelectorBarViewModel (UI tooltip)
        ↓
AppliedEventsFilters.defaultFilters (app-level defaults)
        ↓
AppliedEventsFilters+MatchesFilterOptions.toMatchesFilterOptions() (conversion)
        ↓
MatchesFilterOptions (ServicesProvider layer)
        ↓
PreLiveMatchesPaginator / LiveMatchesPaginator (WAMP subscription)
        ↓
WAMPRouter.customMatchesAggregatorPublisher (WebSocket topic)
        ↓
Server receives: hoursInterval="0-24", sortEventsBy="UPCOMING"
```

### Key Decisions
- **Keep "All Popular Leagues" pill unchanged** - Client only wanted the filter pill updated
- **Use existing `timelapse_icon`** - Already in use for filters, consistent with Upcoming concept
- **No translation changes needed** - Both EN and FR already have "upcoming" key

### Verification
After changes, WAMP topic parameters:
- `hoursInterval: "0-24"` (was "all")
- `sortEventsBy: "UPCOMING"` (was "POPULAR")
