# Cell Reuse Fix - Market Outcomes Components

## Date
24 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix critical cell reuse bug causing blank outcome buttons after scrolling
- Investigate real-time update issues (odds updates, market suspension)
- Align MarketOutcomesMultiLineView with official GomaUI guidelines
- Ensure skeleton/loading states remain functional

### Achievements
- [x] Identified root cause: MarketOutcomesMultiLineView violated GomaUI cell reuse pattern
- [x] Added `cleanupForReuse()` method to MarketOutcomesMultiLineView following GomaUI guidelines
- [x] Implemented smart view reuse logic (reuse existing views when count matches, only recreate when structure changes)
- [x] Added `configure()` method to MarketOutcomesLineView (was missing, breaking the reuse chain)
- [x] Fixed betslip selection state sync regression (outcomes now show selected state after scroll)
- [x] Fixed outcome tap regression (callbacks now properly re-established after cell reuse)
- [x] Updated TallOddsMatchCardView to call cleanupForReuse() on child views
- [x] Verified skeleton/loading states remain functional (no changes needed)

### Issues / Bugs Hit
- [x] **CRITICAL**: Outcome buttons blank after scrolling - caused by destroy-recreate pattern instead of view reuse
- [x] **REGRESSION 1**: MarketOutcomesLineView had no `configure()` method - only `init()` with immediate binding
- [x] **REGRESSION 2**: Betslip selection state lost after scroll - `configure()` didn't apply current ViewModel state
- [x] **REGRESSION 3**: Outcome taps not working - parent callbacks cleared by cleanupForReuse() but never re-established

### Key Decisions
- **Followed OutcomeItemView pattern exactly**: All components now use same configure/cleanup pattern
- **Smart reuse logic**: Check if line count matches before recreating views
- **Pointer equality check**: Reuse views if same ViewModel instances (ViewModels are stable within a sport/filter)
- **Immediate state application**: After `configure()`, immediately apply ViewModel's current state (critical for betslip sync)
- **Callback restoration**: Extract callback setup into separate method, call after every `configure()`
- **No unit tests added**: As requested, focused on implementation only

### Root Cause Analysis

**Original Problem:**
```swift
// BEFORE (BROKEN):
public func configure(with newViewModel: ...) {
    cancellables.removeAll()

    // ❌ Always destroys ALL line views
    lineViews.forEach { $0.removeFromSuperview() }
    lineViews.removeAll()

    // ❌ Always creates NEW views
    updateLineViews(with: newViewModel.lineViewModels)
    setupBindings()
}
```

**Why it broke:**
1. Cell scrolls back with SAME ViewModel instance
2. `configure()` destroys all existing views
3. Creates NEW MarketOutcomesLineView instances
4. New views subscribe to publishers
5. Publishers don't emit (same ViewModel, same values - CurrentValueSubject)
6. Result: **BLANK OUTCOME BUTTONS**

**Solution Pattern (from GomaUI guidelines):**
```swift
// AFTER (FIXED):
public func configure(with newViewModel: ...) {
    cancellables.removeAll()
    self.viewModel = newViewModel

    // ✅ Smart reuse logic
    if lineViews.count == newLineViewModels.count {
        // REUSE existing views
        for (index, lineViewModel) in newLineViewModels.enumerated() {
            lineViews[index].configure(with: lineViewModel)
            setupLineCallbacks(lineView: lineViews[index])
        }
    } else {
        // Only recreate if structure changed
        recreateAllLineViews(with: newLineViewModels)
    }
}
```

### Regression Fixes

**Regression 1: Missing configure() in MarketOutcomesLineView**
- Added `configure()` method following OutcomeItemView pattern
- Clears bindings, updates ViewModel, re-establishes bindings

**Regression 2: Betslip selection state lost**
- Added immediate state application: `updateMarketState(newViewModel.marketStateSubject.value)`
- After `setupBindings()`, immediately query and render current ViewModel state
- Ensures selection state from betslip sync is visible after cell reuse

**Regression 3: Outcome taps broken**
- Extracted callback setup into `setupMarketOutcomesCallbacks()` method
- Call this method after every `updateMarketOutcomesView()`
- Restores parent-level callbacks that were cleared by `cleanupForReuse()`

### Experiments & Notes

**Investigation Process:**
1. Used 4 parallel Task agents to investigate:
   - Agent 1: Child view configuration chain analysis → Found destroy-recreate anti-pattern
   - Agent 2: ViewModel instance stability tracking → Found ViewModels are stable during scroll
   - Agent 3: Subscription lifecycle tracing → Confirmed subscriptions work when views reused
   - Agent 4: Log consolidation → Identified lack of visibility (100+ scattered logs)

2. Discovered MarketOutcomesMultiLineView violated ALL 5 GomaUI guidelines:
   - ❌ No cleanupForReuse() method
   - ❌ Always destroys/recreates instead of reusing
   - ❌ Updates all lines instead of only changed ones
   - ❌ Full re-renders instead of efficient updates
   - ❌ No pattern for cells to call before configure

3. Compared with working components (OutcomeItemView, MarketInfoLineView, MatchHeaderView):
   - All have configure() + cleanupForReuse()
   - All reuse existing views
   - All re-establish bindings without view recreation

**Architecture Discovery:**
- MarketOutcomesLineView binds in `init()`, not `configure()` → needed new configure() method
- ViewModels are created ONCE and stable during scroll (until sport/filter change)
- Publishers use CurrentValueSubject → emit immediately on new subscription
- Cell reuse pattern requires immediate state application (not just future subscriptions)

**Skeleton Support:**
- Already fully implemented via DisplayState enums
- OutcomeItemView has `.loading` state with UIActivityIndicatorView
- No changes needed - existing loading states preserved

### Useful Files / Links

**Modified Files:**
- [MarketOutcomesMultiLineView.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesMultiLineView/MarketOutcomesMultiLineView.swift) - Core fix with smart reuse logic
- [MarketOutcomesLineView.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesLineView/MarketOutcomesLineView.swift) - Added configure() method
- [TallOddsMatchCardView.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TallOddsMatchCardView/TallOddsMatchCardView.swift) - Added cleanupForReuse() call for child views
- [TallOddsMatchCardTableViewCell.swift](BetssonCameroonApp/App/Screens/NextUpEvents/TallOddsMatchCardTableViewCell.swift) - Updated prepareForReuse()

**Reference Documentation:**
- [MarketOutcomesComponentsGuide.md](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Documentation/MarketOutcomesComponentsGuide.md) - Official GomaUI guidelines
- [UI_COMPONENT_GUIDE.md](Frameworks/GomaUI/UIKIT_CODE_ORGANIZATION_GUIDE.md) - Cell reuse patterns
- [ComponentCreationGuide.md](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Documentation/ComponentCreationGuide.md) - MVVM patterns

**Related Components:**
- [OutcomeItemView.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/OutcomeItemView/OutcomeItemView.swift) - Reference pattern (lines 85-98)
- [MarketInfoLineView.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketInfoLineView/MarketInfoLineView.swift) - Reference pattern
- [MatchHeaderView.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderView/MatchHeaderView.swift) - Reference pattern

### Code Changes Summary

**1. MarketOutcomesMultiLineView.swift:**
- Added `cleanupForReuse()` method (lines 68-89)
- Modified `configure()` to use smart reuse logic (lines 91-105)
- Added `reconfigureOrRecreateLineViews()` helper (lines 117-142)
- Renamed `updateLineViews()` → `recreateAllLineViews()` (lines 276-314)

**2. MarketOutcomesLineView.swift:**
- Added `configure()` method (lines 56-73)
- Immediately applies current ViewModel state after setupBindings()

**3. TallOddsMatchCardView.swift:**
- Added `marketOutcomesView.cleanupForReuse()` call in resetChildViewsState() (line 125)
- Added `setupMarketOutcomesCallbacks()` method (lines 372-383)
- Call setupMarketOutcomesCallbacks() after configure() (line 229)

**4. TallOddsMatchCardTableViewCell.swift:**
- Changed to call `prepareForReuse()` instead of `configure(with: nil)` (line 47)

### Testing Performed

**Manual Testing:**
1. ✅ Scroll down/up in Next Up Events → outcomes visible after scroll
2. ✅ Change sports (Football → Basketball) → new outcomes visible
3. ✅ Tap outcomes → added to betslip correctly
4. ✅ Outcomes in betslip show selected state after scroll
5. ✅ Loading states still work (skeleton support intact)

**Expected Behavior Verified:**
- First load: Outcomes display correctly
- Scroll down: New cells show outcomes
- Scroll up: Previously visible cells show outcomes (not blank)
- Sport change: New sport's outcomes display
- Betslip sync: Selected outcomes remain highlighted after scroll
- Outcome taps: Successfully add to betslip

### Performance Impact

**Improvements:**
- View reuse significantly reduces object allocation during scroll
- No unnecessary view destruction/recreation when count matches
- Publishers don't need to re-emit for unchanged ViewModels
- Callback restoration is lightweight (simple closure assignments)

**Metrics (Expected):**
- ~90% reduction in MarketOutcomesLineView allocations during scroll
- ~95% reduction in OutcomeItemView allocations during scroll
- Smoother scrolling (no frame drops from view recreation)
- Lower memory pressure

### Architecture Alignment

**Before:** MarketOutcomesMultiLineView was an outlier
- Only component that always destroyed/recreated views
- Only component without cleanupForReuse()
- Violated all GomaUI cell reuse guidelines

**After:** Consistent pattern across all components

| Component | configure()? | cleanupForReuse()? | Pattern |
|-----------|-------------|-------------------|---------|
| OutcomeItemView | ✅ | ✅ | Reuse views |
| MarketInfoLineView | ✅ | ✅ | Reuse views |
| MatchHeaderView | ✅ | ✅ | Reuse views |
| **MarketOutcomesLineView** | **✅ NEW** | ✅ | **Reuse views** |
| **MarketOutcomesMultiLineView** | **✅ FIXED** | **✅ NEW** | **Reuse child views** |

### Next Steps

**Immediate:**
1. Monitor app in staging/production for any edge cases
2. Verify performance improvements with Instruments profiling
3. Check memory usage during extended scrolling sessions

**Future Improvements (Separate Tasks):**
1. Fix ViewModel recreation on sport change (Agent 2's findings)
   - Implement diffing logic in MarketGroupCardsViewModel.updateMatches()
   - Reuse ViewModels where Match IDs match instead of full recreation
   - Will eliminate subscription churn and improve performance further
2. Add unified logging system (Agent 4's proposal)
   - Consolidate 100+ scattered logs with consistent prefixes
   - Add strategic logging for debugging cell reuse issues
   - Enable comparison with reference site
3. Consider adding automated tests for cell reuse lifecycle
   - Test configure/cleanup cycle
   - Verify callback restoration
   - Validate betslip sync after reuse

**Documentation:**
- ✅ This development journal documents the complete investigation and fix
- Consider adding code comments about cell reuse pattern in affected files
- Update component README files with cell reuse best practices

### Lessons Learned

1. **Always follow established patterns**: Other GomaUI components had correct pattern
2. **Cell reuse requires immediate state application**: Not just future subscriptions
3. **Callbacks need explicit restoration**: cleanupForReuse() clears, configure() must restore
4. **Use agents for complex investigations**: Parallel analysis saved significant debugging time
5. **Git diff is essential for regression analysis**: Quickly identified exact lines that broke features
6. **CurrentValueSubject behavior**: Emits immediately on subscription, perfect for cell reuse
7. **ViewModel stability is key**: ViewModels are stable during scroll, enable view reuse optimization

---

## Session Statistics
- **Duration**: ~3 hours
- **Files Modified**: 4
- **Lines Added**: ~120
- **Lines Removed**: ~15
- **Critical Bugs Fixed**: 4
- **Regressions Fixed**: 3
- **Pattern Compliance**: 100% (now follows GomaUI guidelines)
