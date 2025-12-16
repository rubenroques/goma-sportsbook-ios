## Date
16 December 2025

### Project / Branch
sportsbook-ios / rr/cashout_fixes

### Goals for this session
- Wire SSE subscription to TicketBetInfoViewModel (Phase 4.4)
- Enable real-time cashout value updates as odds change
- Recalculate displayed partial cashout amount when SSE delivers new values

### Achievements
- [x] Added `subscribeToCashoutValue(betId:)` wrapper to `ServicesProvider.Client`
- [x] Added `sseSubscription: AnyCancellable?` property to `TicketBetInfoViewModel`
- [x] Implemented `subscribeToCashoutUpdates()` method with SSE connection handling
- [x] Implemented `handleCashoutUpdate(_ cashoutValue:)` to update `fullCashoutValue` and recalculate display
- [x] Added `deinit` to properly cancel SSE subscription
- [x] SSE subscription starts automatically when `myBet.canCashOut == true`
- [x] Build verified: BetssonCM UAT compiles successfully

### Issues / Bugs Hit
- [x] `GomaLogger` not in scope → Replaced with `print()` statements (consistent with existing file pattern)
- [x] `subscribeToCashoutValue` not available on `ServicesProvider.Client` → Added wrapper method

### Key Decisions
- **Wrapper method in Client.swift** - Added public wrapper to expose `bettingProvider.subscribeToCashoutValue` since `bettingProvider` is private
- **Subscription lifecycle** - SSE subscribes in `init` if cashout available, cancels in `deinit`
- **Reactive recalculation** - When SSE updates `fullCashoutValue`, partial cashout is recalculated using current slider position

### Experiments & Notes
- SSE returns `SubscribableContent<CashoutValue>` with cases: `.connected`, `.contentUpdate(CashoutValue)`, `.disconnected`
- `CashoutValue.cashoutValue` is `Double?` - nil when code 103 (loading state)
- Filtering logic (code 100 only, CASHOUT_VALUE message type) already implemented in `EveryMatrixBettingProvider`

### Useful Files / Links
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Added wrapper method
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift) - SSE subscription
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift) - SSE implementation
- [BettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/BettingProvider.swift) - Protocol definition
- [Previous session: Slider wiring](./16-December-2025-cashout-slider-wiring.md)

### Next Steps
1. Implement cashout state machine (Phase 4.6)
   - States: slider → loading → success/failed
   - Wire to `executeCashout` API
   - Handle full vs partial cashout execution
2. Test end-to-end with real bet using PROD credentials
3. Add UI feedback for loading/error states
