# Odds Boost Next Tier Percentage & Progress Segment Animations

## Date
16 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix hardcoded "11%" in call-to-action message to use actual next tier percentage from API
- Optimize progress segments to avoid full recreation on every betslip update
- Add smooth animations for progress segment fill/unfill transitions

### Achievements
- [x] Added `nextTierPercentage` parameter to `BetslipFloatingState.withTickets` enum case
- [x] Updated `BetslipFloatingViewModel.extractOddsBoostData()` to extract next tier percentage from API response
- [x] Fixed hardcoded "11%" in call-to-action message (now shows actual next tier: "Add 1 more to get 15%")
- [x] Created `ProgressSegmentView.swift` - custom UIView for individual segments with animation support
- [x] Replaced full segment recreation with diff-based `updateProgressSegments()` method
- [x] Implemented three animation types: segment addition (scale + fade in), removal (scale + fade out), fill state (color transition)
- [x] Added staggered wave effect (50ms delay between segments) for premium feel

### Issues / Bugs Hit
- **Hardcoded percentage**: Line 431 in BetslipFloatingView had `"get a 11% win boost"` hardcoded
  - Root cause: Only `currentTier.percentage` was being extracted, not `nextTier.percentage`
  - Fix: Extended data model to pass `nextTierPercentage` through entire stack

- **Performance inefficiency**: Progress segments were fully recreated (remove all + create all) on every betslip state change
  - Root cause: `setupProgressSegments()` called `removeAll()` and rebuilt array from scratch
  - Impact: 12+ view operations per update (6 removes + 6 creates for typical case)
  - Fix: Implemented diff-based updates that only modify changed segments

### Key Decisions

**1. Extend Enum with Next Tier Percentage**
- **Approach**: Add `nextTierPercentage: String?` to `BetslipFloatingState.withTickets` case
- **Rationale**: Clean data flow - ViewModel extracts from API, passes formatted string to View
- **Alternative considered**: View could calculate message from `totalEligibleCount`, but that violates separation of concerns

**2. Create Custom ProgressSegmentView**
- **Approach**: Dedicated UIView subclass with `setFilled(_:animated:)` method
- **Rationale**:
  - Encapsulates segment logic and state tracking (`isFilled` property)
  - Enables internal optimization (early return if state unchanged)
  - Reusable component (could be used elsewhere)
  - Follows GomaUI one-type-per-file architecture
- **Alternative considered**: Keep as generic `UIView` array with external color management - rejected for maintainability

**3. Diff-Based Update Strategy**
- **Approach**: Compare current vs target count, only add/remove/update what changed
- **Benefits**:
  - Performance: O(1) for typical color changes vs O(n) full recreation
  - Enables animations: Can animate individual segment changes
  - Smooth UX: No flicker or layout jumps
- **Tradeoff**: More complex code (~80 lines vs ~25 lines), but significantly better UX

**4. Staggered Animation Wave Effect**
- **Approach**: 50ms delay between segment fill animations (`Double(index) * 0.05`)
- **Rationale**: Creates premium "wave" effect that feels polished
- **Timing**: 6 segments = 0.55s total wave (short enough to feel responsive)

### Experiments & Notes

**Data Flow for Next Tier Percentage:**
```swift
// API Response (ServicesProvider)
OddsBoostStairsState {
  currentTier: OddsBoostTier(minSelections: 3, percentage: 0.15)  // 15%
  nextTier: OddsBoostTier(minSelections: 4, percentage: 0.20)     // 20%
}

// ViewModel Extraction
let (currentPercentage, totalEligibleCount, nextTierPercentage) = extractOddsBoostData()
// Returns: ("15%", 4, "20%")

// View Display
"Add 1 more qualifying selection to get a 20% win boost"
```

**Animation Performance Comparison:**
```swift
// BEFORE: Full recreation every update
setupProgressSegments(6 segments):
  - removeFromSuperview() × 6 = 6 operations
  - UIView() × 6 = 6 allocations
  - addArrangedSubview() × 6 = 6 operations
  Total: 18 operations, no animations

// AFTER: Diff-based updates
updateProgressSegments(2 → 3 filled, 6 total):
  - segment[2].setFilled(true, animated: true) = 1 color animation
  Total: 1 operation with smooth transition
```

**Stagger Timing Calculation:**
```swift
// 6 segments with 50ms stagger:
Segment 0: 0ms delay + 300ms animation = 300ms
Segment 1: 50ms delay + 300ms animation = 350ms
Segment 2: 100ms delay + 300ms animation = 400ms
...
Segment 5: 250ms delay + 300ms animation = 550ms
Total wave duration: 550ms (feels responsive)
```

### Useful Files / Links

**Modified Files:**
- `Frameworks/GomaUI/.../BetslipFloatingView/BetslipFloatingViewModelProtocol.swift` - Extended enum with `nextTierPercentage`
- `Frameworks/GomaUI/.../BetslipFloatingView/BetslipFloatingView.swift` - Used next tier % in message (line 431), integrated ProgressSegmentView
- `Frameworks/GomaUI/.../BetslipFloatingView/MockBetslipFloatingViewModel.swift` - Updated mock factory methods
- `BetssonCameroonApp/App/Screens/NextUpEvents/BetslipFloatingViewModel.swift` - Extract next tier % from API response

**Created Files:**
- `Frameworks/GomaUI/.../BetslipFloatingView/ProgressSegmentView.swift` - NEW: Custom animated segment view

**Related Documentation:**
- [Odds Boost Stairs Integration](16-October-2025-odds-boost-stairs-integration.md) - Initial API integration
- [Odds Boost UI Integration](16-October-2025-odds-boost-ui-integration.md) - BetslipFloatingViewModel wiring
- [UI Component Guide](../UI_COMPONENT_GUIDE.md) - GomaUI architecture patterns

**Key Architecture Files:**
- `BetssonCameroonApp/App/Models/Betting/OddsBoostStairs.swift` - App models (OddsBoostStairsState, OddsBoostTier)
- `BetssonCameroonApp/App/Services/BetslipManager.swift` - Publisher source (oddsBoostStairsPublisher)

### Next Steps

1. **Testing**: Verify animations in simulator:
   - Add selections one by one → Should see wave effect
   - Reach next tier → Should see color transition with stagger
   - Remove selections → Should see reverse wave effect
   - Add enough to show progress bar → Should see scale + fade in
   - Max out tiers → Should see progress bar scale + fade out

2. **Edge Cases**: Test animation behavior:
   - Rapid selection changes (add/remove quickly)
   - Jump from 2 selections to 5+ selections at once
   - Progress bar appearing/disappearing repeatedly

3. **Performance**: Monitor in Instruments if needed:
   - `updateProgressSegments()` should be O(1) for typical updates
   - Watch for retain cycles with `DispatchQueue.main.asyncAfter` closures
   - Verify staggered animations don't pile up if state changes rapidly

4. **Full Betslip Screen**: Apply same patterns to main betslip screen (not just floating view)

5. **Localization**: Add proper localization for:
   - "Add X more qualifying selection" message (line 432)
   - "Max win boost activated!" message (line 434)
   - "Win Boost:" label (line 465)
   - "Odds:" label (line 461)

6. **Documentation**: Update UI Component Guide with:
   - ProgressSegmentView usage example
   - Animation timing guidelines
   - When to use animated vs non-animated updates

### Implementation Pattern Used

**Diff-Based UI Updates with Animations**: Compared current state vs target state, only modified changed elements with smooth transitions. Avoided full view hierarchy recreation.

**Custom UIView Component**: Created `ProgressSegmentView` to encapsulate segment logic, state tracking, and animation behavior following GomaUI one-type-per-file architecture.

**Staggered Animation Pattern**: Used `DispatchQueue.main.asyncAfter` with index-based delay calculation to create wave effect across multiple views.

### Feature Context

**User Experience Flow:**
1. User has 2 selections → Sees "10%" in green capsule, progress shows 2/3 filled segments
2. Adds 1 more selection → **Wave animation**: segments fill left-to-right with 50ms stagger, percentage updates to "15%"
3. Message updates: "Add 1 more qualifying selection to get a 20% win boost" (using next tier %)
4. Adds 4th selection → Sees "20%", progress bar smoothly scales down and fades out (max tier reached)
5. Places bet → Backend applies bonus using `ubsWalletId` from API response

**Animation Details:**
- **Fill transition**: Gray (#backgroundBorder) → Green (#highlightSecondary) over 0.3s
- **Unfill transition**: Green → Gray over 0.3s (when removing selections)
- **Add segments**: Scale 0.3 → 1.0 + fade in, 0.4s total with 0.1s delay
- **Remove segments**: Scale 1.0 → 0.3 + fade out, 0.2s duration
- **Wave effect**: 50ms stagger creates left-to-right cascade feel

### Lessons Learned

**Always check what data is available before hardcoding**: The API response included `nextTier.percentage` all along, we just weren't extracting it. Quick grep of the models would have caught this earlier.

**Diff-based updates are worth the complexity for frequently changing UI**: While the new `updateProgressSegments()` is 3x longer than the old code, the performance improvement and animation support make it worthwhile for a component that updates on every betslip change.

**Staggered animations create premium feel with minimal effort**: Just 50ms delay between segments transforms a basic color change into something that feels polished. Small timing details matter.

**Custom UIView for repeated elements enables optimizations**: By moving segment logic into `ProgressSegmentView`, we can implement state tracking (`isFilled`) and early returns that wouldn't be possible with generic `UIView` array.

**GomaUI architecture scales well**: Following one-type-per-file made it easy to add `ProgressSegmentView` without cluttering the main component file.

---

## Session Summary

Fixed hardcoded "11%" in odds boost call-to-action message by extending data model to pass `nextTierPercentage` from EveryMatrix API through ViewModel to View. Optimized progress segments with diff-based updates and custom `ProgressSegmentView` component, reducing typical updates from 18 operations to 1 operation. Added three animation types (fill/unfill color transitions, segment addition/removal scale+fade, staggered wave effect) for polished UX.

**Total Lines Changed**: ~130 (new ProgressSegmentView file + enum changes + optimized update method)
**Performance Impact**: O(n) → O(1) for typical segment updates
**New Pattern**: Staggered animation wave effect with `asyncAfter` + index-based delays
**Architecture**: Follows GomaUI one-type-per-file, encapsulated custom view component
