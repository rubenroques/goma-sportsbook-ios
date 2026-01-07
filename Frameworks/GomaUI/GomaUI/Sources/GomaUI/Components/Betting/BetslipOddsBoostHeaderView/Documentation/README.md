# BetslipOddsBoostHeaderView

A header component that displays odds boost promotion with animated progress tracking, designed to be positioned at the top of the betslip to encourage users to add more qualifying selections.

## Architecture

**Pattern**: MVVM with Combine publishers
**Parent**: UIView
**Protocol**: `BetslipOddsBoostHeaderViewModelProtocol`
**Shared Component**: Uses `ProgressSegmentView` from `Components/Shared/`

## Visual Design

Matches Figma specification with three sections:

1. **Title**: "You're almost there!" (12px bold orange)
2. **Icon + Text Stack**: 32x32 boost icon + heading + description
3. **Progress Segments**: Animated progress bar (8px height, 2px gaps)

```
┌─────────────────────────────────────────┐
│ [16px padding all sides]                │
│                                         │
│  You're almost there!  (12px bold ●)   │ ← Section 1
│  [16px gap]                            │
│  ┌────┐  Get a 3% Win Boost (16px B)  │ ← Section 2
│  │ 🎁 │  by adding 2 more legs to     │
│  └────┘  your betslip (1.2 min odds). │
│  32x32   (12px regular gray)           │
│  [16px gap]                            │
│  ████████ ░░░░░░░░ ░░░░░░░░           │ ← Section 3
│                                         │
└─────────────────────────────────────────┘
```

## State Management

**Component displays odds boost data only.** ViewController is responsible for showing/hiding the entire component based on whether odds boost is available.

The state struct contains:
- **Selection count** - Current qualifying selections in betslip
- **Total eligible count** - Selections needed to reach boost
- **Next tier percentage** - Next boost level (e.g., "5%")
- **Current boost percentage** - Current boost if max reached

The component always renders when visible - there is no "hidden" state in the data model.

## Usage

### Basic Implementation

```swift


class BetslipViewController: UIViewController {
    private let viewModel = BetslipOddsBoostHeaderViewModel()
    private lazy var headerView = BetslipOddsBoostHeaderView(viewModel: viewModel)
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupBindings()
    }

    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    private func setupBindings() {
        // Handle tap events
        viewModel.onHeaderTapped = { [weak self] in
            self?.expandBetslipDetails()
        }
    }

    private func expandBetslipDetails() {
        // Navigate or expand betslip
    }
}
```

### Updating State

```swift
// From betslip manager updates - ViewController manages visibility
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
            self?.headerView.isHidden = false
        } else {
            self?.headerView.isHidden = true
        }
    }
    .store(in: &cancellables)
```

## Protocol

```swift
public protocol BetslipOddsBoostHeaderViewModelProtocol {
    var dataPublisher: AnyPublisher<BetslipOddsBoostHeaderData, Never> { get }
    var currentData: BetslipOddsBoostHeaderData { get }
    func updateState(_ state: BetslipOddsBoostHeaderState)
    func setEnabled(_ isEnabled: Bool)
    var onHeaderTapped: (() -> Void)? { get set }
}
```

### State Struct

```swift
public struct BetslipOddsBoostHeaderState: Equatable {
    public let selectionCount: Int           // Current selections
    public let totalEligibleCount: Int       // Required for boost
    public let nextTierPercentage: String?   // e.g., "5%"
    public let currentBoostPercentage: String? // e.g., "10%" when max reached
}
```

## Animation Features

### Wave Effect Progress
Segments fill with 50ms stagger for smooth wave animation:

```swift
// Automatic when state updates
let newState = BetslipOddsBoostHeaderState(
    selectionCount: 2,  // Will animate from 1 to 2
    totalEligibleCount: 3,
    nextTierPercentage: "5%",
    currentBoostPercentage: nil
)
viewModel.updateState(newState)
```

### Add/Remove Segments
Smooth scale + fade transitions when segment count changes:
- New segments fade in from 0.3 scale
- Removed segments fade out to 0.3 scale

## Shared Component

**ProgressSegmentView** is located in `Components/Shared/ProgressSegmentView.swift` and is reused by:
- BetslipFloatingThinView
- BetslipOddsBoostHeaderView

## Layout Guidelines

### Header Position (Recommended)
```swift
// Top of betslip, below navigation
NSLayoutConstraint.activate([
    headerView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 16),
    headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
])
```

### Fixed Height (Optional)
```swift
// Component height adapts to content, but can be constrained if needed
headerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
```

## Related Components

- **BetslipFloatingThinView**: Compact floating betslip indicator (uses same protocol data)
- **ProgressSegmentView**: Shared animated progress segment (`Components/Shared/`)

## Testing

### Mock Factory Methods

```swift
// Active with progress
let viewModel = MockBetslipOddsBoostHeaderViewModel.activeMock(
    selectionCount: 1,
    totalEligibleCount: 3,
    nextTierPercentage: "3%"
)

// Max boost reached
let viewModel = MockBetslipOddsBoostHeaderViewModel.maxBoostMock()

// Disabled state (component visible but not interactive)
let viewModel = MockBetslipOddsBoostHeaderViewModel.disabledMock(
    selectionCount: 1,
    totalEligibleCount: 3
)
```

### SwiftUI Previews

```swift
@available(iOS 17.0, *)
#Preview("Header - Progress 1/3") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let headerView = BetslipOddsBoostHeaderView(
            viewModel: MockBetslipOddsBoostHeaderViewModel.activeMock(
                selectionCount: 1,
                totalEligibleCount: 3,
                nextTierPercentage: "3%"
            )
        )
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        return vc
    }
}
```

## Important Design Decisions

### 1. Visibility Management
**Component does NOT hide itself** - the parent ViewController is responsible for showing/hiding the entire component based on whether odds boost data is available. This separation of concerns allows:
- ViewController to coordinate multiple UI elements
- Custom visibility animations
- Complex visibility logic (e.g., user preferences, A/B testing)

### 2. Shared ProgressSegmentView
Originally duplicated, now consolidated to `Components/Shared/` for:
- Single source of truth
- Consistent animations across components
- Reduced code duplication (55 lines saved)

### 3. No Odds Display
Unlike `BetslipFloatingThinView`, this header focuses solely on odds boost promotion. Current odds are not displayed as they're shown elsewhere in the betslip.

### 4. Struct Instead of Enum
State is a struct, not an enum with cases, since component only displays data when visible. This provides:
- Simpler API - direct property access instead of switch statements
- Cleaner construction - no need to wrap in enum case
- Better Swift practices - structs for data, enums for variants

## Migration History

- **Extracted from**: `BetslipFloatingTallView` (October 16, 2025)
- **Purpose**: Dedicated betslip header component with focused data model
- **Key Changes**:
  - Replaced enum with struct (no `.hidden` case)
  - Removed `odds` display (not needed in header)
  - Visibility management delegated to parent ViewController
  - Simplified render logic (no switch statement needed)
