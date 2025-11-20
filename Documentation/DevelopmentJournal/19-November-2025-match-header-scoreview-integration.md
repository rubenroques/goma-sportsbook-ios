# Development Journal

## Date
19 November 2025

### Project / Branch
sportsbook-ios / rr/match_details_score

### Goals for this session
- Add ScoreView to MatchHeaderCompactView for live matches
- Refactor ScoreViewModel to contain transformation logic (DRY principle)
- Display live scores next to participant names in match details header
- Only show scores for live matches (hidden for pre-match)

### Achievements
- [x] **Phase 1: Refactored ScoreViewModel** - Moved all score transformation logic from TallOddsMatchCardViewModel into ScoreViewModel
  - Added failable convenience initializer `init?(from: Match)`
  - Moved 200+ lines of transformation logic into ScoreViewModel.transformScores()
  - Simplified TallOddsMatchCardViewModel to just call `ScoreViewModel(from: match)`
  - Maintained all existing functionality (tennis layouts, serving indicators, etc.)

- [x] **Phase 2: Added ScoreView to MatchHeaderCompactView (GomaUI)**
  - Added `scoreView` property with lazy initialization
  - Positioned to right of team names, vertically aligned with home/away labels
  - Set compression resistance: ScoreView = `.required` (never truncates), team labels = `.defaultLow` (truncate first)
  - Added factory method `createScoreView()`
  - ScoreView hidden by default, shown only when `isLive = true`

- [x] **Updated MatchHeaderCompactViewModelProtocol**
  - Added `scoreViewModel: ScoreViewModelProtocol?` property
  - Added `isLive: Bool` property
  - Implemented custom `Equatable` using identity comparison for protocol (`===`)

- [x] **Updated MockMatchHeaderCompactViewModel**
  - Added three new preset mocks: `liveFootballMatch`, `liveTennisMatch`, `liveLongNames`
  - Mocks demonstrate football scores, tennis game+sets layout, and long name truncation

- [x] **Updated Production MatchHeaderCompactViewModel**
  - Modified `createHeaderData(from:)` to create ScoreViewModel for live matches
  - Added `updateMatch(_ match: Match)` method for live data updates
  - Wired up all existing methods to preserve new properties

- [x] **Wired up live updates in MatchDetailsTextualViewModel**
  - Added `matchHeaderCompactViewModel.updateMatch(match)` call in subscription handler
  - Header now receives Match updates when WebSocket delivers new data

### Issues / Bugs Hit
- **Build Error**: Assumed Match had `liveData` property - actually has direct properties (`detailedScores`, `homeParticipantScore`, etc.)
- **AutoLayout Ambiguity**: Xcode View Debugger showed "Width and horizontal position are ambiguous" for ScoreView
  - Caused by `greaterThanOrEqualTo` constraint combined with hidden/empty view
- **Scores Not Appearing**: Even after wiring up `updateMatch()`, scores still don't display in header
  - Green "9th Game (3rd Set)" capsule proves match IS live
  - InPlay list shows scores correctly (same ScoreViewModel logic)
  - Match details header shows no scores → need further debugging

### Key Decisions
- **Chose init over factory methods**: User prefers failable initializers (`init?`) over static factory methods
- **DRY Principle**: Consolidated score transformation logic in ONE place (ScoreViewModel) instead of duplicating across ViewModels
- **Layout Priority**: Scores always visible > team names can truncate (matches user requirement)
- **Identity Comparison**: Used `===` for protocol comparison in Equatable (protocols can't synthesize Equatable)
- **No Java-style imports**: Swift module imports give access to all public types (no `import ServicesProvider.Match` nonsense)

### Experiments & Notes

**Data Flow Discovery:**
```
TallOddsMatchCard (Working ✅):
Init Match → ScoreViewModel(from: match) → Scores display

MatchHeaderCompact (Not Working ❌):
Init Match (no scores) → subscribeEventDetails → updateMatch(match) → ??? → No scores

Why the difference?
- Both use same ScoreViewModel(from: match)
- InPlay list works perfectly
- Match details subscription receives updates (proven by navigation bar capsule)
- updateMatch() is being called
- Need to verify ScoreViewModel(from: match) is returning non-nil
```

**AutoLayout Constraint Pattern:**
```swift
// ScoreView positioned to right of teams, aligned vertically
scoreView.topAnchor.constraint(equalTo: homeTeamLabel.topAnchor)
scoreView.bottomAnchor.constraint(equalTo: awayTeamLabel.bottomAnchor)
scoreView.trailingAnchor.constraint(equalTo: leftContentView.trailingAnchor)
scoreView.leadingAnchor.constraint(greaterThanOrEqualTo: teamsStackView.trailingAnchor, constant: 8)

// Compression priorities ensure scores never truncate
scoreView.setContentCompressionResistancePriority(.required, for: .horizontal)
homeTeamLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
awayTeamLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
```

**Match Properties (Actual vs Assumed):**
```swift
// ❌ WRONG (what I assumed):
match.liveData?.detailedScores
match.liveData?.activePlayerServing
match.sportId

// ✅ CORRECT (actual Match model):
match.detailedScores
match.activePlayerServing  // Returns Match.ActivePlayerServe (needs mapping)
match.sport.id
match.homeParticipantScore
match.awayParticipantScore
```

### Useful Files / Links

**Modified Files:**
- [ScoreViewModel](BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/ScoreViewModel.swift) - Lines 36-78 (new inits), 100-290 (transformation logic)
- [TallOddsMatchCardViewModel](BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/TallOddsMatchCardViewModel.swift) - Lines 140-146, 293-299 (simplified)
- [MatchHeaderCompactView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderCompactView/MatchHeaderCompactView.swift) - Lines 14, 81-83, 152-156, 178-184, 205-209, 326-332
- [MatchHeaderCompactViewModelProtocol](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderCompactView/MatchHeaderCompactViewModelProtocol.swift) - Lines 17-18, 32-33, 46-47, 50-64
- [MockMatchHeaderCompactViewModel](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderCompactView/MockMatchHeaderCompactViewModel.swift) - Lines 39-40, 123-237
- [MatchHeaderCompactViewModel](BetssonCameroonApp/App/ViewModels/MatchHeaderCompact/MatchHeaderCompactViewModel.swift) - Lines 57-58, 92-96, 110-111, 121-125, 138-139, 161-162
- [MatchDetailsTextualViewModel](BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsTextualViewModel.swift) - Lines 163-164

**Reference Files:**
- [Previous EveryMatrix Fix Journal](Documentation/DevelopmentJournal/19-November-2025-everymatrix-live-data-fix.md)
- [TallOddsMatchCard Reference](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TallOddsMatchCardView/TallOddsMatchCardView.swift) - Lines 268-326 (layout pattern)
- [ScoreView Component](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreView.swift)

### Next Steps

**Immediate Debug Actions:**
1. Add debug logging to `MatchHeaderCompactViewModel.createHeaderData()`:
   ```swift
   print("[MATCH_HEADER_DEBUG] Creating header for: \(match.homeParticipant.name) vs \(match.awayParticipant.name)")
   print("[MATCH_HEADER_DEBUG]    isLive: \(isLive)")
   print("[MATCH_HEADER_DEBUG]    detailedScores: \(match.detailedScores?.count ?? 0)")
   print("[MATCH_HEADER_DEBUG]    homeScore: \(match.homeParticipantScore?.description ?? "nil")")
   print("[MATCH_HEADER_DEBUG]    scoreViewModel created: \(scoreViewModel != nil)")
   ```

2. Verify `ScoreViewModel(from: match)` is returning non-nil
3. Check if `updateMatch()` is actually being called (add print statement)
4. Compare Match object in InPlay vs Match Details (same data?)

**Potential Root Causes:**
- `match.detailedScores` might be nil/empty in Match Details context
- Match object might be different between InPlay and Details subscriptions
- Timing issue: updateMatch() called before scores available?
- ScoreViewModel failable init returning nil for some reason

**Architecture Improvements:**
- Consider adding debug mode to ScoreViewModel that logs why init returns nil
- Add visual indicator in Xcode View Debugger for hidden vs empty views
- Document the Match update flow in architecture docs

### Remaining Questions
- Why does InPlay show scores but Match Details doesn't (same ScoreViewModel code)?
- Does `subscribeEventDetails` return Match with same score data as InPlay subscription?
- Is there a timing issue where header updates before scores arrive?
- Should we add retry logic or delayed score check?
