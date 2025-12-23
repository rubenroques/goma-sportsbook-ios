# Development Journal

## Date
21 December 2025

### Project / Branch
BetssonCameroonApp / rr/cashout_fixes

### Goals for this session
- Create production ViewModels for InlineMatchCardView (already exists in GomaUI)
- Integrate inline match cards into BetssonCameroonApp
- Replace TallOddsMatchCardTableViewCell with InlineMatchCardTableViewCell in NextUpEvents
- Fix betslip integration issue where clicking outcomes didn't add to betslip

### Achievements
- [x] Created `InlineScoreViewModel.swift` - horizontal score display with sport-specific logic
- [x] Created `CompactMatchHeaderViewModel.swift` - simplified header with date/LIVE badge + market count
- [x] Created `CompactOutcomesLineViewModel.swift` - single line of 2-3 outcomes with real-time odds updates
- [x] Created `InlineMatchCardViewModel.swift` - main composite ViewModel with live data + betslip integration
- [x] Added `InlineMatchCardData` struct and `inlineMatchCardsData` publisher to `MarketGroupCardsViewModel`
- [x] Replaced TallOddsMatchCard with InlineMatchCard in `MarketGroupCardsViewController`
- [x] Fixed critical betslip integration bug in `CompactOutcomesLineViewModel.updateOutcomeViewModels()`

### Issues / Bugs Hit
- [x] **Betslip not updating when clicking outcomes** - Root cause identified and fixed

### Key Decisions
- **Reused existing patterns**: All new ViewModels follow the same architecture as TallOddsMatchCardViewModel
- **Single market per card**: InlineMatchCard displays only the first relevant market (compact design)
- **Horizontal score layout**: InlineScoreView uses horizontal columns vs vertical ScoreView
- **GomaUI cell already exists**: `InlineMatchCardTableViewCell` was already in GomaUI

### Experiments & Notes

**Betslip Bug Investigation:**

The issue was in `CompactOutcomesLineViewModel.updateOutcomeViewModels()`:

```swift
// BEFORE (BUG):
childCancellables.removeAll()  // Clears ALL subscriptions
if outcomeViewModels[.left] == nil {  // Only subscribes if VM is NEW
    subscribeToOutcomeEvents(...)
}
// Result: Existing VMs lose their subscriptions after market update!

// AFTER (FIX):
childCancellables.removeAll()
if let existingVM = outcomeViewModels[.left] {
    subscribeToOutcomeEvents(outcomeVM: existingVM, ...)  // Re-subscribe existing
} else if let matchingOutcome = ... {
    // Create new VM and subscribe
}
```

**Event Flow Validated:**
```
OutcomeItemView (tap) → userDidTapOutcome()
    ↓
OutcomeItemViewModel → selectionDidChangeSubject.send()
    ↓
CompactOutcomesLineViewModel → outcomeSelectionDidChangeSubject.send()
    ↓
InlineMatchCardViewModel → Env.betslipManager.addBettingTicket()
```

### Useful Files / Links

**New Production ViewModels:**
- [InlineScoreViewModel](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/InlineScoreViewModel.swift)
- [CompactMatchHeaderViewModel](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/CompactMatchHeaderViewModel.swift)
- [CompactOutcomesLineViewModel](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/CompactOutcomesLineViewModel.swift) - Contains the betslip fix
- [InlineMatchCardViewModel](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/InlineMatchCardViewModel.swift)

**Modified Files:**
- [MarketGroupCardsViewModel](../../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewModel.swift)
- [MarketGroupCardsViewController](../../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewController.swift)

**GomaUI Components (reference):**
- [InlineMatchCardView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/InlineMatchCardView/)
- [CompactOutcomesLineView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CompactOutcomesLineView/)
- [OutcomeItemViewModel](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/OutcomeItemViewModel.swift)

**Previous DJ:**
- [21-December-2025-inline-match-card-integration.md](./21-December-2025-inline-match-card-integration.md)

### Next Steps
1. Test inline cards with live matches to verify score updates work
2. Test betslip integration thoroughly (select/deselect outcomes)
3. Verify selection state syncs when betslip changes externally
4. Consider adding navigation callback for `onMoreMarketsTapped`
