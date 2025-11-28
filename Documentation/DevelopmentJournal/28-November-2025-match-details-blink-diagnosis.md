## Date
28 November 2025

### Project / Branch
sportsbook-ios / rr/bugfix/match_detail_blinks

### Goals for this session
- Fix real-time odds updates not reaching match details textual screen
- Diagnose and fix excessive UI re-rendering ("disco effect") in match details

### Achievements
- [x] Fixed `subscribeToBettingOfferAsOutcomeUpdates()` in MatchDetailsManager to search all stores (main + market group stores)
- [x] Added `findStoreContainingBettingOffer()` helper method
- [x] Simplified `bettingOfferExists()` to use the new helper
- [x] Added diagnostic logging (BLINK_SOURCE) in `handleMarketGroupDetailsContent()` to trace WebSocket update flow
- [x] Created comprehensive architecture analysis document: `Documentation/MatchDetailsTextual-UpdateFlow-Analysis.md`
- [x] Identified 5 root causes of excessive re-rendering through log analysis

### Issues / Bugs Hit
- [x] Odds updates not reaching UI - **ROOT CAUSE**: `subscribeToBettingOfferAsOutcomeUpdates()` only observed main store, but betting offers are stored in isolated market group stores
- [ ] Excessive re-rendering ("disco effect") - **ROOT CAUSES IDENTIFIED**:
  1. MatchDetailsManager emits on EVENT_INFO changes (not market-related)
  2. `updateMatch()` called 19x for same match ID, clearing everything
  3. ViewController reloads table even when data unchanged
  4. ViewModel forwards identical data to publishers

### Key Decisions
- **Diagnostic-first approach**: Added logging at SOURCE (MatchDetailsManager) to understand update triggers before applying fixes
- **Root cause analysis over symptom hiding**: User preferred identifying why updates fire rather than just adding guards/removeDuplicates
- **Fix order**: Root-first strategy - fix at MatchDetailsManager level before downstream guards

### Experiments & Notes
- Log analysis from `blink.log.txt` (434KB) revealed:
  - 166 UPDATE emissions at source
  - 131 CHANGE(BETTING_OFFER) - legitimate odds updates
  - 23 CHANGE(EVENT_INFO) - score/time updates triggering unnecessary market rebuilds
  - 19 same-match `updateMatch()` calls causing full screen rebuilds
  - 131 `recreateMarketControllers()` calls (should be ~2 for initial load only)
  - 54 "data IDENTICAL but reload triggered" instances

### Useful Files / Links
- [MatchDetailsManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/MatchDetailsManager.swift) - Added store lookup fix + diagnostic logging
- [MatchDetailsTextual-UpdateFlow-Analysis.md](../MatchDetailsTextual-UpdateFlow-Analysis.md) - Full architecture analysis with fix recommendations
- [Previous DJ: Odds updates fix](./26-November-2025-fix-odds-updates-betting-offer-subscription.md) - Related work on live/prelive screens

### Next Steps
1. **Fix #1**: MatchDetailsManager - Skip emission for non-market updates (EVENT_INFO, MATCH-only)
2. **Fix #2**: MatchDetailsTextualViewModel - Guard `updateMatch()` for same match ID
3. **Fix #3**: MarketGroupSelectorTabViewModel - Early return if same match
4. **Fix #4**: MarketsTabSimpleViewController - Only `reloadData()` when `dataChanged == true`
5. **Fix #5**: MarketsTabSimpleViewModel - Add `removeDuplicates()` as safety net
6. Build and verify all changes compile
7. Test with live match to confirm reduced blinking
