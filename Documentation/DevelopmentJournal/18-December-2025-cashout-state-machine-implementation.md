## Date
18 December 2025

### Project / Branch
sportsbook-ios / rr/cashout_fixes

### Goals for this session
- Implement Phase 4.6: Cashout state machine and execution
- Add loading overlay for cashout in progress
- Wire error alerts with retry functionality
- Handle full vs partial cashout outcomes

### Achievements
- [x] Added `executeCashout(request:)` wrapper to `Client.swift`
- [x] Created `CashoutExecutionState.swift` enum with states: idle, loading, fullCashoutSuccess, partialCashoutSuccess, failed
- [x] Updated `TicketBetInfoViewModel` with full state machine implementation:
  - State managed via `CurrentValueSubject<CashoutExecutionState, Never>`
  - `handleCashoutRequest` now creates `CashoutRequest` and executes via API
  - `handleCashoutSuccess` distinguishes full vs partial cashout
  - `handleCashoutFailure` triggers error callback with retry action
  - Added `retryCashout()` and `cancelCashout()` methods
- [x] Deleted dead code (old `executeCashout()` and `handleCashoutConfirmation()` methods)
- [x] Extended `TicketBetInfoViewModelProtocol` with `isCashoutLoading` and `isCashoutLoadingPublisher`
- [x] Added loading overlay to `TicketBetInfoView` (dims card + spinner)
- [x] Updated `MyBetsViewModel` with:
  - `onShowCashoutError` callback for alert presentation
  - `onCashoutCompleted` and `onCashoutError` callback wiring
  - `handleCashoutCompleted` method for full/partial handling
- [x] Added `showCashoutErrorAlert` to `MyBetsViewController` with Retry/Cancel buttons
- [x] Updated `MockTicketBetInfoViewModel` with loading state properties

### Issues / Bugs Hit
- [x] Compile error: `Cannot use mutating member on immutable value` in `handleCashoutCompleted`
  - Root cause: `BetListData.viewModels` is a `let` constant
  - Fix: Used `filter` to create new array instead of `removeAll`

### Key Decisions
- **Loading UI**: Full card overlay with dimmed background + spinner (better UX than web's simple disabled button)
- **Error handling**: UIAlertController with Retry/Cancel buttons (native iOS pattern)
- **State machine location**: Kept `CashoutExecutionState` in BetssonCameroonApp, exposed simpler `isCashoutLoading` bool to GomaUI
- **Full cashout**: Filter bet from local list immediately (no API call needed)
- **Partial cashout**: Reload bets via `loadBets(forced: true)` to get updated server data

### Experiments & Notes
- Compared iOS implementation with web (Vue.js) - iOS now ahead:
  - iOS uses new SSE endpoint (web still on deprecated 503 endpoint)
  - iOS has ViewModel caching (prevents SSE reconnection on scroll)
  - iOS loading overlay provides better visual feedback
- State machine follows web pattern: `slider → loading → success/failed`
- Slider formula identical to web: `(fullCashoutValue × sliderStake) / remainingStake`

### Useful Files / Links
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Line 2079-2087
- [CashoutExecutionState.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/CashoutExecutionState.swift) - NEW
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift) - Lines 303-381
- [TicketBetInfoViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/TicketBetInfoViewModelProtocol.swift) - Lines 63-67
- [TicketBetInfoView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/TicketBetInfoView.swift) - Loading overlay
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift) - Lines 398-408, 618-644
- [MyBetsViewController.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewController.swift) - Lines 314-317, 425-448
- [MockTicketBetInfoViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/MockTicketBetInfoViewModel.swift) - Lines 27-36
- [Previous session: State machine planning](./17-December-2025-cashout-state-machine-planning.md)
- [Web comparison: useMyBets.js](../../../CoreMasterAggregator/web-app/src/composables/myBets/useMyBets.js)

### Next Steps
1. Build and verify both GomaUICatalog and BetssonCM UAT schemes
2. Test end-to-end with real bet using PROD credentials
3. Add localization keys if missing: `cashout_error`, `retry`, `cancel`
4. Consider adding success toast/banner for cashout completion
