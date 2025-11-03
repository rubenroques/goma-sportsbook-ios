# Progress Segment Coordinator Extraction

## Date
16 October 2025

### Project / Branch
sportsbook-ios / rr/oddsboost_ui

### Goals for this session
- Fix "jumping" animation issue where segments instantly reposition when adding/removing
- Extract duplicated progress segment animation logic into reusable coordinator
- Apply coordinated width animations to all 3 components (BetslipOddsBoostHeaderView, BetslipFloatingThinView, BetslipFloatingTallView)

### Achievements
- [x] Implemented coordinated width animation system (all segments resize simultaneously)
- [x] Created `ProgressSegmentCoordinator` - 210-line reusable coordinator class
- [x] Applied coordinator to `BetslipOddsBoostHeaderView` (saved ~145 lines)
- [x] Applied coordinator to `BetslipFloatingTallView` (saved ~58 lines)
- [x] User confirmed coordinator already applied to `BetslipFloatingThinView` (saved ~145 lines)
- [x] Eliminated ~348 lines of duplicated animation code across 3 components
- [x] Tested animations in interactive preview - all working correctly

### Issues / Bugs Hit
- [x] **Initial problem**: UIStackView with `.fillEqually` distribution caused instant repositioning when segments added/removed
  - Only the new/removed segment animated (alpha + scale)
  - Existing segments "jumped" to new positions without smooth transitions
- [x] **Root cause**: UIStackView automatically redistributes space, cannot animate width changes
- [x] **Solution**: Replaced UIStackView with manual constraint-based layout using animatable width constraints

### Key Decisions

#### 1. Coordinator Pattern (Solution 2) Over Protocol Extension (Solution 1)
**Why**: Explicit container passing eliminates hidden dependencies
- Coordinator receives `container: UIView` parameter explicitly
- Container bounds calculated in correct parent context
- No risk of accessing `bounds.width` before first layout pass
- Easier to debug (clear parameter flow)

#### 2. Manual Constraint Management
Replaced UIStackView with:
- Container UIView (holds segments)
- Width constraints array (animatable)
- Leading constraints array (chains segments with 2px gaps)
- Manual `layoutSegments()` method rebuilds constraints when needed

#### 3. Animation Strategy
**Add segment (3→4)**:
```
Time 0ms:
- Segment 0-2 width: 100px → 75px (shrink)
- Segment 3 width: 0px → 75px (grow from 0)
All animate together (0.3s, curveEaseOut)
```

**Remove segment (4→3)**:
```
Time 0ms:
- Segment 0-2 width: 75px → 100px (grow)
- Segment 3 width: 75px → 0px (shrink to 0)
All animate together (0.2s)
Completion: Remove segment 3 from superview
```

#### 4. Three Attempted Solutions
1. **Protocol + Extension** - Best for compile-time safety, but user preferred explicit approach
2. **Coordinator Object** ✅ - Chosen for explicit container passing, clear state ownership
3. **Self-Contained UIView** - Rejected due to potential first layout pass issues

### Experiments & Notes

#### Failed Approach (3 times previously)
User attempted to extract logic to shared component 3 times - each time animations broke because:
1. Creating separate UIView subclass → `bounds.width` was 0 initially
2. Using helper class → No `layoutSubviews()` integration
3. Moving constraint arrays out of parent → Animations couldn't find/modify them

#### Why Coordinator Works
- **Container bounds access**: Passed explicitly as parameter (`container.bounds.width`)
- **Layout lifecycle**: Parent's `layoutSubviews()` calls coordinator's `handleLayoutUpdate()`
- **Constraint references**: Coordinator owns arrays, maintains in-place modification
- **Animation context**: `container.layoutIfNeeded()` runs on correct view

#### Width Calculation Formula
```swift
func calculateSegmentWidth(for count: Int, containerWidth: CGFloat) -> CGFloat {
    guard count > 0 else { return 0 }
    let totalGaps = CGFloat(max(0, count - 1)) * 2.0  // 2px gaps
    return (containerWidth - totalGaps) / CGFloat(count)
}
```

### Useful Files / Links
- [ProgressSegmentCoordinator.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Shared/ProgressSegmentCoordinator.swift) (new, 210 lines)
- [BetslipOddsBoostHeaderView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderView.swift)
- [BetslipFloatingTallView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipFloatingView/BetslipFloatingTallView.swift)
- [BetslipFloatingThinView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipFloatingView/BetslipFloatingThinView.swift) (applied by user)
- [ProgressSegmentView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Shared/ProgressSegmentView.swift)
- [Previous Session: BetslipOddsBoostHeaderView Migration](./16-October-2025-betslip-odds-boost-header-migration.md)

### Architecture Breakdown

#### ProgressSegmentCoordinator API
```swift
final class ProgressSegmentCoordinator {
    private(set) var segments: [ProgressSegmentView] = []
    private var widthConstraints: [NSLayoutConstraint] = []
    private var leadingConstraints: [NSLayoutConstraint] = []

    // Width calculation
    func calculateSegmentWidth(for count: Int, containerWidth: CGFloat) -> CGFloat

    // Constraint setup
    func layoutSegments(in container: UIView, targetWidth: CGFloat? = nil)

    // Main update method
    func updateSegments(
        filledCount: Int,
        totalCount: Int,
        in container: UIView,
        animated: Bool = true
    )

    // Layout lifecycle
    func handleLayoutUpdate(containerWidth: CGFloat)
}
```

#### Component Integration Pattern
```swift
// 1. Properties
private lazy var progressSegmentsContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
}()
private let segmentCoordinator = ProgressSegmentCoordinator()

// 2. Setup
mainStackView.addArrangedSubview(progressSegmentsContainer)
progressSegmentsContainer.heightAnchor.constraint(equalToConstant: 8)

// 3. Update
private func updateProgressSegments(filledCount: Int, totalCount: Int, animated: Bool = true) {
    segmentCoordinator.updateSegments(
        filledCount: filledCount,
        totalCount: totalCount,
        in: progressSegmentsContainer,
        animated: animated
    )
}

// 4. Layout
public override func layoutSubviews() {
    super.layoutSubviews()
    segmentCoordinator.handleLayoutUpdate(
        containerWidth: progressSegmentsContainer.bounds.width
    )
}
```

### Code Metrics

#### Before Refactoring
- 3 components with duplicated animation logic
- ~348 lines of duplicated code total
- BetslipOddsBoostHeaderView: 333 lines (includes ~145 lines animation logic)
- BetslipFloatingThinView: 794 lines (includes ~145 lines animation logic)
- BetslipFloatingTallView: 395 lines (includes ~58 lines animation logic)

#### After Refactoring
- 1 shared coordinator: 210 lines
- BetslipOddsBoostHeaderView: ~188 lines (removed ~145 lines)
- BetslipFloatingThinView: ~649 lines (removed ~145 lines)
- BetslipFloatingTallView: ~337 lines (removed ~58 lines)
- **Net savings**: ~138 lines + perfect animation consistency

#### Lines Changed Per Component
**BetslipOddsBoostHeaderView**:
- Removed: 3 properties (progressSegments, widthConstraints, leadingConstraints)
- Removed: 2 helper methods (calculateSegmentWidth, layoutSegments) - 44 lines
- Removed: Complex updateProgressSegments() - 100 lines
- Added: 1 property (segmentCoordinator)
- Added: Simple updateProgressSegments() delegate - 7 lines
- Added: layoutSubviews() override - 8 lines

**BetslipFloatingTallView** (same pattern):
- Removed: progressSegmentsStackView, progressSegments array
- Removed: Complex updateProgressSegments() - 73 lines
- Added: progressSegmentsContainer, segmentCoordinator
- Added: Simple delegation + layoutSubviews()

### Animation Technical Details

#### Wave Fill Effect (Unchanged)
```swift
// 50ms stagger per segment (left-to-right)
for (index, segment) in segments.enumerated() {
    let shouldBeFilled = index < filledCount
    let delay = animated ? Double(index) * 0.05 : 0

    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        segment.setFilled(shouldBeFilled, animated: animated)
    }
}
```

#### Coordinated Width Animation (New)
```swift
// Add segment: All widths animate simultaneously
UIView.animate(
    withDuration: 0.3,
    delay: 0,
    options: [.curveEaseOut],
    animations: {
        self.widthConstraints.forEach { $0.constant = newTargetWidth }
        container.layoutIfNeeded()
    }
)

// Remove segment: Shrink to 0 + expand remaining
UIView.animate(
    withDuration: 0.2,
    animations: {
        // Shrink removed segments to 0
        for i in totalCount..<self.widthConstraints.count {
            self.widthConstraints[i].constant = 0
        }
        // Expand remaining segments
        for i in 0..<totalCount {
            self.widthConstraints[i].constant = newTargetWidth
        }
        container.layoutIfNeeded()
    }
)
```

### Testing Verification

**Interactive Preview Tests** (BetslipOddsBoostHeaderView):
✅ Add segment (3→4): All segments shrink smoothly, new segment grows from 0
✅ Remove segment (4→3): Rightmost shrinks to 0, others expand smoothly
✅ Fill segments: Wave effect works (50ms stagger)
✅ No jumping or instant repositioning
✅ All animations coordinated

**Expected Behavior in All 3 Components**:
- Segments resize proportionally when count changes
- No instant "jump" repositioning
- Smooth coordinated animations (all segments move together)
- Container resize (rotation) updates widths correctly

### Next Steps
1. ✅ **DONE** - Test BetslipFloatingTallView with coordinator in simulator
2. ✅ **DONE** - Verify BetslipFloatingThinView integration (user confirmed working)
3. Monitor for any animation issues in production usage
4. Consider adding coordinator documentation to GomaUI CLAUDE.md
5. Evaluate if other GomaUI components could benefit from similar coordinator pattern

### Related Context
- **Previous session**: Created BetslipOddsBoostHeaderView with initial coordinated animations
- **This session**: Extracted coordinator for reusability across 3 components
- **Architectural pattern**: Coordinator object with explicit container passing
- **GomaUI principle**: Share common logic while preserving animation context
- **Animation requirement**: Smooth coordinated transitions, no instant repositioning

### Technical Debt / Future Improvements
- [ ] Consider adding unit tests for ProgressSegmentCoordinator
- [ ] Document coordinator pattern in GomaUI architecture guide
- [ ] Explore if coordinator can be generalized for other animated constraint patterns
- [ ] Performance test with rapid segment updates (10+ per second)
- [ ] Add debug logging mode for troubleshooting animation issues
