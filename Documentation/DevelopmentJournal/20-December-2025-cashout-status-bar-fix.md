## Date
20 December 2025

### Project / Branch
BetssonCameroonApp / rr/cashout_fixes

### Goals for this session
- Fix missing "Cashed Out" status bar on My Bets → Cash Out tab
- Align bet card display with web/design specifications

### Achievements
- [x] Added `cashedOut` case to `BetTicketStatus` enum in GomaUI
- [x] Implemented rendering logic for cashedOut in `BetTicketStatusView` (light blue background)
- [x] Added `cashedOutMock()` factory method in `MockBetTicketStatusViewModel`
- [x] Updated `createBetStatus(from:)` in `TicketBetInfoViewModel` to map `MyBetState.cashedOut` to the new status
- [x] Fixed exhaustive switch errors in `TicketSelectionView`
- [x] Aligned individual selection behavior: show "PENDING" (orange) for cashedOut tickets instead of "CASHED OUT"

### Issues / Bugs Hit
- [x] Initial implementation caused exhaustive switch errors in `TicketSelectionView` - fixed
- [x] Design clarification needed: individual selections shouldn't show "Cashed Out", they should show "PENDING"

### Key Decisions
- **Ticket-level vs Selection-level status distinction**:
  - `BetTicketStatusView` (bottom bar): Shows ticket outcome - Won/Lost/Draw/**Cashed Out**
  - `TicketSelectionView` (individual tags): Shows selection outcome - Won/Lost/Draw/**PENDING** for cashedOut tickets
- **Color choices**:
  - Cashed Out bar: `buttonBackgroundSecondary` (light blue) - per design
  - Pending tag: `alertWarning` (orange) with white text - matches web behavior
- **State vs Result mapping**: Check `myBet.state == .cashedOut` before checking `myBet.result` since state determines cashout action while result determines game outcome

### Experiments & Notes
- Full cashout: Bottom bar shows "Cashed Out", selections show "PENDING" (games weren't resolved)
- Partial cashout: Bet remains active, selections will eventually resolve to won/lost/draw
- Localization keys already exist: `"cashed_out"` and `"pending"` in both EN and FR

### Useful Files / Links
- [BetTicketStatusViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetTicketStatusView/BetTicketStatusViewModelProtocol.swift) - Enum definition
- [BetTicketStatusView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetTicketStatusView/BetTicketStatusView.swift) - Rendering logic
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift) - Status mapping
- [TicketSelectionView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketSelectionView/TicketSelectionView.swift) - Selection tag rendering
- [MyBetState.swift](../../BetssonCameroonApp/App/Models/Betting/MyBetState.swift) - State enum with `isFinished` logic
- [19-December-2025-cashout-root-cause-analysis.md](./19-December-2025-cashout-root-cause-analysis.md) - Previous session context

### Next Steps
1. Build and test on device/simulator
2. Verify correct display on Cash Out tab with real cashed out bets
3. Test partial cashout scenarios to ensure "PENDING" displays correctly
4. Verify localization in French ("Gains CashOut+" for bar, "En attente" for pending)
