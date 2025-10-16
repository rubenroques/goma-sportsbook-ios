# Betslip Odds Boost Header Component Migration

## Date
16 October 2025

### Project / Branch
sportsbook-ios / rr/oddsboost_ui

### Goals for this session
- Extract `BetslipFloatingTallView` into independent `BetslipOddsBoostHeaderView` component
- Simplify state model (remove `.hidden` case, replace enum with struct)
- Consolidate duplicate `ProgressSegmentView` into shared location
- Add component to GomaUIDemo with interactive demo controller

### Achievements
- [x] Created new component folder structure with proper file organization
- [x] Extracted and renamed component from `BetslipFloatingTallView` to `BetslipOddsBoostHeaderView`
- [x] Simplified state model from enum to struct (removed `.hidden` case, simplified API)
- [x] Consolidated `ProgressSegmentView` to `Components/Shared/` (eliminated 55-line duplication)
- [x] Created protocol with focused data model (removed `odds` display, simplified to 4 properties)
- [x] Implemented mock ViewModel with factory methods (`activeMock()`, `maxBoostMock()`, `disabledMock()`)
- [x] Added component to GomaUIDemo ComponentRegistry (Betting & Sports category)
- [x] Created interactive demo view controller with segmented control (3 states: 1/3, 2/3, Max)
- [x] Updated 3 SwiftUI previews (removed hidden state preview)
- [x] Created comprehensive documentation (README.md with usage examples, protocol docs, testing guide)
- [x] Removed containerView shadow/corner styling per user feedback (cleaner appearance)

### Issues / Bugs Hit
- [x] **Git lock file conflict** - `.git/index.lock` existed, removed manually
- [x] **File not under version control** - `ProgressSegmentView` not tracked by git, used `mv` instead of `git mv`
- [x] **Initial duplicate ProgressSegmentView** - Created in both component folders, consolidated to Shared

### Key Decisions
- **Component name**: `BetslipOddsBoostHeaderView` - clearly indicates betslip context, odds boost purpose, and header positioning
- **State model**: Replaced single-case enum with struct for cleaner API (no `.hidden` case)
  - Reason: Component only displays data when visible, ViewController manages visibility
  - Benefits: No switch statements, direct property access, simpler construction
- **Shared ProgressSegmentView**: Moved to `Components/Shared/` instead of duplicating
  - Eliminates 55 lines of code duplication
  - Single source of truth for progress animations
  - Follows GomaUI architecture patterns
- **Visibility management**: Delegated to parent ViewController, component doesn't self-hide
  - Separation of concerns: component displays data, ViewController controls visibility
  - Allows custom visibility animations and complex logic (A/B testing, user preferences)
- **No odds display**: Header focuses solely on odds boost promotion (unlike `BetslipFloatingThinView`)
- **Removed shadow/corner radius**: ContainerView styling simplified based on user feedback

### Experiments & Notes
- **Protocol-driven MVVM**: Component uses protocol interface for flexibility
- **Wave effect animation**: Progress segments fill with 50ms stagger for smooth visual feedback
- **Diff-based segment updates**: Only adds/removes segments when count changes, smooth scale + fade transitions
- **SwiftUI preview support**: Uses `PreviewUIViewController` wrapper for better AutoLayout rendering
- **Demo controller patterns**: Segmented control for state switching, toggle for enabled/disabled, info label for state display

### Useful Files / Links
- [BetslipOddsBoostHeaderView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderView.swift)
- [BetslipOddsBoostHeaderViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderViewModelProtocol.swift)
- [MockBetslipOddsBoostHeaderViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/MockBetslipOddsBoostHeaderViewModel.swift)
- [Shared/ProgressSegmentView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Shared/ProgressSegmentView.swift)
- [BetslipOddsBoostHeaderViewController.swift](../../Frameworks/GomaUI/Demo/Components/BetslipOddsBoostHeaderViewController.swift)
- [ComponentRegistry.swift](../../Frameworks/GomaUI/Demo/Components/ComponentRegistry.swift)
- [Documentation/README.md](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/Documentation/README.md)
- [Previous Session: BetslipFloatingView Thin/Tall Variants](./16-October-2025-betslip-floating-view-thin-tall-variants.md)

### Architecture Breakdown

#### Component Files (4 files)
```
BetslipOddsBoostHeaderView/
├── BetslipOddsBoostHeaderView.swift (333 lines)
│   - Main UIView implementation
│   - 3 sections: title label, icon+text stack, progress segments
│   - Simplified render() with direct property access
│
├── BetslipOddsBoostHeaderViewModelProtocol.swift (52 lines)
│   - State struct (4 properties): selectionCount, totalEligibleCount, nextTierPercentage, currentBoostPercentage
│   - Data wrapper struct with isEnabled flag
│   - Protocol with dataPublisher, updateState, setEnabled, onHeaderTapped
│
├── MockBetslipOddsBoostHeaderViewModel.swift (84 lines)
│   - Production-ready mock with factory methods
│   - activeMock(), maxBoostMock(), disabledMock()
│
└── Documentation/
    └── README.md (269 lines)
        - Comprehensive usage guide
        - Protocol documentation
        - Code examples
        - Testing patterns
```

#### Shared Component
```
Components/Shared/
└── ProgressSegmentView.swift (55 lines)
    - Reusable animated progress segment
    - Used by BetslipFloatingThinView and BetslipOddsBoostHeaderView
    - Wave effect with 50ms stagger
```

#### Demo App Integration
```
Demo/Components/
├── BetslipOddsBoostHeaderViewController.swift (163 lines)
│   - Interactive state switcher (segmented control)
│   - Enabled/disabled toggle
│   - State info display
│   - Tap event demo
│
└── ComponentRegistry.swift
    - Added to bettingSportsComponents array
    - Preview factory with activeMock(selectionCount: 1, totalEligibleCount: 3)
```

### State Model Evolution

**Before: Enum with cases**
```swift
public enum BetslipOddsBoostHeaderState: Equatable {
    case hidden
    case active(
        selectionCount: Int,
        totalEligibleCount: Int,
        nextTierPercentage: String?,
        currentBoostPercentage: String?
    )
}

// Usage in render():
switch data.state {
    case .hidden: break
    case .active(let count, let eligible, let next, let current):
        // Update UI
}
```

**After: Struct with properties**
```swift
public struct BetslipOddsBoostHeaderState: Equatable {
    public let selectionCount: Int
    public let totalEligibleCount: Int
    public let nextTierPercentage: String?
    public let currentBoostPercentage: String?
}

// Usage in render():
let state = data.state
headingLabel.text = state.currentBoostPercentage ?? "Get a \(state.nextTierPercentage) Win Boost"
updateProgressSegments(filledCount: state.selectionCount, totalCount: state.totalEligibleCount)
```

**Benefits:**
- No switch statements needed
- Direct property access
- Cleaner construction: `BetslipOddsBoostHeaderState(selectionCount: 2, totalEligibleCount: 3, ...)`
- Reduced protocol file from ~43 lines to ~52 lines (with better documentation)
- Follows Swift best practices: structs for data, enums for variants

### ViewController Responsibility Pattern

```swift
// ViewController manages visibility based on data availability
betslipManager.oddsBoostPublisher
    .sink { [weak self, weak viewModel] boostData in
        if let boost = boostData {
            let state = BetslipOddsBoostHeaderState(
                selectionCount: boost.currentSelections,
                totalEligibleCount: boost.requiredSelections,
                nextTierPercentage: boost.nextTierBoost,
                currentBoostPercentage: boost.currentBoost
            )
            viewModel?.updateState(state)
            self?.headerView.isHidden = false  // ViewController controls visibility
        } else {
            self?.headerView.isHidden = true   // Hide when no boost available
        }
    }
    .store(in: &cancellables)
```

### Related Context
- **Odds boost data pipeline**: Already implemented in previous session (BetslipManager → ViewModel → UI)
- **BetslipFloatingThinView**: Compact horizontal variant (unchanged, continues to use shared ProgressSegmentView)
- **StyleProvider integration**: All colors/fonts use StyleProvider (no hardcoded values)
- **GomaUI component standards**: Follows protocol-driven MVVM, mock implementations, SwiftUI previews

### Next Steps
1. **Production ViewModel**: Create production ViewModel that connects to BetslipManager.oddsBoostStairsPublisher
2. **Betslip screen integration**: Add header to betslip ViewController (top position, below navigation)
3. **Localization**: Add string localizations for all hardcoded text (6 strings: title, heading variants, description variants)
4. **Testing**: Test component in simulator with real odds boost data
5. **Animation tuning**: Verify wave effect timing feels natural with real betslip interactions
6. **Accessibility**: Add VoiceOver labels for progress segments and interactive elements
7. **Consider deprecation**: Evaluate if `BetslipFloatingTallView` should be deprecated now that header component exists

### Technical Debt / Future Improvements
- [ ] Extract magic numbers to constants (16px padding, 32px icon size, 8px segment height, 12px gap)
- [ ] Consider custom icon asset instead of fallback to `flame.fill` system icon
- [ ] Add unit tests for progress segment diff calculation logic
- [ ] Document ViewController integration pattern in main GomaUI README
- [ ] Performance test: Profile with rapid state changes (10+ updates per second)
- [ ] Consider extracting wave animation timing to StyleProvider for consistency

### Code Metrics
- **Files created**: 7 (4 component files, 1 demo controller, 1 shared component, 1 documentation)
- **Files modified**: 2 (ComponentRegistry.swift, previous BetslipFloatingView documentation reference)
- **Lines added**: ~900 (component: 333, protocol: 52, mock: 84, demo: 163, docs: 269)
- **Lines removed**: ~55 (eliminated duplicate ProgressSegmentView)
- **Net impact**: +845 lines for complete independent component with full documentation
