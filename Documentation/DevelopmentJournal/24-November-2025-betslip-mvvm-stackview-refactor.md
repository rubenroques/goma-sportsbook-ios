# Development Journal

## Date
24 November 2025

### Project / Branch
sportsbook-ios / rr/boot_performance

### Goals for this session
- Understand BetslipViewController architecture and explain `shouldShowTypeSelector` logic
- Fix MVVM violations and constraint management issues
- Refactor to use UIStackView-based layout

### Achievements
- [x] Explained complete BetslipViewController architecture (headerView, typeSelectorView, MVVM flow)
- [x] Removed `shouldShowTypeSelector` cached state from ViewController (MVVM violation)
- [x] Moved `shouldShowTypeSelector` from BetslipData struct to ViewModel property
- [x] Replaced fragile manual constraint management with UIStackView-based layout
- [x] Fixed UIStackView arranged subview constraint conflict using container pattern
- [x] Reduced code from 287 lines to ~250 lines, removed 24-line `updateConstraints()` method

### Issues / Bugs Hit
- [x] MVVM violation: ViewController cached `shouldShowTypeSelector` property instead of reading from ViewModel
- [x] Breaking constraint management: Manual activate/deactivate logic was fragile and causing layout issues
- [x] UIStackView constraint conflict: Attempted to constrain arranged subview directly (invalid pattern)
- [x] Architecture confusion: Static configuration mixed with dynamic state in BetslipData struct

### Key Decisions
- **Separated configuration from state**: `shouldShowTypeSelector` is now a computed ViewModel property (from `betslipConfiguration`), not part of published `BetslipData`
- **UIStackView for layout**: Replaced manual constraint juggling with declarative stack-based layout
- **Container pattern for insets**: Added `typeSelectorContainer` to hold `typeSelectorView` with 16pt horizontal insets (correct UIStackView pattern)
- **Single source of truth**: ViewController reads `viewModel.shouldShowTypeSelector` directly, no caching or observation needed

### Experiments & Notes
- **Initial approach (wrong)**: Tried to constrain `typeSelectorView` leading/trailing while it was an arranged subview → constraint conflict
- **Container pattern (correct)**: Container is arranged subview (stack manages width), type selector constrained to container (we control insets)
- **One-time setup**: Configuration doesn't change at runtime, so set `typeSelectorContainer.isHidden` once in `viewDidLoad()` instead of observing changes

### Architecture Improvements

**Before:**
```swift
// MVVM violation - cached state in VC
private var shouldShowTypeSelector: Bool?

// Fragile constraint management
private func updateConstraints() {
    NSLayoutConstraint.deactivate(...)  // 24 lines of manual constraint handling
    if shouldShowTypeSelector == true {
        NSLayoutConstraint.activate([...])
    } else {
        NSLayoutConstraint.activate([...])
    }
}

// Configuration mixed with dynamic state
public struct BetslipData: Equatable {
    public let isEnabled: Bool
    public let tickets: [BettingTicket]
    public let shouldShowTypeSelector: Bool  // ❌ Static config!
}
```

**After:**
```swift
// ✅ Clean MVVM - no cached state
// ✅ Direct property access from ViewModel

// Simple UIStackView layout
private lazy var contentStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 0
    return stack
}()

// Container pattern for insets
contentStackView.addArrangedSubview(typeSelectorContainer)
typeSelectorContainer.addSubview(typeSelectorView)

// One-time configuration setup
typeSelectorContainer.isHidden = !viewModel.shouldShowTypeSelector

// Pure dynamic state
public struct BetslipData: Equatable {
    public let isEnabled: Bool
    public let tickets: [BettingTicket]
}

// Configuration as ViewModel property
public var shouldShowTypeSelector: Bool {
    betslipConfiguration.shouldShowTypeSelector
}
```

### Useful Files / Links
- [BetslipViewController.swift](BetssonCameroonApp/App/Screens/Betslip/BetslipViewController.swift)
- [BetslipViewModelProtocol.swift](BetssonCameroonApp/App/Screens/Betslip/BetslipViewModelProtocol.swift)
- [BetslipViewModel.swift](BetssonCameroonApp/App/Screens/Betslip/BetslipViewModel.swift)
- [BetslipConfiguration.swift](BetssonCameroonApp/App/Models/Configs/BetslipConfiguration.swift)
- [BetslipHeaderView.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipHeaderView/BetslipHeaderView.swift)
- [BetslipTypeSelectorView.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipTypeSelectorView/BetslipTypeSelectorView.swift)

### Next Steps
1. Test betslip layout with type selector visible (uncomment virtual betslip tab in config)
2. Test betslip layout with type selector hidden (current state - only sports tab)
3. Verify no constraint conflicts in console logs
4. Test page swiping behavior (should only work when type selector is visible)
5. Consider applying same UIStackView pattern to other ViewControllers with dynamic layout needs

### Technical Learnings
- **UIStackView golden rule**: Never constrain arranged subviews' position/size relative to external views - use container pattern instead
- **MVVM separation**: Configuration (static, read once) vs State (dynamic, observe changes)
- **SwiftUI thinking in UIKit**: Declarative layout (UIStackView) reduces bugs compared to imperative constraint management
