## Date
16 December 2025

### Project / Branch
sportsbook-ios / rr/cashout_fixes

### Goals for this session
- Wire cashout slider calculations (Phase 4.5 of cashout feature)
- Replace hardcoded mock ViewModels with real slider/amount ViewModels
- Implement partial cashout calculation formula from Web/Android

### Achievements
- [x] Extended `TicketBetInfoViewModelProtocol` with `cashoutSliderViewModel` and `cashoutAmountViewModel` optional properties
- [x] Updated `TicketBetInfoView` to use protocol ViewModels instead of creating mocks internally
- [x] Updated `MockTicketBetInfoViewModel` with mock cashout VMs for GomaUICatalog previews
- [x] Wired real ViewModels in `TicketBetInfoViewModel` with calculation logic
- [x] Implemented partial cashout formula: `partialCashoutValue = (fullCashoutValue × sliderStake) / remainingStake`
- [x] Added reactive Combine subscription for real-time slider updates
- [x] Both GomaUICatalog and BetssonCM UAT build successfully

### Issues / Bugs Hit
- None - implementation went smoothly

### Key Decisions
- **Slider represents stake amount** (not cashout value directly) - min: 0.1, max: remainingStake
- **Initial slider position at 80%** of max stake (following Web/Android pattern)
- **Protocol extension approach** - added optional properties to existing protocol for backward compatibility
- **Dual ViewModel reference pattern** - protocol type for external access + concrete type for internal updates

### Experiments & Notes
- CashoutSliderViewModel and CashoutAmountViewModel already existed in BetssonCameroonApp but weren't wired
- The `dataPublisher` provides reactive updates with `currentValue` - no need to expose synchronous accessor
- Title dynamically switches between "Partial Cashout" and "Full Cashout" based on slider position

### Useful Files / Links
- [TicketBetInfoViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/TicketBetInfoViewModelProtocol.swift)
- [TicketBetInfoView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/TicketBetInfoView.swift)
- [MockTicketBetInfoViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/MockTicketBetInfoViewModel.swift)
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift)
- [CashoutSliderViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/CashoutSliderViewModel.swift)
- [CashoutAmountViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/CashoutAmountViewModel.swift)
- [Plan File](~/.claude/plans/wiggly-rolling-spindle.md)
- [Cashout Handoff Document](./16-December-2025-cashout-handoff-document.md)

### Next Steps
1. Wire SSE subscription to TicketBetInfoViewModel (Phase 4.4 - real-time cashout value updates)
2. Implement cashout state machine (Phase 4.6 - slider → loading → success/failed)
3. Wire cashout execution button to `executeCashout` API
4. Test with real open bet using PROD credentials
