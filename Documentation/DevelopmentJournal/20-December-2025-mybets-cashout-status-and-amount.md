## Date
20 December 2025

### Project / Branch
BetssonCameroonApp / rr/cashout_fixes

### Goals for this session
- Fix missing "Cashed Out" status bar on My Bets → Cash Out tab
- Fix CashoutAmountView to show historical cashout amount (not slider value)
- Improve SSE logging for cashout value updates

### Achievements
- [x] Added `cashedOut` case to `BetTicketStatus` enum in GomaUI
- [x] Implemented rendering logic for cashedOut in `BetTicketStatusView` (light blue `buttonBackgroundSecondary`)
- [x] Added `cashedOutMock()` factory method in `MockBetTicketStatusViewModel`
- [x] Updated `createBetStatus(from:)` in `TicketBetInfoViewModel` to map `MyBetState.cashedOut`
- [x] Fixed exhaustive switch in `TicketSelectionView` - shows "PENDING" (orange) for cashedOut tickets
- [x] Improved SSE error logging to show actual decode error and raw data
- [x] Added PING/heartbeat filter for SSE messages (silent debug log instead of error)
- [x] Created `PartialCashOut` model in BetssonCameroonApp
- [x] Added `partialCashOuts` property to `MyBet` model (partial - init updated)

### Issues / Bugs Hit
- [x] Exhaustive switch errors in `TicketSelectionView` after adding cashedOut enum case
- [x] SSE decoding errors flooding logs - was PING heartbeat messages
- [ ] CashoutAmountView update incomplete - need to finish mapper and ViewModel changes

### Key Decisions
- **Ticket-level vs Selection-level status distinction**:
  - `BetTicketStatusView` (bottom bar): Shows ticket outcome - Won/Lost/Draw/**Cashed Out**
  - `TicketSelectionView` (individual tags): Shows **PENDING** for cashedOut tickets (selections weren't resolved)
- **SSE PING handling**: Filter early with string check, log at debug level (not error)
- **Historical cashout**: Should come from `partialCashOuts` array, sum of `cashOutAmount` values

### Experiments & Notes
- SSE heartbeat format: `{"messageType":"PING","timestamp":"20-12-2025 12:10:22"}`
- ServicesProvider.Bet has `partialCashOuts: [PartialCashOut]?` but wasn't mapped to MyBet
- Total cashed out = `partialCashOuts.compactMap { $0.cashOutAmount }.reduce(0, +)`

### Useful Files / Links
- [BetTicketStatusViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetTicketStatusView/BetTicketStatusViewModelProtocol.swift)
- [BetTicketStatusView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetTicketStatusView/BetTicketStatusView.swift)
- [TicketSelectionView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketSelectionView/TicketSelectionView.swift)
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift)
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift)
- [MyBet.swift](../../BetssonCameroonApp/App/Models/Betting/MyBet.swift)
- [PartialCashOut.swift](../../BetssonCameroonApp/App/Models/Betting/PartialCashOut.swift) (NEW)

### Next Steps
1. Add computed properties to MyBet: `totalCashedOut`, `hasPreviousCashouts`
2. Update `ServiceProviderModelMapper+MyBets.swift` to map `partialCashOuts`
3. Update `TicketBetInfoViewModel.setupCashoutViewModels()` to use historical amount
4. Remove slider → amount binding (should be static)
5. Build and test with actual partial cashout data
