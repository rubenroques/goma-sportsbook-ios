## Date
12 January 2026

### Project / Branch
BetssonCameroonApp / main

### JIRA Ticket
[SPOR-7110](https://gomagaming.atlassian.net/browse/SPOR-7110) - BC-470 - Favorites option is present in nav bar and filters

### Goals for this session
- Remove Favorites functionality from user-visible Sports UI in BetssonCameroonApp
- Keep frameworks (GomaUI, ServicesProvider) untouched
- Keep Casino favorites untouched
- Surgical removal focusing only on what users see

### Achievements
- [x] Removed Favorites QuickLink from `QuickLinksTabBarViewModel.forCasinoScreens()`
- [x] Made `.favourites` case a no-op in `MainTabBarCoordinator`
- [x] Hidden favorite button in `MatchHeaderViewModel` (changed `Just(true)` to `Just(false)`)
- [x] Removed Favorites FilterOption from `CombinedFiltersViewController.createFilterConfiguration()`
- [x] Removed Favorites SortOption from `NextUpEventsViewModel.getSortOption()`
- [x] Removed `.favorites` case from `AppliedEventsFilters.SortType` enum
- [x] Updated `AppliedEventsFilters+MatchesFilterOptions.swift` to handle framework's `.favorites` with fallback to `.popular`

### Issues / Bugs Hit
- None encountered during implementation

### Key Decisions
- **Keep frameworks intact**: GomaUI and ServicesProvider still have `.favourites`/`.favorites` enum cases - only BetssonCameroonApp UI is affected
- **Fallback strategy**: When ServicesProvider returns `.favorites` sort type, we map it to `.popular` as a safe fallback
- **No style changes**: StyleProviderColors favorites color left untouched
- **No service removal**: FavoritesManager service kept in place (may be used elsewhere or for future re-enablement)

### Files Modified

| File | Change |
|------|--------|
| `BetssonCameroonApp/App/ViewModels/QuickLinksTabBarViewModel.swift` | Removed favourites QuickLinkItem |
| `BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift` | Made .favourites case break |
| `BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/MatchHeaderViewModel.swift` | `isFavoriteButtonVisiblePublisher` returns `Just(false)` |
| `BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewController.swift` | Removed favourites from filter config and icon mapping |
| `BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewModel.swift` | Removed favourites from sort options |
| `BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift` | Removed `.favorites` from `SortType` enum |
| `BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/AppliedEventsFilters+MatchesFilterOptions.swift` | Fallback for `.favorites` to `.popular` |

### Useful Files / Links
- [SPOR-7110 - Jira Ticket](https://gomagaming.atlassian.net/browse/SPOR-7110)
- [Plan File](../../.claude/plans/curried-conjuring-zebra.md)
- [QuickLinksTabBarViewModel](../../BetssonCameroonApp/App/ViewModels/QuickLinksTabBarViewModel.swift)
- [MatchHeaderViewModel](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/MatchHeaderViewModel.swift)
- [CombinedFiltersViewController](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewController.swift)
- [AppliedEventsFilters](../../BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift)

### Next Steps
1. Build BetssonCameroonApp to verify no compilation errors
2. Manual QA testing:
   - Verify Favorites quick link NOT visible in casino quick links bar
   - Verify Favorites option NOT in Sort By filter
   - Verify star/favorite icon NOT visible in match headers
3. Create PR for code review
