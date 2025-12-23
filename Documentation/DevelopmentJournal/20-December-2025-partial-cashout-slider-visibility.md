## Date
20 December 2025

### Project / Branch
sportsbook-ios / rr/cashout_fixes

### Goals for this session
- Investigate why iOS shows cashout slider for all bets while web hides it for full-cashout-only bets
- Implement `partialCashOutEnabled` flag support to control slider visibility
- Match web behavior: `partialCashOutEnabled: false` = button only, no slider

### Achievements
- [x] Identified root cause: iOS ignores `partialCashOutEnabled` from SSE response
- [x] Verified via production API that bet `98b7c839...` has `partialCashOutEnabled: false`
- [x] Added `isPartialCashoutEnabled` property to `TicketBetInfoViewModel`
- [x] Modified `setupCashoutViewModels()` to NOT create slider upfront - wait for SSE
- [x] Updated `handleCashoutUpdate()` to show/hide slider based on `partialCashOutEnabled` flag
- [x] Added `hideSliderForFullCashoutOnly()` method to remove slider when disabled
- [x] Modified `handleCashoutTap()` to execute full cashout directly when no slider
- [x] Added `cashoutComponentsDidChangePublisher` to protocol for UI refresh
- [x] Updated `TicketBetInfoView` to bind to new publisher and refresh bottom components
- [x] Updated `MockTicketBetInfoViewModel` to conform to updated protocol

### Issues / Bugs Hit
- Production API blocked curl requests without proper `origin` and `referer` headers
- Resolved by adding browser-like headers to requests

### Key Decisions
- **Wait for SSE before creating slider**: Initial `setupCashoutViewModels()` only stores values; SSE determines slider visibility
- **New publisher pattern**: Added `cashoutComponentsDidChangePublisher` to notify UI when slider visibility changes dynamically
- **Button-only full cashout**: When slider is nil but cashout is available, button triggers full cashout directly using `remainingStake`

### Experiments & Notes
- SSE response structure confirmed:
  ```json
  {
    "cashoutValueSettings": {
      "partialCashOutEnabled": true/false  // THIS CONTROLS SLIDER VISIBILITY
    }
  }
  ```
- Bet `98b7c839...` (World Cup 2026 bet with 12 XAF stake) consistently returns `partialCashOutEnabled: false`
- Other bets return `partialCashOutEnabled: true` and should show slider

### Useful Files / Links
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift) - Main ViewModel with slider logic
- [TicketBetInfoViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/TicketBetInfoViewModelProtocol.swift) - Protocol with new publisher
- [TicketBetInfoView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/TicketBetInfoView.swift) - UI component binding
- [MockTicketBetInfoViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/MockTicketBetInfoViewModel.swift) - Mock conforming to protocol
- [CashOut-Feature-Specification.md](../../Documentation/Specs/CashOut-Feature-Specification.md) - Web behavior reference

### Flow Summary

**Before (broken):**
```
API → canCashOut=true → Create slider immediately → Always show slider
```

**After (fixed):**
```
API → Store values only → SSE → partialCashOutEnabled?
  ├─ true  → Create slider → Show slider (partial+full cashout)
  └─ false → Enable button → Button only (full cashout)
```

### Next Steps
1. Build project to verify compilation
2. Test on device with production account `+237650888006`
3. Verify bet `98b7c839...` shows button-only (no slider)
4. Verify other bets show slider as before
5. Test full cashout via button works correctly
