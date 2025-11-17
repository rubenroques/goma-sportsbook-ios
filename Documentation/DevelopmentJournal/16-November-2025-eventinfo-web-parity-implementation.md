# Development Journal

## Date
16 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Port Betsson Cameroon web app's EVENT_INFO system to iOS EveryMatrix provider
- Implement 48 sports support via template system (BASIC, SIMPLE, DETAILED, DEFAULT)
- Add card tracking (yellow/yellowRed/red) from EVENT_INFO typeIds 2, 3, 4
- Maintain zero breaking changes to existing Score enum and EventLiveData
- Create reusable EventLiveDataBuilder for all subscription managers

### Achievements
- [x] Created `EveryMatrixSportPatterns.swift` with 48 sports mapped to 4 templates
- [x] Implemented regex pattern matching for score parts (quarters, periods, innings, sets, games)
- [x] Created `FootballCards` struct (cleaner than tuples, properly Codable/Equatable)
- [x] Extended `EventLiveData` with card properties (yellowCards, yellowRedCards, redCards, totalCards computed)
- [x] Built `EventLiveDataBuilder` - stateless utility with all transformation logic (~400 lines)
- [x] Implemented 4 score templates exactly matching web app logic:
  - **BASIC** (9 sports): Football, Rugby, MMA - only whole match score
  - **SIMPLE** (18 sports): Basketball (Q1-Q4), Ice Hockey (P1-P3), Baseball (innings), Volleyball (sets)
  - **DETAILED** (Tennis): Sets + current game points (0, 15, 30, 40, 50=Advantage) + serve indicator
  - **DEFAULT**: Unknown sports fallback to whole match score
- [x] Implemented 7 EVENT_INFO type handlers (SCORE, YELLOW_CARDS, YELLOW_RED_CARDS, RED_CARDS, SERVE, EVENT_STATUS, MATCH_TIME)
- [x] Refactored `LiveMatchesPaginator.swift` - replaced ~200 lines with simple delegation to EventLiveDataBuilder
- [x] Added comprehensive logging with `[LIVE_SCORE]` prefix throughout entire data flow:
  - EventLiveDataBuilder: Card extraction, participant mapping, final result summary
  - LiveMatchesPaginator: EventInfo receipt, type logging, match data confirmation
  - TallOddsMatchCardViewModel: EventLiveData receipt, transformation details, critical warnings

### Issues / Bugs Hit
- [ ] Cards not showing in "Live"/"In Play" screen UI
  - **Root cause identified via logs**: `LiveScoreData` model doesn't include card properties
  - EventLiveDataBuilder correctly extracts cards → EventLiveData receives cards → ViewModel receives cards → BUT transformation to LiveScoreData drops them
  - Need to extend UI models and components to display cards

### Key Decisions
- **Used FootballCards struct instead of tuples**: Properly Codable/Equatable, cleaner API, includes `hasCards` computed property
- **Stateless EventLiveDataBuilder**: Simple static methods, no dependencies, used by all subscription managers
- **Pattern-based matching over eventPartId hardcoding**: Language-independent regex patterns make system robust across different API response formats
- **Active period filtering (statusId "1")**: Only show live periods for SIMPLE/DETAILED templates to reduce UI clutter
- **Default template fallback**: Unknown sports gracefully show whole match score
- **Score enum unchanged**: Used existing `.set`, `.gamePart`, `.matchFull` cases - no breaking changes
- **EveryMatrix provider only**: No changes to SportRadar or Goma providers (per user request)
- **Comprehensive logging strategy**: `[LIVE_SCORE]` prefix enables easy filtering, reveals exact data flow bottleneck

### Experiments & Notes
- **Web app comparison**: Direct port from `eventInfoScores.js` (408 lines), `constants.js` (145 lines)
- **Pattern matching examples**:
  ```swift
  EveryMatrixSportPatterns.isQuarter("2nd Quarter") // true
  EveryMatrixSportPatterns.extractOrdinalNumber("3rd Set") // 3
  ```
- **Participant ID mapping is critical**: Never assume paramFloat1 is home score - EveryMatrix API doesn't guarantee order
- **Basketball example output**:
  ```swift
  detailedScores = [
    "Whole Match": .matchFull(88, 84),
    "Q1": .gamePart(25, 20),
    "Q2": .gamePart(22, 24),
    "Q3": .gamePart(18, 21),
    "Q4": .gamePart(23, 19)  // Only active quarter shown
  ]
  ```
- **Tennis example output**:
  ```swift
  detailedScores = [
    "Whole Match": .matchFull(2, 1),  // Sets won
    "Game": .gamePart(30, 15),        // Current game points
    "1st Set": .set(1, 6, 4),
    "2nd Set": .set(2, 3, 6),
    "3rd Set": .set(3, 2, 1)
  ]
  activePlayerServing = .home
  ```

### Useful Files / Links
- [EventLiveDataBuilder.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/EventLiveDataBuilder.swift) - Main transformation logic
- [EveryMatrixSportPatterns.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/EveryMatrixSportPatterns.swift) - Template mappings, regex patterns
- [FootballCards.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Events/Core/FootballCards.swift) - Card data model
- [EventLiveData.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Events/Core/EventLiveData.swift) - Extended with card properties
- [LiveMatchesPaginator.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/LiveMatchesPaginator.swift) - Simplified to use builder
- [TallOddsMatchCardViewModel.swift](../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/TallOddsMatchCardViewModel.swift) - ViewModel with logs revealing UI gap
- [Web App EVENT_INFO Docs](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Documentation/README.md) - EveryMatrix WebSocket docs

### Architecture Overview
```
┌─────────────────────────────────────────────────────────┐
│ WebSocket EVENT_INFO (EveryMatrix)                      │
│ typeId: 1=SCORE, 2=YELLOW_CARDS, 3=YELLOW_RED_CARDS,   │
│         4=RED_CARDS, 37=SERVE, 92=EVENT_STATUS, 95=TIME│
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ EventLiveDataBuilder.buildEventLiveData()               │
│ - Determines sport template (sportId → BASIC/SIMPLE/    │
│   DETAILED/DEFAULT)                                      │
│ - Processes EventInfos by typeId                        │
│ - Maps scores via participant IDs (critical!)           │
│ - Extracts cards with FootballCards struct              │
│ - Returns EventLiveData with detailedScores + cards     │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ LiveMatchesPaginator.observeEventInfosForEvent()        │
│ - Observes EventInfo entities from EntityStore          │
│ - Gets MatchDTO for participant mapping                 │
│ - Calls EventLiveDataBuilder                            │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ TallOddsMatchCardViewModel.updateScoreViewModel()       │
│ - Receives EventLiveData with cards ✅                  │
│ - Transforms to LiveScoreData (scoreCells only) ⚠️      │
│ - Cards are dropped here! 🐛                            │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ UI Components                                            │
│ - ScoreView renders scoreCells ✅                       │
│ - Cards not rendered (no data!) ❌                      │
└─────────────────────────────────────────────────────────┘
```

### Next Steps
1. **Extend UI models to include cards**:
   - Add `cards: FootballCards?` property to `LiveScoreData` or `MatchHeaderData`
   - Update `transformEventLiveDataToLiveScoreData()` to pass cards through
2. **Create card display UI component**:
   - GomaUI component for card display (yellow/red card icons with counts)
   - Integrate into TallOddsMatchCard or MatchHeader
3. **Test with live football match**: Run app with `[LIVE_SCORE]` filter to verify:
   - EventInfos with typeId 2, 3, 4 are received
   - Participant mapping is correct (home/away assignment)
   - Cards flow through to ViewModel
   - UI displays cards correctly
4. **Test other sports**:
   - Basketball: Verify quarters (Q1-Q4) display correctly
   - Tennis: Verify sets + current game points + serve indicator
   - Unknown sport: Verify DEFAULT template shows whole match score
5. **Remove debug logs**: Once cards are working, remove or conditionalize `[LIVE_SCORE]` logs
6. **Update CLAUDE.md**: Document EventLiveDataBuilder usage pattern for future development

### Code Statistics
- **New files**: 2 (EventLiveDataBuilder.swift, EveryMatrixSportPatterns.swift)
- **Modified files**: 3 (EventLiveData.swift, LiveMatchesPaginator.swift, TallOddsMatchCardViewModel.swift)
- **New lines**: ~675 (EventLiveDataBuilder ~400, EveryMatrixSportPatterns ~250, EventLiveData ~25)
- **Removed lines**: ~200 (old buildEventLiveData logic in LiveMatchesPaginator)
- **Net impact**: +475 lines
- **Sports supported**: 48 (via template system)
- **EVENT_INFO types**: 7 (SCORE + 3 card types + SERVE + STATUS + TIME)
- **Breaking changes**: 0 (all extensions use optional parameters with defaults)
