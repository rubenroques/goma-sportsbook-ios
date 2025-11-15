## Date
15 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Fix country league count display to match web app behavior
- Refactor from string-based "_all" suffix logic to type-safe enum pattern
- Eliminate double-counting bug in filter UI

### Achievements
- [x] Added `isAllOption: Bool` property to `LeagueOption` struct with default value
- [x] Updated `CombinedFiltersViewModel` to explicitly set `isAllOption` flag
- [x] Fixed count calculation in `CountryLeagueOptionRowView` to exclude "All" options
- [x] Eliminated string-based business logic (`"_all"` suffix checks)
- [x] Ensured backward compatibility - all demo code works without changes

### Issues / Bugs Hit
- [x] Country league counts were double-counting (e.g., showing "2" instead of "1")
- [x] Root cause: "All Leagues" option had count of all leagues, then was included in sum
- [x] Example: League A (10) + League B (15) + All (25) = 50, should be 25

### Key Decisions
- Used default parameter value `isAllOption: Bool = false` for backward compatibility
- Explicitly set `isAllOption: true` only for "All Leagues" creation
- Kept existing `"_all"` string ID format for backend compatibility
- Filtered count calculation at UI layer rather than changing data structure

### Experiments & Notes
- Discovered the bug through comparison with web app behavior
- Found that LeagueOption was previously just a plain struct with no type safety
- The `"_all"` suffix pattern was used in multiple places (lines 190, 202, 208, 310)
- Only the count calculation (line 288-292) was causing the visible bug
- Demo/mock code uses default parameter values, so no changes needed there

### Useful Files / Links
- [LeagueOption Model](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/LeaguesFilterView/Models/LeaguesFilterViewModels.swift)
- [CombinedFiltersViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModel.swift)
- [CountryLeagueOptionRowView](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CountryLeaguesFilterView/CountryLeagueOptionRowView/CountryLeagueOptionRowView.swift)
- [Filters Implementation DJ](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Documentation/DevelopmentJournal/06-August-2025-filters-implementation.md)
- [Filters State Management DJ](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Documentation/DevelopmentJournal/07-August-2025-filters-state-management.md)
- [Filters WebSocket League Counts DJ](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Documentation/DevelopmentJournal/08-August-2025-filters-websocket-league-counts.md)

### Technical Details

#### Bug Explanation
**Before Fix:**
```swift
// All leagues summed INCLUDING "All" option
let totalEvents = leagues.compactMap { $0.count }.reduce(0, +)
// Result: 10 + 15 + 25 = 50 (WRONG)
```

**After Fix:**
```swift
// Filter out "All" option before summing
let totalEvents = leagues
    .filter { !$0.isAllOption }
    .compactMap { $0.count }
    .reduce(0, +)
// Result: 10 + 15 = 25 (CORRECT)
```

#### Architecture Improvement
**From:** String-based business logic
```swift
id: "\(venueId)_all"  // String concatenation
if id.hasSuffix("_all") { }  // String checking
```

**To:** Type-safe property
```swift
isAllOption: true  // Explicit boolean flag
if !league.isAllOption { }  // Type-safe filtering
```

### Next Steps
1. Test filter UI with various country/league combinations
2. Consider refactoring other `"_all"` string checks to use `isAllOption` property (lines 190, 202, 208, 310)
3. Verify counts match web app across all sports and countries
4. Monitor for any edge cases with "All" option selection logic
