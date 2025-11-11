# MyBets Cashout Tab Parity Fix

## Date
11 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Investigate MyBets Cashout Tab parity gap between iOS and Web
- Implement server-side filtering for cashed-out bets
- Add `getCashedOutBetsHistory()` to BettingProvider protocol chain
- Fix MyBetsViewModel to use correct API endpoint

### Achievements
- [x] Verified 100% accuracy of parity gap documentation
- [x] Added `getCashedOutBetsHistory()` to BettingProvider protocol (line 19)
- [x] Implemented method in EveryMatrixBettingProvider (lines 102-116)
- [x] Implemented stub in GomaProvider (lines 1409-1411) - returns `notSupportedForProvider`
- [x] Implemented stub in SportRadarBettingProvider (lines 107-109) - returns `notSupportedForProvider`
- [x] Exposed public API in Client.swift (lines 1439-1447)
- [x] Fixed MyBetsViewModel `.cashOut` case (line 275) - now calls `getCashedOutBetsHistory()`
- [x] Removed misleading TODO comment from MyBetsViewModel

### Issues / Bugs Hit
- [x] Initial build attempt failed - forgot GomaProvider and SportRadarBettingProvider also need to implement protocol
- Resolution: Added stub implementations returning `notSupportedForProvider` error

### Key Decisions

**1. Server-Side Filtering Strategy**
- **Decision**: Use `/settled-bets?betStatus=CASHED_OUT` endpoint (existing API)
- **Rationale**: API already supports filtering - no need for client-side filtering
- **Alternative Rejected**: Client-side filtering would be inefficient and inconsistent with other tabs

**2. Multi-Provider Support**
- **Decision**: Only EveryMatrix implements full functionality; Goma and SportRadar return `notSupportedForProvider`
- **Rationale**:
  - Only EveryMatrix backend confirmed to support cashout history filtering
  - Consistent with protocol pattern - providers declare unsupported features explicitly
  - Prevents build errors while allowing future implementation

**3. Implementation Pattern**
- **Decision**: Follow exact pattern from `getWonBetsHistory()` (copy-paste-modify approach)
- **Rationale**:
  - Both use same `/settled-bets` endpoint with different `betStatus` parameter
  - Proven stable pattern used 3 times already (open, resolved, won)
  - Zero risk of architectural deviation

### Implementation Details

#### API Endpoint Used
```
GET /bets-api/v1/{operatorId}/settled-bets
Query Parameters:
  - limit: 20
  - placedBefore: {ISO8601 date}
  - betStatus: "CASHED_OUT"
```

#### Model Mapping Chain (EveryMatrix)
```
REST API Response
    ↓
[EveryMatrix.Bet] (internal model, already hierarchical)
    ↓
EveryMatrixModelMapper.bettingHistory(fromBets:)
    ↓
BettingHistory (domain model)
```

No DTO layer needed - REST API returns complete hierarchical data.

#### Code Changes Summary

| File | Lines | Change |
|------|-------|--------|
| `BettingProvider.swift` | 19 | Added protocol method |
| `EveryMatrixBettingProvider.swift` | 102-116 | Implemented with `betStatus: "CASHED_OUT"` |
| `GomaProvider.swift` | 1409-1411 | Stub returning `notSupportedForProvider` |
| `SportRadarBettingProvider.swift` | 107-109 | Stub returning `notSupportedForProvider` |
| `Client.swift` | 1439-1447 | Public API wrapper |
| `MyBetsViewModel.swift` | 274-275 | Fixed to call new method, removed TODO |

### Experiments & Notes

**Investigation Findings:**
- Original developer left cashout tab incomplete intentionally (deferred feature)
- TODO comment was misleading - API has always supported the feature
- Evidence found in `EveryMatrixModelMapper+MyBets.swift:119` proving `"CASHED_OUT"` status exists
- Development journal from 28-August-2025 confirms cashout was "waiting for API support"

**Complexity Assessment:**
- Estimated difficulty: 1/5 stars (trivial)
- Actual time: ~15 minutes of implementation
- Why simple: Exact pattern exists 3 times, zero new endpoints, zero model changes

**Documentation Quality:**
- External documentation was 100% accurate (rare!)
- All file paths, line numbers, and code patterns verified
- Parity gap analysis was thorough and correct

### Useful Files / Links

**Modified Files:**
- [BettingProvider Protocol](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/BettingProvider.swift)
- [EveryMatrixBettingProvider](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift)
- [GomaProvider](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/GomaProvider.swift)
- [SportRadarBettingProvider](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarBettingProvider.swift)
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift)
- [MyBetsViewModel](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift)

**Reference Documentation:**
- [Parity Gap Analysis](/Users/rroques/Desktop/GOMA/CoreMasterAggregator/Documentation/PARITY_GAP_MyBets_Cashout_Tab.md)
- [Fix Implementation Prompt](/Users/rroques/Desktop/GOMA/CoreMasterAggregator/Documentation/Prompts/fix_ios_mybets_cashout_tab_parity.md)
- [EveryMatrix Provider CLAUDE.md](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md)

**Related Code:**
- Pattern Reference: `getWonBetsHistory()` at EveryMatrixBettingProvider.swift:86-100
- API Endpoint Definition: `EveryMatrixOddsMatrixWebAPI.swift:10` (`getSettledBets`)
- Status Mapper: `EveryMatrixModelMapper+MyBets.swift:119` (proves `"CASHED_OUT"` status exists)

### Next Steps

**Immediate (This Session):**
1. Build ServicesProvider framework to verify no compilation errors
2. Build BetssonCameroonApp to verify integration
3. Runtime test in simulator:
   - Verify Open tab shows pending bets
   - Verify Cashout tab shows ONLY cashed-out bets (not duplicates)
   - Verify Won and Settled tabs unchanged
   - Test empty cashout tab (user never cashed out)
   - Test pagination in cashout tab

**Future Considerations:**
1. Consider implementing cashout history in Goma/SportRadar providers if their APIs support it
2. Add analytics tracking for cashout tab usage
3. Consider adding "empty state" messaging if user has no cashout history

**Testing Checklist:**
- [ ] ServicesProvider builds successfully
- [ ] BetssonCameroonApp builds successfully
- [ ] Cashout tab shows only cashed-out bets
- [ ] No duplication between Open and Cashout tabs
- [ ] Empty cashout tab handles gracefully
- [ ] Pagination works correctly
- [ ] Tab switching is smooth

---

## Technical Notes

### Why This Bug Happened

**Root Cause:** Developer misunderstanding of tab semantics
- **Misinterpretation**: "Cashout" = "Bets I **can** cash out now" (future action)
- **Actual Meaning**: "Cashout" = "Bets I **already** cashed out" (historical record)

**Contributing Factors:**
1. TODO comment suggested API didn't support filtering (incorrect assumption)
2. API mapper already handled `"CASHED_OUT"` status - feature existed all along
3. No cross-platform parity check during initial implementation

### Architecture Lessons

**What Went Well:**
- Protocol-driven design made adding new method straightforward
- Existing pattern (`getWonBetsHistory`) provided perfect template
- Multi-provider architecture gracefully handles unsupported features

**Process Improvements:**
- Always check web implementation for parity before assuming missing features
- Verify API capabilities before adding TODO comments about "when API supports it"
- Cross-reference mappers to confirm what status values backend actually returns

### Code Quality Notes

**Positive Patterns Observed:**
- Consistent naming: `get[Status]BetsHistory()` pattern
- Uniform error handling: `notSupportedForProvider` for stubs
- Clean separation: Protocol → Provider → Client → ViewModel
- Mapper reuse: Same `bettingHistory(fromBets:)` mapper works for all statuses

**No Technical Debt Introduced:**
- Zero duplication (reused existing mapper)
- Zero new API endpoints (used existing with different parameter)
- Zero architectural changes (followed established pattern)
- Zero UI changes (purely backend logic fix)

---

## Session Metadata

**Session Duration:** ~30 minutes
**Complexity:** Low (straightforward protocol implementation)
**Risk Level:** Low (follows proven pattern, no breaking changes)
**Files Modified:** 6 files
**Lines Changed:** ~35 lines added
**Build Status:** Pending verification (interrupted by documentation request)
