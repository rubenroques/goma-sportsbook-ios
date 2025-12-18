## Date
17 December 2025

### Project / Branch
sportsbook-ios / rr/cashout_fixes

### Goals for this session
- Plan Phase 4.6: Cashout state machine and execution
- Design loading overlay, error handling, and retry flow
- Understand the cashout execution API and integration points

### Achievements
- [x] Explored cashout execution flow in codebase
- [x] Discovered `executeCashout(request:)` exists on BettingProvider but not Client wrapper
- [x] Identified that current `handleCashoutRequest` just calls callback without executing
- [x] Designed comprehensive state machine: `idle → loading → success/failed`
- [x] Planned loading overlay for TicketBetInfoView (dim entire card)
- [x] Planned error alert with Retry/Cancel buttons
- [x] Created detailed implementation plan for 8 files
- [x] User approved the plan

### Issues / Bugs Hit
- None (planning session only)

### Key Decisions
- **Loading UI**: Disable entire card with dimmed overlay + spinner (user choice)
- **Error handling**: Alert dialog with Retry/Cancel buttons (user choice)
- **State enum location**: Keep `CashoutExecutionState` in BetssonCameroonApp, expose simpler `isCashoutLoading` bool to GomaUI
- **API choice**: Use `executeCashout(request: CashoutRequest)` which returns `CashoutResponse` with full/partial distinction
- **Full cashout**: Remove bet from list via `viewModelCache.invalidate(forBetId:)`
- **Partial cashout**: Reload bets to get updated data, reset to idle state

### Experiments & Notes
- Current `executeCashout()` and `handleCashoutConfirmation()` in TicketBetInfoViewModel are unused - will be replaced
- `CashoutRequest` model already exists with `CashoutType.full` and `.partial` enums
- `CashoutResponse` has `isFullCashout` and `isPartialCashout` computed properties
- Cache invalidation already implemented in Phase 4.2-4.3

### Useful Files / Links
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift)
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift)
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift)
- [CashoutRequest.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Cashout/CashoutRequest.swift)
- [CashoutResponse.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Cashout/CashoutResponse.swift)
- [Plan File](~/.claude/plans/wiggly-rolling-spindle.md)
- [Previous session: SSE subscription](./16-December-2025-cashout-sse-subscription.md)

### Next Steps
1. Implement Phase 4.6 following the approved plan:
   - Step 1: Add `executeCashout` wrapper to Client.swift
   - Step 2: Create `CashoutExecutionState.swift` enum
   - Step 3: Update TicketBetInfoViewModel with state machine
   - Step 4: Update GomaUI protocol with loading flag
   - Step 5: Add loading overlay to TicketBetInfoView
   - Step 6: Update MyBetsViewModel with completion handlers
   - Step 7: Add error alert to MyBetsViewController
   - Step 8: Update mock for previews
2. Build and verify
3. Test end-to-end with real bet
