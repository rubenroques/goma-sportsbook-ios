# Development Journal

## Date
25 November 2025

### Project / Branch
sportsbook-ios / rr/boot_performance

### Goals for this session
- Build and run GomaUIDemo app
- Fix compilation errors caused by GomaUI API drift
- Sync Demo app with current GomaUI component interfaces

### Achievements
- [x] Fixed filter component API changes (`selectedId` → `selectedSport`/`selectedFilter` with enum types)
  - SportGamesFilterViewController, SortFilterViewController
  - CombinedFiltersDemoViewController (complex refactor with synchronization logic)
  - ComponentRegistry and ComponentsTableViewController
- [x] Fixed StyleProvider color/font API changes
  - Replaced 26 occurrences of `StyleProvider.Color.backgroundColor` → `.backgroundTestColor`
  - Fixed `textColor` → `textPrimary`, `secondaryColor` → `textSecondary`
  - Fixed `FontType.italic` → `FontType.light` (italic doesn't exist)
- [x] Fixed BetslipOddsBoostHeaderView API changes
  - Removed `nextTierPercentage` parameter from `activeMock()` calls
  - Updated `updateInfoLabel()` to use available state properties
- [x] Made internal mocks public for Demo app access
  - `MockCustomExpandableSectionViewModel`: `internal` → `public`
  - `MockPendingWithdrawViewModel`: `internal` → `public`
  - `PromotionItemView.viewModel`: `private` → `public`
- [x] Fixed MatchHeaderCompactViewController
  - `withoutStatistics` → `liveFootballMatch` (non-existent mock variant)
  - `onStatisticsTapped` → `onCountryTapped`/`onLeagueTapped`
- [x] Fixed PromotionItemViewController
  - Removed code accessing `.value` on `AnyPublisher` (not available)
- [x] GomaUIDemo builds successfully

### Issues / Bugs Hit
- Demo app was out of sync with GomaUI library after multiple refactoring sessions
- Filter system underwent major type-safe refactoring (String → FilterIdentifier/LeagueFilterIdentifier enums)
- Several mock ViewModels were marked `internal` instead of `public`, blocking Demo app access

### Key Decisions
- Used `.backgroundTestColor` for all Demo VC backgrounds (contrast color for testing)
- Replaced `italic` font type with `light` as closest available alternative
- Simplified PromotionItemViewController by removing broken reset logic
- Used existing `liveFootballMatch` mock instead of creating new `withoutStatistics` variant

### Experiments & Notes
- Filter API evolution documented in DJs:
  - `13-November-2025-filter-magic-strings-refactor.md` - Created FilterIdentifier/LeagueFilterIdentifier enums
  - `13-November-2025-expandable-section-filter-identifier-refactor.md` - Further refinements
- Pattern: Demo app drift is common when GomaUI components evolve - consider CI integration tests

### Useful Files / Links
#### Filter Components (API changed)
- [MockSportGamesFilterViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SportGamesFilterView/MockSportGamesFilterViewModel.swift)
- [MockSortFilterViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SortFilterView/MockSortFilterViewModel.swift)
- [SportGamesFilterViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SportGamesFilterView/SportGamesFilterViewModelProtocol.swift)
- [SortFilterViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SortFilterView/SortFilterViewModelProtocol.swift)

#### Demo Files Fixed
- [SportGamesFilterViewController](../../Frameworks/GomaUI/Demo/Components/SportGamesFilterViewController.swift)
- [SortFilterViewController](../../Frameworks/GomaUI/Demo/Components/SortFilterViewController.swift)
- [CombinedFiltersDemoViewController](../../Frameworks/GomaUI/Demo/Components/CombinedFilters/CombinedFiltersDemoViewController.swift)
- [ComponentRegistry](../../Frameworks/GomaUI/Demo/Components/ComponentRegistry.swift)
- [ComponentsTableViewController](../../Frameworks/GomaUI/Demo/Components/ComponentsTableViewController.swift)
- [BetslipOddsBoostHeaderViewController](../../Frameworks/GomaUI/Demo/Components/BetslipOddsBoostHeaderViewController.swift)
- [MatchHeaderCompactViewController](../../Frameworks/GomaUI/Demo/Components/MatchHeaderCompactViewController.swift)
- [PromotionItemViewController](../../Frameworks/GomaUI/Demo/Components/PromotionItemViewController.swift)

#### Mocks Made Public
- [MockCustomExpandableSectionViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CustomExpandableSectionView/MockCustomExpandableSectionViewModel.swift)
- [MockPendingWithdrawViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/PendingWithdrawView/MockPendingWithdrawViewModel.swift)
- [PromotionItemView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/PromotionItemView/PromotionItemView.swift)

### Next Steps
1. Run GomaUIDemo in simulator to verify components render correctly
2. Consider adding CI build check for GomaUIDemo to catch API drift early
3. Review other Demo ViewControllers for potential similar issues
