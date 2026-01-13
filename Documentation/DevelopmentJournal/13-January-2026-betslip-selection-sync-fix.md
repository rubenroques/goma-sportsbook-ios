## Date
13 January 2026

### Project / Branch
sportsbook-ios / rr/gomaui_snapshot_test

### Goals for this session
- Investigate bug where removing selection from betslip (via delete button) leaves outcome visually "selected" after closing betslip
- Determine why this bug appeared after migrating from TallOdds cards to InlineMatch cards

### Achievements
- [x] Root cause identified: stale data check in `updateSelectionStates()`
- [x] Fixed `CompactOutcomesLineViewModel.updateSelectionStates()` - removed buggy optimization
- [x] Fixed `MarketOutcomesLineViewModel.updateSelectionStates()` for consistency

### Issues / Bugs Hit
- **Selection state not syncing on external betslip removal**
  - Bug location: `CompactOutcomesLineViewModel.updateSelectionStates()` lines 102-131
  - The method checked `leftOutcome.isSelected` from `displayStateSubject` before calling `setSelected()`
  - Problem: `createOutcomeData()` always sets `isSelected: false` - this value is NEVER updated
  - When removing from betslip: `false != false` → skip `setSelected(false)` → UI stays selected

### Key Decisions
- **Removed the "optimization" check entirely** - the check `if leftOutcome.isSelected != shouldBeSelected` was comparing against stale data
- **Always call `setSelected()` unconditionally** - it's idempotent (just sends to CurrentValueSubject), no performance concern
- **Fixed both ViewModels for consistency** - even though TallOdds doesn't currently use betslip subscription

### Experiments & Notes
- TallOdds didn't have this bug because `TallOddsMatchCardViewModel` has **NO betslip subscription** at all
- The betslip observation feature (`bettingTicketsPublisher` subscription) was only added to `InlineMatchCardViewModel`
- The bug was introduced when implementing the betslip sync feature for inline cards

### Bug Flow (for reference)
```
1. User taps outcome → OutcomeItemViewModel.isSelectedSubject = true (UI shows selected)
2. User opens betslip, taps delete (X) on the selection
3. bettingTicketsPublisher fires with updated set (without removed ticket)
4. updateSelectionStates(selectedOfferIds: newSet) is called
5. Check: leftOutcome.isSelected (false) != shouldBeSelected (false) → FALSE
6. setSelected(false) is SKIPPED
7. OutcomeItemViewModel.isSelectedSubject remains true → UI still shows selected
```

### Useful Files / Links
- [CompactOutcomesLineViewModel.swift](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/CompactOutcomesLineViewModel.swift) - Primary fix location
- [MarketOutcomesLineViewModel.swift](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/MarketOutcomesLineViewModel.swift) - Consistency fix
- [InlineMatchCardViewModel.swift](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/InlineMatchCardViewModel.swift) - Betslip subscription setup
- [21-December-2025-inline-match-card-betslip-fix.md](./21-December-2025-inline-match-card-betslip-fix.md) - Original betslip integration fix

### Next Steps
1. Build and verify fix with manual testing
2. Test scenario: select outcome → open betslip → delete → close betslip → verify deselected
3. Consider adding unit test for `updateSelectionStates()` to prevent regression
