# Development Journal Entry

## Date
15 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Verify cross-platform filter inconsistency reported by Web team's Claude instance
- Fix iOS filter displaying empty leagues (leagues with 0 events)
- Align iOS filter behavior with Web app implementation

### Achievements
- [x] Verified the empty leagues bug exists in iOS CombinedFiltersViewModel
- [x] Implemented three-layer filtering strategy matching Web app:
  - Popular leagues: Filter out leagues with count = 0
  - Individual leagues: Skip empty leagues when building venueDict
  - Empty countries: Remove countries with no remaining leagues
- [x] Fixed SortFilterView collapse icon from UIButton to UIImageView
- [x] Added conditional "All Popular Leagues" option (only shown when totalCount > 0)

### Issues / Bugs Hit
- [x] Swift compiler error: "Generic parameter 'ElementOfResult' could not be inferred" when using `compactMap`
  - **Solution**: Added explicit return type `-> SortOption?` to closure

### Key Decisions
- **Adopted Web app's "filter before render" approach**: Instead of showing all leagues and hiding empty ones in UI, we filter data at ViewModel level before passing to views
- **Three-level filtering cascade**:
  1. Filter individual leagues by event count
  2. Build country groupings with only non-empty leagues
  3. Remove countries that end up with no leagues
- **Changed collapse icon from UIButton to UIImageView**: Prevents icon from intercepting tap events while still displaying state and animating rotation

### Technical Implementation Details

#### CombinedFiltersViewModel.swift Changes

**1. Popular Leagues Filtering (lines 138-164)**
```swift
// Changed from .map to .compactMap with explicit Optional return
let newSortOptions = popularCompetitions.compactMap { competition -> SortOption? in
    let count = isLiveMode ?
        (competition.numberLiveEvents ?? 0) :
        (competition.numberEvents ?? 0)

    // Skip leagues with no events
    guard count > 0 else { return nil }

    return SortOption(...)
}

// Only add "All" option if there are leagues with events
if totalCount > 0 {
    popularLeagues.append(allLeaguesOption)
}
```

**2. Individual Leagues Filtering (lines 188-196)**
```swift
for competition in sportCompetitions {
    let count = isLiveMode ?
        (competition.numberLiveEvents ?? 0) :
        (competition.numberEvents ?? 0)

    // Skip leagues with no events
    guard count > 0 else { continue }

    // ... rest of venueDict building logic
}
```

**3. Empty Countries Filtering (lines 220-222)**
```swift
for (index, (venueId, value)) in venueDict.enumerated() {
    // Skip countries with no leagues (all were filtered out due to 0 events)
    guard !value.leagues.isEmpty else { continue }

    // ... rest of country building logic
}
```

#### SortFilterView.swift Changes

**Collapse Icon Refactor**
```swift
// Before: UIButton that could capture taps
private let collapseButton: UIButton = { ... }()

// After: UIImageView for state display only
private let collapseIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    // ... image setup
    return imageView
}()
```

The tap gesture on `headerView` handles all interaction, while `collapseIcon` only displays the current state.

### Root Cause Analysis

**Why iOS showed empty leagues:**

The iOS implementation used a **categorization-only** strategy:
- Organized leagues into "popular" vs "non-popular" sections
- Never checked event counts before adding leagues
- ALL leagues returned by API were displayed

**Web app's correct approach:**

Used a **data-driven visibility** strategy:
- Filtered arrays before rendering: `.filter(competition => competition.count > 0)`
- Two-step filtering: remove empty leagues first, then remove empty countries
- Only non-empty leagues reach the UI layer

**The Architecture Gap:**

| Platform | Strategy | Result |
|----------|----------|--------|
| Web | Data-driven filtering | Only leagues with events shown |
| iOS (before) | Categorization without filtering | All leagues shown (including empty) |
| iOS (after) | Data-driven filtering + categorization | Matches Web behavior |

### Useful Files / Links
- [CombinedFiltersViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModel.swift) - Main filter logic
- [Competition.swift](../../BetssonCameroonApp/App/Models/Events/Competition.swift) - Model with `numberEvents` and `numberLiveEvents` properties
- [SortFilterView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SortFilterView/SortFilterView.swift) - Collapse icon fix
- [Web App Reference](../CrossPlatform_Filter_Comparison.md) - Cross-platform comparison (created by other Claude instance)

### Cross-Platform Collaboration Note

This fix was initiated by a report from another Claude Code instance working on the Web app. The Web team's Claude:
1. Identified the discrepancy between Web and iOS filter behavior
2. Analyzed both implementations side-by-side
3. Proposed the exact fix needed for iOS
4. Created comprehensive documentation of the issue

This demonstrates effective AI-to-AI collaboration across platform boundaries.

### Testing Recommendations

To verify the fix:
1. Build and run BetssonCameroonApp
2. Navigate to Next Up Events filters
3. Switch between Live and Pre-Live modes
4. Verify behavior:
   - Only leagues with events are displayed
   - Countries with no leagues are completely hidden
   - "All Popular Leagues" option only appears when there are popular leagues with events
   - Collapse icon rotates smoothly without capturing tap events

### Next Steps
1. Test the fix in simulator with various sports (some with empty leagues)
2. Verify the filtering works correctly in both Live and Pre-Live modes
3. Consider adding similar filtering to BetssonFranceApp legacy implementation
4. Monitor for any performance impact with large numbers of competitions
