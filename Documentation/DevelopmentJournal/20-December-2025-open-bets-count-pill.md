## Date
20 December 2025

### Project / Branch
BetssonCameroonApp / rr/cashout_fixes

### Goals for this session
- Add open bets count to the "Open" pill in MyBets status bar (matching web-app behavior)
- Verify API response structure to confirm no `totalCount` field exists
- Implement dynamic pill title updates: "Open (5)" format

### Achievements
- [x] Verified API response structure on both STG and PROD environments
  - STG: `https://sports-api-stage.everymatrix.com/bets-api/v1/4093/open-bets` → returns bare array `[]`
  - PROD: `https://sports-api.everymatrix.com/bets-api/v1/4374/open-bets` → returns bare array `[{...}, ...]`
  - Confirmed: No `totalCount`, `total`, `pagination`, or `meta` wrapper fields
- [x] Added `title(withCount:)` helper method to `MyBetStatusType` enum
- [x] Implemented `updatePill()` method in `MyBetsStatusBarViewModel` (was previously a no-op stub)
- [x] Added `updateOpenBetsCount(_ count: Int?)` convenience method to `MyBetsStatusBarViewModel`
- [x] Added reactive binding in `MyBetsViewModel.setupBindings()` to update pill count on bets load
- [x] Updated status change handler to reset count when switching away from "Open" tab

### Issues / Bugs Hit
- None encountered during implementation

### Key Decisions
- **Use loaded bets count (`array.count`)** instead of API total - matches web-app behavior and API returns bare arrays
- **Only "Open" pill shows count** - other tabs (CashOut, Won, Settled) do not display counts per requirements
- **Show count only when > 0** - displays plain "Open" when no bets (not "Open (0)")
- **Reset count when switching tabs** - prevents stale counts from persisting

### Experiments & Notes
- Explored `PillSelectorBarViewModelProtocol` - already had `updatePill()` method in protocol but implementation was stubbed
- `MyBetsStatusBarViewModel` follows the pattern from `TransactionTypePillSelectorViewModel` for pill updates
- Reactive binding approach ensures automatic count updates on:
  - Initial bets load
  - Pull-to-refresh
  - Cashout completion (both full and partial)
  - User logout (resets to empty)

### Useful Files / Links
- [MyBetStatusType.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetStatusType.swift) - Added `title(withCount:)` method
- [MyBetsStatusBarViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/MyBetsStatusBarViewModel.swift) - Implemented `updatePill()` and `updateOpenBetsCount()`
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift) - Added reactive bindings in `setupBindings()`
- [PillSelectorBarViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/PillSelectorBarView/PillSelectorBarViewModelProtocol.swift) - Protocol reference

### Next Steps
1. Build and verify implementation compiles
2. Test in simulator:
   - Verify "Open (X)" displays correctly with open bets
   - Verify count updates on refresh
   - Verify count decrements after cashout
   - Verify plain "Open" when switching back with 0 bets
3. Test edge cases: logout/login flow, empty state

---

## REVERTED - 23 December 2025

**Reason**: Jira issue was picked up by another team member. Feature was reverted to avoid duplicate implementations.

**Backup branch**: `rr/backup-open-bets-count-feature` (contains full implementation)

### Files Reverted
1. **MyBetStatusType.swift** - Removed `title(withCount:)` method
2. **MyBetsStatusBarViewModel.swift** - Reverted `updatePill()` to stub, removed `updateOpenBetsCount()` method
3. **MyBetsViewModel.swift** - Removed reactive bindings for pill count updates

### To Restore
```bash
# Option 1: Cherry-pick from backup branch
git cherry-pick rr/backup-open-bets-count-feature

# Option 2: View the original implementation
git show rr/backup-open-bets-count-feature:BetssonCameroonApp/App/Screens/MyBets/MyBetStatusType.swift
git show rr/backup-open-bets-count-feature:BetssonCameroonApp/App/Screens/MyBets/ViewModels/MyBetsStatusBarViewModel.swift
git show rr/backup-open-bets-count-feature:BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift
```
