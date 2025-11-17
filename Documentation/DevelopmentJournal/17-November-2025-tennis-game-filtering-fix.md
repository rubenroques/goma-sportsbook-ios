# Development Journal

## Date
17 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix tennis matches showing ALL game scores instead of only the active game
- Investigate why dozens of completed games from all sets were appearing in UI
- Achieve web app parity with tennis EVENT_INFO filtering logic

### Achievements
- [x] Identified root cause: `isSet()` pattern matcher had false positives for game entries
- [x] Analyzed EveryMatrix EVENT_INFO data structure and statusId filtering requirements
- [x] Reviewed web app implementation (eventInfoScores.js) for correct filtering approach
- [x] Refactored `EveryMatrixSportPatterns.isSet()` to properly exclude game entries
- [x] Improved architectural encapsulation - logic moved inside pattern matcher
- [x] Updated EventLiveDataBuilder comments to reflect proper abstraction

### Issues / Bugs Hit
- [x] Tennis matches displaying all games from all sets (dozens of entries)
  - **Root cause**: `isSet("4th Game (2nd Set)")` returned `true` because regex matched "2nd Set"
  - **Impact**: Completed games with statusId "4" bypassed the active-only filtering
  - **Solution**: Added `!contains("game")` check inside `isSet()` function

### Key Decisions
- **Architectural Choice**: Moved filtering logic INSIDE `isSet()` rather than external check
  - Considered web app pattern (external filter) vs proper encapsulation (internal logic)
  - Chose **Option 1: Internal Logic** for better software engineering
  - Rationale: Single source of truth, proper abstraction, easier testing
  - Trade-off: Slight divergence from web app pattern, but cleaner architecture

- **Pattern Matching Strategy**: Use `contains("game")` to distinguish sets from games
  - Simpler than complex regex patterns
  - Works for all game entry formats: "4th Game (2nd Set)", "1st Game (3rd Set)", etc.
  - Complements existing statusId filtering in game processing

- **Tennis Display Requirements Confirmed**:
  - Show ALL sets (active + completed) - tennis viewers want set history
  - Show ONLY active game (statusId "1") - current points like "40-15"
  - Filter dozens of completed games (statusId "4") from previous sets

### Experiments & Notes
- **Web App Analysis**: Reviewed `/Users/rroques/Desktop/GOMA/CoreMasterAggregator/web-app/docs/eventInfos/`
  - BUSINESS_LOGIC.md explains Tennis Game Filtering rules
  - TEMPLATES.md details DETAILED template (Tennis-specific)
  - EveryMatrix-Score-API-Findings.md confirms statusId values ("1" = active, "4" = completed)
  - eventInfoScores.js line 138: `const isGameNotSet = partName.toLowerCase().includes('game')`

- **Pattern Matching Deep Dive**:
  ```
  Before Fix:
  isSet("1st Set") → true ✓
  isSet("4th Game (2nd Set)") → true ✗ WRONG (matched "2nd Set")

  After Fix:
  isSet("1st Set") → true ✓
  isSet("4th Game (2nd Set)") → false ✓ (contains "game")
  ```

- **Two-Stage Filtering System**:
  - Stage 1 (Set filtering): Accept all sets, no statusId check needed
  - Stage 2 (Game filtering): Only active games with statusId "1"
  - Both stages necessary - solve different problems

### Useful Files / Links
- [EventLiveDataBuilder.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/EventLiveDataBuilder.swift) - DETAILED template score processing
- [EveryMatrixSportPatterns.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/EveryMatrixSportPatterns.swift) - Pattern matching utilities (isSet, isGame, etc.)
- [Web App EventInfo Docs](/Users/rroques/Desktop/GOMA/CoreMasterAggregator/web-app/docs/eventInfos/) - Reference implementation
- [16-November-2025-eventinfo-web-parity-implementation.md](./16-November-2025-eventinfo-web-parity-implementation.md) - Previous session establishing EventLiveDataBuilder
- [Development Journal: 17-November-2025-sse-zombie-connections-reconnection-fix.md](./17-November-2025-sse-zombie-connections-reconnection-fix.md) - Parallel session work

### Code Changes Summary

**File 1: `EveryMatrixSportPatterns.swift`** (lines 121-130)
- Refactored `isSet()` function to encapsulate game exclusion logic
- Added pattern match check + game entry exclusion in single function
- Improved documentation explaining exclusion rationale

**File 2: `EventLiveDataBuilder.swift`** (lines 323-330)
- Removed external `!contains("game")` check (now inside `isSet()`)
- Simplified set filtering to clean `if isSet()` call
- Updated comments to reflect proper abstraction

**Lines Changed**: ~10 lines modified across 2 files
**Architecture Improvement**: Leaky abstraction fixed, proper encapsulation achieved

### Technical Details

**EveryMatrix EVENT_INFO Structure for Tennis**:
```
Whole Match: Sets won (statusId varies)
1st Set: Games won (statusId "4" when completed)
2nd Set: Games won (statusId "4" when completed)
3rd Set: Games won (statusId "1" when active)
4th Game (1st Set): Points (statusId "4" - completed)
5th Game (1st Set): Points (statusId "4" - completed)
...dozens more completed games...
7th Game (3rd Set): Points (statusId "1" - active) ← ONLY THIS ONE SHOWN
```

**Pattern Matcher Behavior**:
- `isSet()` now properly returns false for game entries
- `isGame()` pattern still matches game entries correctly
- `statusId == "1"` filter in game processing removes completed games
- Result: Only ONE active game displayed

### Next Steps
1. ✅ **Test with live tennis match** - Verify only one game score appears in UI
2. ✅ **Check `[LIVE_SCORE]` logs** - Confirm game entries process correctly (not as sets)
3. **Run full regression** - Ensure other sports (Basketball, Volleyball with sets) unaffected
4. **Monitor production** - Watch for any edge cases in tennis game naming
5. **Update CLAUDE.md** - Document pattern matcher encapsulation principle if needed

### Testing Verification Checklist
- [ ] Live tennis match shows only ONE game score (e.g., "40-15")
- [ ] All sets display correctly ("1st Set", "2nd Set", "3rd Set")
- [ ] No game entries like "4th Game (2nd Set)" appear in sets list
- [ ] Logs show game entries filtered by statusId, not misclassified as sets
- [ ] Volleyball/Table Tennis/Badminton still work (use SIMPLE template with sets)
- [ ] Basketball quarters unaffected (different pattern)

---

## Session Notes

**Duration**: ~2 hours (investigation + implementation + architectural discussion)

**Debugging Approach**:
1. User reported: "Tennis showing all games from all sets"
2. Initial hypothesis: `isGame()` regex pattern too narrow
3. Read web app docs - discovered external filter pattern
4. Traced iOS code flow - found set filtering captured games first
5. Architectural discussion - internal vs external filtering
6. Implemented cleaner solution with proper encapsulation

**Key Insight**: The bug wasn't in the game filtering logic (statusId check was correct). The bug was that game entries never reached that check because they were misclassified as sets in an earlier stage. Fixing the pattern matcher prevented the misclassification, allowing the existing statusId filter to work correctly.

**Web App Parity Note**: We diverged slightly from web app implementation for better architecture. Web app uses external filter, iOS now uses internal filter. Both achieve same result, but iOS has cleaner encapsulation.
