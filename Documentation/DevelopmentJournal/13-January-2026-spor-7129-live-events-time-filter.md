## Date
13 January 2026

### Project / Branch
BetssonCameroonApp / rr/gomaui_snapshot_test

### JIRA Ticket
[SPOR-7129](https://gomagaming.atlassian.net/browse/SPOR-7129) - [iOS] BA - BC-473 - Match list is not populated with live events while on Live section

### Goals for this session
- Investigate why live events are not displaying in the Live section
- Understand the filter architecture between pre-match and live screens
- Fix the API call to use correct parameters for live events
- Hide the time filter UI when in live mode (irrelevant for live events)

### Achievements
- [x] Identified root cause: API sends time range (e.g., `0-24`) instead of `all` for live events
- [x] Mapped the complete filter flow: `AppliedEventsFilters` → `MatchesFilterOptions` → `LiveMatchesPaginator.buildTopic()` → WAMP API
- [x] Fixed `LiveMatchesPaginator.swift:151` to hardcode `hoursInterval: "all"` for live events
- [x] Added `isLiveMode` to `CombinedFiltersViewModelProtocol`
- [x] Updated `CombinedFiltersViewController` to skip `timeFilter` widget when `isLiveMode == true`

### Issues / Bugs Hit
- None - straightforward implementation once root cause was identified

### Key Decisions
- **Hardcode "all" in LiveMatchesPaginator** rather than modifying `MatchesFilterOptions` struct - cleaner and more explicit
- **Skip widget in loop** rather than creating separate filter context - minimal change, same effect
- **Protocol already had `isLiveMode`** in ViewModel, just needed to expose it in protocol for ViewController access

### Technical Analysis

**Current API call (broken):**
```
/sports/{op}/{lang}/custom-matches-aggregator/{sportId}/all/all/0-24/UPCOMING/LIVE/10/5
```

**Required API call (fixed):**
```
/sports/{op}/{lang}/custom-matches-aggregator/{sportId}/all/all/all/UPCOMING/LIVE/10/5
```

**Filter Architecture:**
- Filters are **shared** between Live and Pre-Match screens (same `AppliedEventsFilters`)
- `isLiveMode` flag only affected league counts (live vs all events), not TimeSlider visibility
- TimeSlider values map to `TimeRange.serverRawValue`: `all`, `0-1`, `0-8`, `0-24`, `0-48`

### Files Modified
| File | Change |
|------|--------|
| `Frameworks/ServicesProvider/.../LiveMatchesPaginator.swift:151` | Hardcode `hoursInterval: "all"` |
| `BetssonCameroonApp/.../CombinedFiltersViewModelProtocol.swift` | Add `isLiveMode: Bool { get }` |
| `BetssonCameroonApp/.../CombinedFiltersViewController.swift:491-495` | Skip timeFilter when isLiveMode |

### Useful Files / Links
- [LiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/LiveMatchesPaginator.swift) - WAMP topic builder
- [CombinedFiltersViewController.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewController.swift) - Filter UI
- [MatchesFilterOptions.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/MatchesFilterOptions.swift) - TimeRange enum
- [InPlayEventsViewModel.swift](../../BetssonCameroonApp/App/Screens/InPlayEvents/InPlayEventsViewModel.swift) - Live events screen ViewModel
- [SPOR-7129](https://gomagaming.atlassian.net/browse/SPOR-7129) - Jira ticket
- [SPOR-7130](https://gomagaming.atlassian.net/browse/SPOR-7130) - Android equivalent
- [SPOR-7131](https://gomagaming.atlassian.net/browse/SPOR-7131) - Web equivalent

### Client Guidance (from Jira)
> "to ask for live events you don't need to add time range, the correct call is `/sports/4374/en/custom-matches-aggregator/1/all/all/all/UPCOMING/LIVE/10/5`"

### Next Steps
1. Build and verify on simulator
2. Test live section with multiple sports to confirm events populate
3. Verify filters modal no longer shows TimeSlider in live mode
4. Create PR for review
