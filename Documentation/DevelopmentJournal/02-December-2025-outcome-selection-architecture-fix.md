## Date
02 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Investigate and fix broken outcome selection architecture in OutcomeItemView
- Understand why double-toggle workaround was needed
- Implement proper MVVM-C pattern for outcome selection

### Achievements
- [x] Root cause analysis: identified triple-toggle chaos in selection flow
- [x] Designed and documented correct MVVM architecture with unidirectional data flow
- [x] Added `OutcomeSelectionChangeEvent` to `OutcomeItemViewModelProtocol`
- [x] Added `MarketOutcomeSelectionEvent` to `MarketOutcomesLineViewModelProtocol`
- [x] Added `CompactOutcomeSelectionEvent` to `CompactOutcomesLineViewModelProtocol`
- [x] Implemented `userDidTapOutcome()` method as single entry point for user interaction
- [x] Implemented `selectionDidChangePublisher` for parent ViewModels to observe child changes
- [x] Implemented `outcomeSelectionDidChangePublisher` for Views to observe parent ViewModel
- [x] Fixed `OutcomeItemView.handleTap()` - now calls single method, no direct state access
- [x] Added haptic feedback via publisher observation (proper MVVM)
- [x] Removed `onTap` callback from OutcomeItemView
- [x] Removed deprecated `toggleSelection()` and `toggleOutcome()` methods
- [x] Updated `MockOutcomeItemViewModel` with new architecture
- [x] Updated `MockMarketOutcomesLineViewModel` with child observation
- [x] Updated `MockCompactOutcomesLineViewModel` with child observation
- [x] Updated production `OutcomeItemViewModel` (BetssonCameroonApp)
- [x] Updated production `MarketOutcomesLineViewModel` (BetssonCameroonApp)
- [x] Updated `MatchBannerMarketOutcomesLineViewModel` (BetssonCameroonApp)
- [x] Updated `MarketOutcomesLineView` to observe parent VM publisher
- [x] Updated `CompactOutcomesLineView` to observe parent VM publisher

### Issues / Bugs Hit
- [ ] Original bug: `toggleSelection()` was called twice in `OutcomeItemView.handleTap()` as accidental workaround
- [ ] Root cause: Triple-toggle (View toggled twice + Parent toggled once = odd number = worked)
- [ ] Single toggle didn't work because: View toggle + Parent toggle = even number = back to original state

### Key Decisions
1. **Single Source of Truth**: `OutcomeItemViewModel.outcomeDataSubject` owns selection state
2. **Unidirectional Data Flow**: User Tap → View → ViewModel → State → Publishers → Observers
3. **View is Passive**: Views NEVER access ViewModel internals (no `.value` access)
4. **Parent Observes Children**: Parent VM subscribes to child VMs' publishers, re-publishes for its View
5. **Callbacks for External Systems Only**: `onOutcomeSelected`/`onOutcomeDeselected` notify Coordinator/BetslipService, don't trigger state changes

### Experiments & Notes
- The broken architecture had View calling `toggleSelection()` twice, then parent calling it again through callback
- With 3 toggles: false→true→false→true (ended at selected - worked!)
- With 2 toggles: false→true→false (ended at unselected - broken!)
- The "fix" of calling it twice was accidentally compensating for the parent's toggle

### Architecture Before vs After

**Before (Broken):**
```
OutcomeItemView.handleTap()
├── viewModel.toggleSelection()     ← Toggle #1
├── viewModel.toggleSelection()     ← Toggle #2 (accidental workaround)
└── onTap(outcomeId)
    └── MarketOutcomesLineView.handleOutcomeTap()
        └── viewModel.toggleOutcome()  ← Toggle #3 (same child VM!)
```

**After (Correct MVVM):**
```
User Tap → OutcomeItemView.handleTap()
    │
    └── viewModel.userDidTapOutcome()  ← Single call
           │
           ├── Toggles state internally
           ├── Publishes to isSelectedPublisher → View updates UI
           └── Publishes to selectionDidChangePublisher
                                              │
                                              ▼
                         Parent ViewModel observes & re-publishes
                                              │
                                              ▼
                         Parent View observes & calls external callbacks
```

### Useful Files / Links
- [OutcomeItemViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/OutcomeItemView/OutcomeItemViewModelProtocol.swift)
- [OutcomeItemView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/OutcomeItemView/OutcomeItemView.swift)
- [MockOutcomeItemViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/OutcomeItemView/MockOutcomeItemViewModel.swift)
- [MarketOutcomesLineViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesLineView/MarketOutcomesLineViewModelProtocol.swift)
- [MarketOutcomesLineView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesLineView/MarketOutcomesLineView.swift)
- [MockMarketOutcomesLineViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesLineView/MockMarketOutcomesLineViewModel.swift)
- [CompactOutcomesLineViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CompactOutcomesLineView/CompactOutcomesLineViewModelProtocol.swift)
- [CompactOutcomesLineView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CompactOutcomesLineView/CompactOutcomesLineView.swift)
- [MockCompactOutcomesLineViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CompactOutcomesLineView/MockCompactOutcomesLineViewModel.swift)
- [Production OutcomeItemViewModel](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/OutcomeItemViewModel.swift)
- [Production MarketOutcomesLineViewModel](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/MarketOutcomesLineViewModel.swift)
- [MatchBannerMarketOutcomesLineViewModel](../../BetssonCameroonApp/App/ViewModels/Banners/MatchBannerMarketOutcomesLineViewModel.swift)
- [Plan File](../../.claude/plans/nested-purring-cerf.md)

### Next Steps
1. Build GomaUIDemo to verify all components work
2. Build BetssonCameroonApp to verify production code
3. Test outcome selection in simulator - single tap should select, second tap should deselect
4. Verify betslip integration still receives correct events
5. Fix any remaining build errors in Demo/Preview files if needed
