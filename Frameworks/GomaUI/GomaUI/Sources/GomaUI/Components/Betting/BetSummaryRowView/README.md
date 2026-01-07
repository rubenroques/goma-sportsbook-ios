# BetSummaryRowView

A single row displaying a title-value pair for bet summary information.

## Overview

BetSummaryRowView displays a horizontal row with a left-aligned title and right-aligned value, commonly used for showing bet odds, potential winnings, bonuses, and payout amounts. The component supports enabled/disabled states with visual feedback.

## Component Relationships

### Used By (Parents)
- `BetInfoSubmissionView` - displays odds, potential winnings, win bonus, and payout rows

### Uses (Children)
- None (leaf component)

## Features

- Left-aligned title with semibold styling
- Right-aligned value with bold styling
- Enabled/disabled state with alpha dimming (0.5)
- Reactive updates via Combine publisher
- Minimal layout with flexible width between title and value

## Usage

```swift
let viewModel = MockBetSummaryRowViewModel.potentialWinningsMock()
let rowView = BetSummaryRowView(viewModel: viewModel)
```

## Data Model

```swift
struct BetSummaryRowData: Equatable {
    let title: String
    let value: String
    let isEnabled: Bool
}

protocol BetSummaryRowViewModelProtocol {
    var dataPublisher: AnyPublisher<BetSummaryRowData, Never> { get }
    var currentData: BetSummaryRowData { get }

    func updateTitle(_ title: String)
    func updateValue(_ value: String)
    func setEnabled(_ isEnabled: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textPrimary` - both title and value text color
- `StyleProvider.fontWith(type: .semibold, size: 10)` - title font
- `StyleProvider.fontWith(type: .bold, size: 12)` - value font

## Mock ViewModels

Available presets:
- `.oddsMock()` - "ODDS" / "0.00"
- `.potentialWinningsMock()` - "POTENTIAL WINNINGS" / "XAF 0"
- `.winBonusMock()` - "X% WIN BONUS" / "XAF 0"
- `.payoutMock()` - "PAYOUT" / "XAF 0"
- `.disabledMock()` - "TITLE" / "VALUE" with isEnabled: false
