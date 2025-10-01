## Date
30 September 2025

### Project / Branch
sportsbook-ios / rr/virtuals

### Goals for this session
- Fix outcome button selection state synchronization with betslip in MatchBannerView
- Ensure selection state persists on scroll (cell reuse)
- Make outcome buttons reflect betslip changes from external sources (e.g., list deselection)

### Achievements
- [x] Implemented betslip-aware selection state synchronization following MVVM-C parent-managed pattern
- [x] Extended `MarketOutcomesLineViewModelProtocol` with `updateSelectionStates(selectedOfferIds:)` method
- [x] Implemented `updateSelectionStates` in both `MockMarketOutcomesLineViewModel` and production ViewModels
- [x] Fixed `MatchBannerViewModel` to use production `MatchBannerMarketOutcomesLineViewModel` instead of Mock
- [x] Fixed `MatchBannerView` casting issue that was blocking production ViewModel usage
- [x] Fixed deselection bug by removing conditional state checks in parent ViewModel
- [x] Selection state now syncs bidirectionally: banner ↔ betslip ↔ match list

### Issues / Bugs Hit
- [x] **Mock ViewModel child creation issue**: `MockMarketOutcomesLineViewModel.createOutcomeViewModel()` was creating new child ViewModels on every call, breaking reactive bindings during cell reuse
- [x] **Type casting failure**: `MatchBannerView.swift:204` was casting to `MockMarketOutcomesLineViewModel` specifically, causing production ViewModel to be ignored
- [x] **Deselection not working**: Parent state (`marketStateSubject`) was never updated when child ViewModels changed, so conditional checks (`isSelected != newValue`) prevented deselection from firing

### Key Decisions
- **Chose Parent-Managed Selection State (Option 2)** over:
  - Option 1: Betslip-Aware OutcomeItemViewModel (simpler but pollutes GomaUI with app-specific logic)
  - Option 3: Centralized SelectionStateManager (more robust but adds unnecessary indirection)
- **Reasoning**: Maintains GomaUI reusability, follows existing MVVM-C patterns, performance-conscious (one subscription per match, not per outcome)
- **MatchBannerMarketOutcomesLineViewModel already existed** with built-in betslip subscription - just needed to use it instead of Mock
- **Always update child ViewModels unconditionally** - betslip is the single source of truth, don't rely on stale parent state

### Experiments & Notes
- Added surgical logging with `[BETSLIP_SYNC]` prefix at critical decision points:
  - `MatchBannerViewModel`: Subscription setup, betslip changes, offer ID extraction
  - `MatchBannerMarketOutcomesLineViewModel`: Betslip subscription, selection state updates
  - `MockMarketOutcomesLineViewModel`: `updateSelectionStates` with per-outcome state tracking
  - `MockOutcomeItemViewModel`: `setSelected()` calls with before/after state
- Logs revealed the Mock → Production ViewModel issue immediately (saw `offerID: nil` instead of real IDs)
- Hyperthink mode debugging technique: trace backwards from symptom to root cause through architectural layers

### Useful Files / Links
- [MarketOutcomesLineViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesLineView/MarketOutcomesLineViewModelProtocol.swift) - Added `updateSelectionStates` protocol method
- [MockMarketOutcomesLineViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesLineView/MockMarketOutcomesLineViewModel.swift) - Mock implementation with detailed logging
- [MatchBannerMarketOutcomesLineViewModel](../../BetssonCameroonApp/App/ViewModels/Banners/MatchBannerMarketOutcomesLineViewModel.swift) - Production implementation with betslip subscription
- [MatchBannerViewModel](../../BetssonCameroonApp/App/ViewModels/Banners/MatchBannerViewModel.swift) - Simplified to use production ViewModel
- [MatchBannerView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchBannerView/MatchBannerView.swift) - Fixed type casting issue (line 204)
- [MarketOutcomesLineViewModel](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/MarketOutcomesLineViewModel.swift) - Also updated for protocol conformance
- [BetslipManager](../../BetssonCameroonApp/App/Services/BetslipManager.swift) - Central betslip state management

### Architecture Notes
**Data Flow for Selection State Sync:**
```
User taps outcome in banner
  → OutcomeItemView.handleTap() (line 437)
    → MatchBannerViewModel.onOutcomeSelected()
      → Env.betslipManager.addBettingTicket()
        → bettingTicketsPublisher emits
          → MatchBannerMarketOutcomesLineViewModel.updateSelectionState()
            → outcomeViewModels[.left].setSelected(true)
              → OutcomeItemView updates UI ✅

User taps outcome in list
  → (same betslip flow)
    → ALL MatchBannerMarketOutcomesLineViewModel instances receive update
      → Banner outcomes sync automatically ✅
```

**Why This Architecture Works:**
- GomaUI components stay reusable (no app-specific dependencies)
- Clear ownership: MatchBannerViewModel owns its outcome selection states
- Single source of truth: BetslipManager is the authoritative state
- Performance: One betslip subscription per match, not per outcome
- Scalable: Works for banners, match cards, match details, etc.

### Next Steps
1. Remove `[BETSLIP_SYNC]` debug logs once fully tested in production
2. Apply same pattern to other match card components (TallOddsMatchCardViewModel, etc.)
3. Consider extracting betslip sync logic into a reusable protocol/mixin if pattern repeats
4. Test with multiple simultaneous banners scrolling to verify no memory leaks from Combine subscriptions
5. Document this pattern in `Documentation/MVVM.md` as reference for future similar issues
