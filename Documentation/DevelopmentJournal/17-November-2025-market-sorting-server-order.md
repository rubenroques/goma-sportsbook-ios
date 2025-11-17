## Date
17 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Understand complete sorting flow for Events, Markets, and Outcomes from WAMP to UI
- Document the entire data transformation pipeline
- Remove client-side market sorting to preserve server order

### Achievements
- [x] Traced complete sorting architecture across 3 layers: Server (Events) → Builder (Markets) → Builder (Outcomes)
- [x] Documented 90+ outcome sorting patterns in `EveryMatrixModelMapper.sortValue()`
- [x] Verified EntityStore's `getAllInOrder()` preserves WAMP insertion order via `entityOrder` array
- [x] Commented out paramFloat1/2/3 market sorting in MatchBuilder to trust server ordering
- [x] Created comprehensive sorting flow documentation with code references

### Issues / Bugs Hit
- Initial confusion: MatchesFilterOptions appeared unused but is actually the bridge between app-level AppliedEventsFilters and provider-level WAMP parameters

### Key Decisions
- **Server-Trust Architecture**: Markets now follow same strategy as Events - preserve WAMP server order instead of client-side re-sorting
- Kept outcome sorting (headerNameKey-based) because it's semantic ordering (Home/Draw/Away patterns) vs market sorting which was arbitrary paramFloat-based
- EntityStore's `entityOrder: [String: [String]]` dictionary already maintains insertion order perfectly - no need to change storage mechanism

### Experiments & Notes
- MatchesFilterOptions is NOT SportRadar backward compatibility - it's actively used for EveryMatrix filtering
- AppliedEventsFilters → MatchesFilterOptions conversion happens in `AppliedEventsFilters+MatchesFilterOptions.swift`
- WAMP topic format: `/sports/{op}/{lang}/custom-matches-aggregator/{sportId}/{locationId}/{tournamentId}/{hoursInterval}/{sortEventsBy}/...`
- SortBy enum values: "POPULAR" (most bet-on), "UPCOMING" (start time), "FAVORITES" (user favorited)

### Useful Files / Links
**Sorting Architecture**:
- [MatchesFilterOptions.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/MatchesFilterOptions.swift) - Provider-level filter enums (lines 64-106)
- [AppliedEventsFilters.swift](../../BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift) - App-level filter enums (lines 41-57)
- [AppliedEventsFilters+MatchesFilterOptions.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/AppliedEventsFilters+MatchesFilterOptions.swift) - Conversion logic (lines 30-39)

**WAMP Integration**:
- [PreLiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/PreLiveMatchesPaginator.swift) - Passes sortBy to WAMP (line 161)
- [LiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/LiveMatchesPaginator.swift) - Passes sortBy to WAMP (line 151)

**Builder Pattern**:
- [MatchBuilder.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/Builders/MatchBuilder.swift) - Market sorting commented out (lines 51-77, 103)
- [MarketBuilder.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/Builders/MarketBuilder.swift) - Outcome sorting (lines 34-43)

**Outcome Sorting Logic**:
- [EveryMatrixModelMapper+Events.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+Events.swift) - sortValue() with 90+ patterns (lines 244-342)

**EntityStore**:
- [EntityStore.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/Store/EntityStore.swift) - Order preservation (line 17, 33-36, 100-107)

### Data Flow Summary
```
WAMP Socket (Server-sorted Events)
    ↓
EntityStore.store() → entityOrder array (insertion order preserved)
    ↓
MatchBuilder.getAllInOrder() → markets in server order
    ↓
MarketBuilder → outcomes sorted by headerNameKey patterns
    ↓
EveryMatrixModelMapper → Domain models
    ↓
ViewModels → UI (no additional sorting)
```

### Sorting Responsibilities
- **Events**: Server (POPULAR/UPCOMING/FAVORITES via WAMP topic parameter)
- **Markets**: Server (preserved via EntityStore.getAllInOrder, previously client-sorted by paramFloat1/2/3)
- **Outcomes**: Client (90+ headerNameKey patterns: home=10, draw=20, away=30, etc.)

### Next Steps
1. Test in simulator to verify market order matches backend expectations
2. Monitor for any visual regressions where paramFloat sorting was relied upon
3. Consider documenting why outcomes still need client-side sorting (semantic vs arbitrary ordering)
4. Update CLAUDE.md or architecture docs if this server-trust strategy becomes canonical
