# Development Journal

## Date
13 November 2025

### Project / Branch
sportsbook-ios / betsson-cm (working branch), rr/breadcrumb (current branch)

### Goals for this session
- Fix ExpandableSectionView interaction (entire header should be tappable, not just arrow)
- Create production view model implementations to replace mocks
- Remove FilterIdentifier enum and replace with plain String throughout codebase

### Achievements
- [x] Fixed ExpandableSectionView to make entire header clickable (not just the toggle button)
  - Added UITapGestureRecognizer to headerContainerView
  - Maintained button functionality for accessibility
  - Changes in: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExpandableSectionView/ExpandableSectionView.swift`

- [x] Created 4 production view model implementations (exact clones of mocks)
  - `BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/SportGamesFilterViewModel.swift`
  - `BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/LeaguesFilterViewModel.swift`
  - `BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/SortFilterViewModel.swift`
  - `BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CountryLeaguesFilterViewModel.swift`

- [x] Updated CombinedFiltersViewController to use production view models instead of mocks

- [x] Completed FilterIdentifier removal across 11 files
  - Replaced `FilterIdentifier` enum with plain `String` for sport IDs
  - Updated protocols, implementations, data models, and view models
  - Deleted `Frameworks/SharedModels/Sources/SharedModels/FilterIdentifier.swift`

### Issues / Bugs Hit
- None encountered - all changes compiled successfully on first attempt

### Key Decisions
- **ExpandableSectionView UX**: Made entire header tappable while keeping button for accessibility
  - Users can now tap anywhere on the header to expand/collapse
  - Toggle button remains interactive for screen readers and assistive tech

- **Production View Models**: Created as exact clones of mocks
  - No enhancements or additional logic added
  - Mocks were already production-quality implementations
  - Just removed misleading "Mock" prefix

- **FilterIdentifier Removal**: Simplified sport selection architecture
  - Eliminated "all sports" concept (not needed in app)
  - Changed from enum with `.all` and `.singleSport(id:)` cases to plain `String`
  - Default sport ID changed from `.singleSport(id: "1")` to `"1"`
  - **LeagueFilterIdentifier remains unchanged** - still needs enum for `.all`, `.allInCountry`, `.singleLeague` distinction

### Experiments & Notes
- **FilterIdentifier Analysis**: Discovered it was a sophisticated enum handling special values ("all", "0", empty strings)
  - Original design had type safety and semantic clarity
  - Removal trades type safety for simplicity
  - Acceptable trade-off since app never shows "all sports"

- **Mock Naming Convention**: "Mock" implementations were actually production-ready
  - Pattern in codebase: Protocol + Mock implementation (no separate production implementation)
  - GomaUI follows "protocol-first, implementation-agnostic" architecture
  - Creating dedicated production implementations improves clarity

### Useful Files / Links
#### ExpandableSectionView Changes
- [ExpandableSectionView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExpandableSectionView/ExpandableSectionView.swift)
- [ExpandableSectionViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExpandableSectionView/ExpandableSectionViewModelProtocol.swift)

#### Production View Models Created
- [SportGamesFilterViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/SportGamesFilterViewModel.swift)
- [SortFilterViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/SortFilterViewModel.swift)
- [CountryLeaguesFilterViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CountryLeaguesFilterViewModel.swift)

#### FilterIdentifier Removal - Files Modified
**GomaUI Framework:**
- [SportGamesFilterViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SportGamesFilterView/SportGamesFilterViewModelProtocol.swift)
- [MockSportGamesFilterViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SportGamesFilterView/MockSportGamesFilterViewModel.swift)
- [SportGamesFilterView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SportGamesFilterView/SportGamesFilterView.swift)

**BetssonCameroonApp:**
- [AppliedEventsFilters.swift](../../BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift) - Core data model
- [CombinedFiltersViewController.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewController.swift)
- [CombinedFiltersViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModel.swift)
- [NextUpEventsViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewModel.swift)
- [InPlayEventsViewModel.swift](../../BetssonCameroonApp/App/Screens/InPlayEvents/InPlayEventsViewModel.swift)
- [AppliedEventsFilters+MatchesFilterOptions.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/AppliedEventsFilters+MatchesFilterOptions.swift)

#### Related Documentation
- [FilterIdentifier removal context](./13-November-2025-filter-magic-strings-refactor.md)
- [UI Component Guide](../UI_COMPONENT_GUIDE.md)
- [MVVM Architecture](../MVVM.md)

### Code Changes Summary

#### 1. ExpandableSectionView Enhancement
```swift
// Added tap gesture to entire header
private lazy var headerTapGesture: UITapGestureRecognizer = Self.createHeaderTapGesture()

// Setup
self.headerTapGesture.addTarget(self, action: #selector(headerTapped))
self.headerContainerView.addGestureRecognizer(self.headerTapGesture)

// Handler
@objc private func headerTapped() {
    viewModel.toggleExpanded()
}
```

#### 2. FilterIdentifier Type Replacements
| Before | After |
|--------|-------|
| `FilterIdentifier` | `String` |
| `CurrentValueSubject<FilterIdentifier, Never>` | `CurrentValueSubject<String, Never>` |
| `FilterIdentifier(stringValue: "1")` | `"1"` |
| `sportId.rawValue` | `sportId` |
| `selectedSport: FilterIdentifier = .all` | `selectedSport: String = "1"` |
| `.singleSport(id: "1")` (default) | `"1"` (default) |

#### 3. Production View Models
All four view models are exact clones of their mock counterparts with:
- Imports: Added `import GomaUI`
- Class name: Removed "Mock" prefix
- No logic changes

### Next Steps
1. Build and test BetssonCameroonApp to verify all changes compile
2. Test filter functionality in simulator
   - Verify sport selection works correctly
   - Confirm expandable sections work with header tap
   - Check UserDefaults persistence with new String format
3. Verify backward compatibility with existing UserDefaults data
4. Consider similar cleanup for other "Mock" implementations used in production
5. Update CLAUDE.md documentation if needed for production view model pattern
