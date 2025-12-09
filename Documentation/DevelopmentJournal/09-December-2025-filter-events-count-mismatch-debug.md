## Date
09 December 2025

### Project / Branch
BetssonCameroonApp / rr/issues_debug_and_test

### Goals for this session
- Debug why Champions League filter shows "25 events" but displays nothing when applied
- Understand the WAMP data flow for tournament counts and match fetching
- Identify root cause of the mismatch between filter count and actual events

### Achievements
- [x] Identified root cause: hierarchical tournament structure in EveryMatrix
- [x] Confirmed issue on both STG (operator 4093) and PROD (operator 4374)
- [x] Documented the data model mismatch between `numberOfEvents` and actual matches
- [x] Added surgical logging with `[FILTER_DEBUG]` prefix to key files
- [x] Created comprehensive summary for team communication

### Issues / Bugs Hit
- [x] Parent tournaments report aggregated `numberOfEvents` including child tournaments
- [x] `custom-matches-aggregator` API returns 0 matches for parent tournament IDs
- [x] Only child/leaf tournaments return actual matches

### Key Decisions
- Root cause is an **EveryMatrix API data model issue**, not an iOS app bug
- The `numberOfEvents` field is an aggregate count (includes children), but match queries only return direct children
- Need to discuss with team whether to filter out parent tournaments or recursively fetch child tournaments

### Experiments & Notes

**Tournament Hierarchy Example:**
```
UEFA Champions League 2025/2026 (parent)
  └── UEFA Champions League - League Stage 2025/2026 (child)
```

**API Behavior:**
| Tournament | ID | numberOfEvents | Matches Returned |
|------------|----|-----------------:|:-----------------|
| Parent: UEFA Champions League 2025/2026 | `272811505422045184` | 25 | **0** |
| Child: League Stage 2025/2026 | `280068766176514048` | 21 | **18** |

**Key WAMP Endpoints:**
- Tournament counts: `/sports#popularTournaments` or `/sports#tournaments`
- Match fetching: `/sports/{operatorId}/{lang}/custom-matches-aggregator/{sportId}/{locationId}/{tournamentId}/...`

**Parent vs Child identification:**
- Tournaments with `parentId` field are children
- Tournaments without `parentId` are potential parent/containers

### Useful Files / Links
- [CombinedFiltersViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModel.swift) - Filter count display logic
- [AppliedEventsFilters+MatchesFilterOptions.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/AppliedEventsFilters+MatchesFilterOptions.swift) - Filter to API conversion
- [PreLiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/PreLiveMatchesPaginator.swift) - WAMP topic construction
- [SportTournamentsManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/SportTournamentsManager.swift) - Tournament subscription
- [WAMPRouter.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/WAMPRouter.swift) - WAMP route definitions

### Next Steps
1. Discuss with team the preferred solution approach:
   - Option A: Filter out parent tournaments (only show leaf tournaments in UI)
   - Option B: Recursively fetch child tournament IDs when parent is selected
   - Option C: Use `numberOfUpcomingMatches` instead of `numberOfEvents`
   - Option D: Check for `parentId` field to identify parent vs leaf tournaments
2. Coordinate with EveryMatrix if API-side fix is possible
3. Remove debug logging after fix is implemented
