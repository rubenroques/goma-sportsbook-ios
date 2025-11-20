# Development Journal: Production ScoreViewModel & Tennis Layout Implementation

## Date
18 November 2025

## Project / Branch
sportsbook-ios / rr/match_details_score

## Goals for this session
- Create production implementation of `ScoreViewModelProtocol` to replace Mock usage
- Implement complete Tennis layout support with new ScoreView features (serving indicator, separator, highlighting)
- Refactor `TallOddsMatchCardViewModel` to accept `Match` directly (remove factory method)
- Ensure sport-specific layout logic (Type C sports detection)

## Achievements
- [x] Created `ScoreViewModel.swift` - full production implementation with Combine publishers
- [x] Refactored `TallOddsMatchCardViewModel.init()` to accept `Match` directly instead of `TallOddsMatchData`
- [x] Removed factory method pattern - moved all logic into `init()` for cleaner API
- [x] Added `sportId` property stored from `match.sport.id` for Type C detection
- [x] Implemented complete score transformation logic with all new ScoreView features:
  - ✅ Type C sports detection (Tennis: "3", Volleyball: "20", etc.)
  - ✅ Serving indicator mapping (`activePlayerServing` → `servingPlayer`)
  - ✅ Highlighting modes (`.bothHighlight`, `.winnerLoser`, `.noHighlight`)
  - ✅ Separator logic (`showsTrailingSeparator = true` for game points in Type C sports)
  - ✅ MatchFull filtering (exclude total column for Tennis layout)
  - ✅ Current vs completed set detection for proper highlighting
- [x] Fixed type conversion issues with `ServiceProviderModelMapper`
- [x] Optimized date handling - stored raw `Date?` instead of converting String → Date
- [x] Updated all 3 call sites to use new init signature
- [x] Added comprehensive debug logging for Sport ID investigation

## Issues / Bugs Hit
- [x] **Type conversion error**: `Match.ActivePlayerServe` ≠ `ServicesProvider.ActivePlayerServe`
  - **Solution**: Added `mapActivePlayerServe()` helper function to convert between types
- [x] **Type conversion error**: `[String: ServicesProvider.Score]` ≠ `[String: Score]`
  - **Solution**: Used existing `ServiceProviderModelMapper.scoresDictionary()` function
- [x] **Compilation error**: Tried to access `.value` on `AnyPublisher<String?, Never>`
  - **Solution**: Store raw `Date?` from Match instead of parsing from ViewModel publisher
- [ ] **CRITICAL BUG - Sport ID always "0"**: ALL sports (Football, Tennis, etc.) showing:
  - `Sport.id: '0'`
  - `Sport.alphaId: 'nil'`
  - `Sport.numericId: 'nil'`
  - `Sport.name: 'FBL'` (even for Tennis matches!)
  - **Impact**: Type C detection completely broken → Tennis layout doesn't work
  - **Status**: Debug logging added, awaiting investigation of Sport mapping pipeline

## Key Decisions
- **Eliminated factory method**: Changed from `TallOddsMatchCardViewModel.create(from:)` to direct `init(match:)` for simpler, more straightforward API
- **Store sport ID at initialization**: Capture `match.sport.id` early so it's available during real-time updates when only `EventLiveData` is provided
- **Type C sport IDs**: Hardcoded array `["3", "20", "64", "63", "14"]` for Tennis, Volleyball, Beach Volleyball, Table Tennis, Badminton
- **Serving indicator placement**: Only attach to first score cell (game points) to match web design
- **Highlighting strategy**:
  - Current game/set → `.bothHighlight`
  - Completed sets → `.winnerLoser` (allows ScoreCellView to compare scores)
  - Total scores (non-Type C) → `.bothHighlight`
- **Date handling optimization**: Use `match.date: Date?` directly instead of formatting to string and parsing back

## Architecture Improvements
### Before (Factory Pattern):
```swift
// Factory method with intermediate data structure
static func create(from match: Match, ...) -> TallOddsMatchCardViewModel {
    let tallOddsMatchData = TallOddsMatchData(...)
    return TallOddsMatchCardViewModel(matchData: tallOddsMatchData)
}
```

### After (Direct Init):
```swift
// Clean init accepting domain model directly
init(match: Match, relevantMarkets: [Market], marketTypeId: String, ...) {
    self.sportId = match.sport.id  // Store sport info
    // Create child ViewModels directly from Match
}
```

**Benefits**:
- ✅ Less indirection - easier to understand
- ✅ Removed intermediate `TallOddsMatchData` structure
- ✅ Sport ID properly captured and accessible
- ✅ Cleaner call sites

## Score Transformation Logic

### Type C Sports (Tennis Layout)
```
Expected: [●] [15/30] | [6/4] [4/6] [7/6]
          ^    ^      ^  ^     ^     ^
          |    |      |  |     |     └─ Current set (.bothHighlight)
          |    |      |  └─────┴─────── Completed sets (.winnerLoser)
          |    |      └──────────────── Vertical separator
          |    └─────────────────────── Current game (.bothHighlight, separator)
          └──────────────────────────── Serving indicator
```

**Implementation**:
1. Filter out `.matchFull` scores for Type C sports
2. Map `activePlayerServing` to first cell's `servingPlayer`
3. Set `.gamePart` → `highlightingMode: .bothHighlight`, `showsTrailingSeparator: true`
4. Detect current set (last set index) vs completed sets
5. Set completed `.set` → `highlightingMode: .winnerLoser`
6. Set current `.set` → `highlightingMode: .bothHighlight`

### Type A/B Sports (Basketball/Football)
```
Basketball: [25/22] [18/28] [31/24] [26/30] [100/104]
            ^        ^        ^        ^        ^
            |        |        |        |        └─ Total (.bothHighlight)
            └────────┴────────┴────────┘─────────── Quarters (.winnerLoser)

Football: [2/1]
          ^
          └─ Single score (.bothHighlight)
```

## Experiments & Notes

### Sport ID Mapping Investigation
**Problem**: All sports showing default values instead of correct IDs

**Debug logs reveal**:
```
Football matches: Sport.id='0', name='FBL', alphaId=nil, numericId=nil
Tennis matches:   Sport.id='0', name='FBL', alphaId=nil, numericId=nil (WRONG!)
```

**Expected for Tennis**:
```
Sport.id='3', name='Tenis', alphaId='TNS', numericId='2'
```

**Hypothesis**: Sport mapping pipeline broken at one of these layers:
1. **Goma API** → `GomaModels.Sport` (identifier: "2", name: "Tenis")
2. **GomaModelMapper** → `ServicesProvider.SportType` (iconId: "3", numericId: "2", alphaId: should be "TNS")
3. **ServiceProviderModelMapper** → `App Sport` (id: fallback chain result)

**Known issues in mapping**:
- `GomaModelMapper+Sports.swift:28` sets `alphaId: sport.identifier` (numeric "2" instead of alpha "TNS")
- Fallback chain: `iconId ?? alphaId ?? numericId ?? "0"`
- If all three are nil → defaults to "0"

**Next investigation needed**: Add logging at each mapping layer to trace where data is lost

## Useful Files / Links

### Implementation Files
- [ScoreViewModel.swift](../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/ScoreViewModel.swift) - Production ScoreViewModel implementation
- [TallOddsMatchCardViewModel.swift](../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/TallOddsMatchCardViewModel.swift) - Main ViewModel with refactored init
- [ScoreView.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreView.swift) - UI component with new features
- [ScoreViewModelProtocol.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreViewModelProtocol.swift) - Protocol definition

### Data Models
- [Match.swift](../BetssonCameroonApp/App/Models/Events/Match.swift) - Domain model with sport, scores, activePlayerServe
- [Score.swift](../BetssonCameroonApp/App/Models/Events/Score.swift) - Score enum (.set, .gamePart, .matchFull)
- [Sport.swift](../BetssonCameroonApp/App/Models/Events/Sport.swift) - Sport model with id, alphaId, numericId

### Mappers (Sport ID Investigation)
- [ServiceProviderModelMapper+Sports.swift](../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Sports.swift) - App layer Sport mapping
- [ServiceProviderModelMapper+Scores.swift](../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Scores.swift) - Score type conversion
- [GomaModelMapper+Sports.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/Mappers/GomaModelMapper+Sports.swift) - Provider layer Sport mapping with iconId lookup

### Call Sites Updated
- [SportsBetslipViewModel.swift](../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewModel.swift:150) - Updated to use new init
- [MarketGroupCardsViewModel.swift](../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewModel.swift:127) - Updated to use new init
- [SportsSearchViewModel.swift](../BetssonCameroonApp/App/Screens/SportsSearch/SportsSearchViewModel.swift:264) - Updated to use new init

### Related Documentation
- [18-November-2025-scoreview-tennis-web-parity.md](./18-November-2025-scoreview-tennis-web-parity.md) - Previous session adding ScoreView features
- [UI Component Guide](../UI_COMPONENT_GUIDE.md) - GomaUI component patterns
- [MVVM.md](../MVVM.md) - Architecture guidelines

## Code Snippets

### Production ScoreViewModel
```swift
final class ScoreViewModel: ScoreViewModelProtocol {
    private let scoreCellsSubject = CurrentValueSubject<[ScoreDisplayData], Never>([])
    private let visualStateSubject = CurrentValueSubject<ScoreViewVisualState, Never>(.idle)

    func updateScoreCells(_ cells: [ScoreDisplayData]) {
        scoreCellsSubject.send(cells)
        visualStateSubject.send(cells.isEmpty ? .empty : .display)
    }
}
```

### Type C Detection & Transformation
```swift
let isTypeCsport = ["3", "20", "64", "63", "14"].contains(sportId)

switch score {
case .gamePart(let home, let away):
    // Current game - highlighted, separator for Type C, serving indicator
    ScoreDisplayData(
        style: .background,
        highlightingMode: .bothHighlight,
        showsTrailingSeparator: isTypeCsport,
        servingPlayer: isFirstCell ? servingPlayer : nil
    )

case .set(let index, let home, let away):
    // Determine if current or completed set
    let isCurrentSet = (index == lastSetIndex)
    ScoreDisplayData(
        style: .simple,
        highlightingMode: isCurrentSet ? .bothHighlight : .winnerLoser,
        showsTrailingSeparator: false
    )

case .matchFull(_, _):
    // Skip for Type C sports (Tennis doesn't show totals)
    if isTypeCsport { continue }
}
```

### Serving Player Mapping
```swift
private static func mapServingPlayer(from serving: ServicesProvider.ActivePlayerServe?) -> ScoreDisplayData.ServingPlayer? {
    switch serving {
    case .home: return .home
    case .away: return .away
    case .none: return nil
    }
}
```

## Performance Considerations
- Storing `sportId` as property avoids repeated lookups during real-time updates
- Using `CurrentValueSubject` instead of `@Published` for precise Combine control
- Score transformation happens once per EventLiveData update
- Type C detection is O(1) with hardcoded array check

## Testing Notes
**Manual testing performed**:
- ✅ Compilation successful with all type conversions fixed
- ⚠️ Runtime testing blocked by Sport ID bug
- 📋 Need to verify Tennis layout once Sport mapping is fixed

**Expected visual verification**:
1. Tennis matches should show game points with serving indicator
2. Vertical separator should appear after game points
3. Completed sets should use winner/loser highlighting (colored background)
4. Current set should use both-highlight (no color differentiation)
5. Total score column should NOT appear for Tennis

## Next Steps
1. **CRITICAL**: Investigate and fix Sport mapping pipeline
   - Add logging at GomaModelMapper layer
   - Add logging at ServiceProviderModelMapper layer
   - Trace where Sport.id becomes "0"
   - Fix iconId/alphaId/numericId population
2. Test Tennis matches with correct Sport ID to verify layout implementation
3. Verify Basketball/Football layouts still work correctly
4. Test serving indicator updates during live match
5. Test score cell highlighting transitions (current → completed set)
6. Consider removing debug logs after Sport ID fix is verified
7. Update development journal with Sport mapping fix details

## Blockers
- **Sport ID mapping completely broken**: Type C detection fails for ALL sports
  - Tennis matches incorrectly identified as Type A/B
  - Cannot verify Tennis layout implementation until fixed
  - Debug logging added but needs runtime investigation

## Performance Impact
**Positive**:
- Eliminated unnecessary Date string parsing (removed 17 lines of code)
- Direct Match init reduces object allocation overhead
- Sport ID stored once, used many times during live updates

**Neutral**:
- Score transformation complexity remains same
- Additional serving indicator logic is minimal

## Migration Impact
**Breaking changes**:
- All call sites using `TallOddsMatchCardViewModel.create()` must switch to `init()`
- ✅ All 3 call sites updated in this session

**Non-breaking**:
- Protocol interface unchanged
- GomaUI ScoreView API unchanged
- Real-time update flow unchanged

---

**Session Duration**: ~3 hours
**Lines Changed**: +450 / -200
**Files Modified**: 5
**Files Created**: 1 (ScoreViewModel.swift)
