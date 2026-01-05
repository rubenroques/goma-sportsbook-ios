# BetslipOddsBoostHeaderView

A header displaying odds boost promotion progress within the betslip.

## Overview

BetslipOddsBoostHeaderView shows the user's progress toward earning an odds boost on their bet. It displays a boost icon, heading text describing the next tier, description with remaining selections needed, and animated progress segments. The ViewController managing this component controls its visibility based on boost availability.

## Component Relationships

### Used By (Parents)
- None (standalone component, typically positioned below BetslipHeaderView)

### Uses (Children)
- `ProgressSegments` (internal) - animated progress bar segments

## Features

- Boost icon with tier information
- Pre-assembled heading and description text from ViewModel
- Animated progress segment bar
- Tap gesture for additional interaction
- Enabled/disabled state with alpha dimming
- Auto-layout with 16pt padding
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockBetslipOddsBoostHeaderViewModel.activeMock(
    selectionCount: 2,
    totalEligibleCount: 3,
    headingText: "Get 5% win boost"
)
let headerView = BetslipOddsBoostHeaderView(viewModel: viewModel)
```

## Data Model

```swift
struct BetslipOddsBoostHeaderState: Equatable {
    let selectionCount: Int           // Current selections
    let totalEligibleCount: Int       // Selections needed for boost
    let minOdds: String?              // Minimum odds requirement
    let headingText: String           // Pre-assembled by ViewModel
    let descriptionText: String       // Pre-assembled by ViewModel
}

struct BetslipOddsBoostHeaderData: Equatable {
    let state: BetslipOddsBoostHeaderState
    let isEnabled: Bool
}

protocol BetslipOddsBoostHeaderViewModelProtocol {
    var dataPublisher: AnyPublisher<BetslipOddsBoostHeaderData, Never> { get }
    var currentData: BetslipOddsBoostHeaderData { get }
    func updateState(_ state: BetslipOddsBoostHeaderState)
    func setEnabled(_ isEnabled: Bool)
    var onHeaderTapped: (() -> Void)? { get set }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundGradient2` - container background
- `StyleProvider.Color.highlightPrimary` - title and boost icon color
- `StyleProvider.Color.textPrimary` - heading text color
- `StyleProvider.Color.textSecondary` - description text color
- `StyleProvider.fontWith(type: .bold, size: 12)` - title font
- `StyleProvider.fontWith(type: .bold, size: 16)` - heading font
- `StyleProvider.fontWith(type: .regular, size: 12)` - description font

## Mock ViewModels

Available presets:
- `.activeMock(selectionCount:totalEligibleCount:headingText:)` - progress state
- `.maxBoostMock()` - all selections complete, max boost reached
