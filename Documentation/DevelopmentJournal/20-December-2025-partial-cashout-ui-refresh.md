## Date
20 December 2025

### Project / Branch
BetssonCameroonApp / rr/cashout_fixes

### Goals for this session
- Fix partial cashout UI not refreshing after successful cashout
- User sees stale slider values and bet info after partial cashout success

### Achievements
- [x] Added `updateBounds(newMaximumValue:resetToPercentage:)` method to `CashoutSliderViewModel`
- [x] Modified `handleCashoutSuccess()` in `TicketBetInfoViewModel` to update UI immediately after partial cashout:
  - Updates internal `remainingStake` tracking
  - Updates slider bounds with new remaining stake (resets to 80%)
  - Updates amount ViewModel with cumulative cashed out total
  - Creates amount ViewModel if first partial cashout
- [x] Fixed error alert cancel action not resetting state machine:
  - Extended `onCashoutError` callback to include cancel action parameter
  - `handleCashoutFailure` now passes `cancelCashout()` as cancel action
  - State properly resets to `.idle` when user cancels error alert

### Issues / Bugs Hit
- [x] After cashout error + cancel, button was unresponsive (state stuck in `.failed`)
- [ ] 409 Conflict errors from server (server-side, not related to UI changes)

### Key Decisions
- **Immediate local updates**: UI updates locally first, then background API sync via `loadBets(forced: true)`
- **80% slider reset**: After partial cashout, slider resets to 80% of new remaining stake (consistent with initial setup)
- **Cancel action fix**: Extended callback signature to properly wire cancel action to `cancelCashout()`

### Experiments & Notes
- Root cause: `handleCashoutSuccess` calculated new remaining stake but never applied it to slider/amount ViewModels
- `myBet` is immutable (`let`), so we track `remainingStake` separately in ViewModel
- State machine guard `guard case .idle = cashoutStateSubject.value` was blocking new attempts after error+cancel

### Useful Files / Links
- [CashoutSliderViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/CashoutSliderViewModel.swift) - Added `updateBounds` method
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift) - Modified `handleCashoutSuccess` and `handleCashoutFailure`
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift) - Updated error callback wiring
- [Previous session: cashout-amount-view-fix](./20-December-2025-cashout-amount-view-fix.md)
- [Root cause analysis](./19-December-2025-cashout-root-cause-analysis.md)

### Next Steps
1. Test partial cashout flow end-to-end (success case)
2. Verify slider bounds update correctly with new remaining stake
3. Verify amount view shows cumulative cashed out total
4. Handle 409 Conflict errors with better user messaging (server-side race condition)
