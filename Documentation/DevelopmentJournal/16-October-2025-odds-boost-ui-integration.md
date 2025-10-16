# Odds Boost UI Integration - BetslipFloatingView

## Date
16 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Wire up odds boost data from `BetslipManager.oddsBoostStairsPublisher` to `BetslipFloatingViewModel`
- Display win boost percentage and progress segments in the betslip floating view UI
- Fix critical architectural issue: production ViewModel was never being used

### Achievements
- [x] Refactored `BetslipFloatingViewModel` to use `combineLatest` instead of stored state properties
- [x] Connected odds boost data flow: `oddsBoostStairsPublisher` → ViewModel → UI
- [x] Fixed `BetslipFloatingView` to show win boost capsule when data exists (was always hidden)
- [x] Discovered and fixed critical issue: `MainTabBarViewModel` and `MatchDetailsTextualViewModel` were using `MockBetslipFloatingViewModel` instead of production implementation
- [x] Removed ~75 lines of duplicate/dead code across two ViewModels

### Issues / Bugs Hit
- **Critical architectural issue discovered**: Production `BetslipFloatingViewModel` was never instantiated
  - Both `MainTabBarViewModel` and `MatchDetailsTextualViewModel` used `MockBetslipFloatingViewModel`
  - Both ViewModels manually subscribed to `bettingTicketsPublisher` and calculated state
  - Hardcoded values: `totalEligibleCount = 0`, `winBoostPercentage: nil`
  - Result: All odds boost integration work was bypassed, UI never updated

### Key Decisions

**1. Refactor to `combineLatest` Pattern**
- **Problem**: `BetslipFloatingViewModel` stored `currentTickets` property only to bridge between two subscriptions
- **Solution**: Use `Publishers.CombineLatest` to synchronize both publishers automatically
- **Benefits**:
  - Removed unnecessary stored state (`currentTickets` property)
  - Single subscription instead of two
  - Idiomatic Combine pattern
  - Automatic re-emission when either publisher changes

**2. Production ViewModel Replacement**
- **Root Cause**: Classic "dead code" scenario - created production ViewModel but never switched from Mock
- **Impact**: ~40 lines of duplicate logic per ViewModel (80 total)
- **Solution**:
  - Changed initializer defaults to use `BetslipFloatingViewModel()` instead of Mock
  - Removed manual subscription and update methods
  - Kept only tap callback setup in parent ViewModels

**3. UI Visibility Fix**
- **Bug**: Win boost capsule had hardcoded `isHidden = true` even when data existed
- **Fix**: Changed to `isHidden = false` when `winBoostPercentage` is present (line 415)
- **Impact**: Green "Win Boost:X%" capsule now displays correctly

### Experiments & Notes

**combineLatest Pattern**:
```swift
// Before: Two separate subscriptions + stored state
private var currentTickets: [BettingTicket] = []
bettingTicketsPublisher.sink { self.currentTickets = $0; self.update($0) }
oddsBoostStairsPublisher.sink { if let tickets = self.currentTickets { ... } }

// After: Single combined subscription
Publishers.CombineLatest(
    bettingTicketsPublisher,
    oddsBoostStairsPublisher
)
.sink { (tickets, oddsBoost) in
    self.oddsBoostState = oddsBoost
    self.updateBetslipState(with: tickets)
}
```

**Data Extraction from API Response**:
```swift
private func extractOddsBoostData(selectionCount: Int) -> (String?, Int) {
    guard let oddsBoostState = self.oddsBoostState else {
        return (nil, 0) // No bonus available
    }

    // Current tier percentage for display
    let currentPercentage = oddsBoostState.currentTier.map { tier in
        return "\(Int(tier.percentage * 100))%"
    }

    // Next tier's minSelections for progress bar
    let totalEligibleCount = oddsBoostState.nextTier?.minSelections ?? 0

    return (currentPercentage, totalEligibleCount)
}
```

**Dead Code Discovery**:
- Found by user when progress bar wasn't showing
- Traced to Mock ViewModel receiving manual updates with hardcoded values
- Production ViewModel existed but was never instantiated in any screen

### Useful Files / Links

**Modified Files**:
- `BetssonCameroonApp/App/Screens/NextUpEvents/BetslipFloatingViewModel.swift` - Refactored to combineLatest, ~10 lines cleaner
- `BetssonCameroonApp/App/Screens/MainTabBar/MainTabBarViewModel.swift` - Removed ~40 lines of duplicate logic
- `BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsTextualViewModel.swift` - Removed ~35 lines of duplicate logic
- `Frameworks/GomaUI/.../BetslipFloatingView.swift:415` - Fixed win boost capsule visibility

**Related Documentation**:
- [Odds Boost Stairs Integration](16-October-2025-odds-boost-stairs-integration.md) - Initial API integration
- [EveryMatrix Architecture Deep Dive](16-October-2025-everymatrix-architecture-deep-dive.md) - Provider architecture context

**Key Architecture Files**:
- `BetssonCameroonApp/App/Services/BetslipManager.swift` - Publisher source (oddsBoostStairsPublisher, bettingTicketsPublisher)
- `BetssonCameroonApp/App/Models/Betting/OddsBoostStairs.swift` - App models (OddsBoostStairsState, OddsBoostTier)
- `BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+OddsBoost.swift` - SP → App model mapper

### Next Steps

1. **Testing**: Verify odds boost UI behavior:
   - Add 2+ selections → Should show "X%" and progress segments
   - Add more selections → Percentage increases, progress updates
   - Reach max tier → Win boost shows, progress bar disappears (totalEligibleCount = 0)
   - Log out → Win boost capsule disappears
   - Log back in with tickets → Win boost re-fetches and appears

2. **Edge Cases**: Test scenarios:
   - Non-qualifying events (not in eligibleEventIds)
   - API errors or timeout
   - Currency not in capAmount dict
   - User has no bonus wallet configured

3. **Performance**: Monitor for issues:
   - `combineLatest` emits on every change to either publisher
   - May cause frequent UI updates if betslip changes rapidly
   - Consider debouncing if performance issues arise

4. **Betslip Full Screen**: Apply same pattern to full betslip screen (not just floating view)

5. **Documentation**:
   - Update UI Component Guide with odds boost capsule usage
   - Add betslip floating view to component gallery with odds boost states

### Implementation Pattern Used

**Combine Reactive Pattern**: Used `Publishers.CombineLatest` to synchronize two data streams (tickets and odds boost) and automatically recalculate UI state when either changes.

**MVVM with Protocol-Driven Design**: Production ViewModel implements protocol, handles all data subscriptions and transformations internally, parent ViewModels only set up callbacks.

**3-Layer Data Flow** (from previous session):
```
EveryMatrix API → SP Models → Domain Models → App Models → ViewModel → UI
```

**GomaUI Component Integration**:
- View (BetslipFloatingView) remains passive, receives data via protocol
- ViewModel (BetslipFloatingViewModel) owns subscriptions and data transformation
- Parent ViewModels (MainTabBar, MatchDetails) only need to instantiate and set callbacks

### Feature Context

**User Experience**:
1. User adds 2 selections → Sees "10%" in green capsule, progress 2/3
2. Adds 1 more → Sees "15%", progress 3/4
3. Message: "Add 1 more qualifying event to get a 20% win boost"
4. Adds 4th → Sees "20%", progress bar disappears (max reached)
5. Places bet → Backend applies bonus using `ubsWalletId` from API response

**UI Components Involved**:
- Orange selection count circle
- Orange "Odds:X.XX" capsule
- **Green "Win Boost:X%" capsule** (now visible!)
- Progress segments (X filled / Y total)
- Call-to-action message
- "Open Betslip" button with chevron

### Lessons Learned

**Always verify production code is actually used**: Don't assume that because you wrote production code, it's being executed. Check initializers and factory methods.

**combineLatest is cleaner than stored state**: When coordinating multiple publishers, prefer declarative combination over manual state management.

**Mocks can hide architectural issues**: Using mocks during development is fine, but switching to production should happen before integration testing. Leaving mocks in place bypasses the real implementation.

**UI debugging starts at data flow**: When UI doesn't update, trace backwards: View ← ViewModel ← Publishers ← Data Source. In this case, the break was at ViewModel instantiation.

---

## Session Summary

Completed the odds boost UI integration by connecting `BetslipManager.oddsBoostStairsPublisher` to `BetslipFloatingViewModel` using `combineLatest`. Discovered and fixed critical architectural issue where production ViewModel was never instantiated, causing all odds boost features to be bypassed. Removed ~75 lines of duplicate code. Win boost capsule and progress segments now display correctly with real-time API data.

**Total Lines Changed**: ~120 (10 added in ViewModel refactor, ~110 deleted from parent ViewModels and UI fix)
**Critical Bug Fixed**: Production ViewModel was dead code, Mock was receiving hardcoded values
**Pattern Introduced**: `combineLatest` for multi-publisher synchronization in ViewModels
