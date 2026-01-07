# QuickAddButtonView

A quick-add amount button for bet submission forms.

## Overview

QuickAddButtonView displays a compact button that adds a preset amount to the current stake/bet value. It shows a "+" prefix followed by the amount value. The component is commonly used in betslip stake entry to quickly add common amounts (100, 250, 500, etc.) to the current bet value.

## Component Relationships

### Used By (Parents)
- `BetInfoSubmissionView`

### Uses (Children)
- None (leaf component)

## Features

- Amount display with "+" prefix
- Enabled/disabled states
- Tap callback via closure
- Input background styling
- Rounded corners (4pt)
- Alpha-based disabled state (0.5)
- Reactive updates via Combine publishers
- Synchronous initial rendering

## Usage

```swift
let viewModel = MockQuickAddButtonViewModel.amount100Mock()
let quickAddButton = QuickAddButtonView(viewModel: viewModel)

// Handle button tap
viewModel.onButtonTapped = {
    addToStake(100)
}

// Update amount
viewModel.updateAmount(200)

// Disable button
viewModel.setEnabled(false)
```

## Data Model

```swift
struct QuickAddButtonData: Equatable {
    let amount: Int
    let isEnabled: Bool
}

protocol QuickAddButtonViewModelProtocol {
    var dataPublisher: AnyPublisher<QuickAddButtonData, Never> { get }
    var currentData: QuickAddButtonData { get }
    var onButtonTapped: (() -> Void)? { get set }

    func updateAmount(_ amount: Int)
    func setEnabled(_ isEnabled: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textPrimary` - button title color
- `StyleProvider.Color.inputBackground` - button background
- `StyleProvider.fontWith(type: .bold, size: 12)` - button title font

Layout constants:
- Corner radius: 4pt
- Button fills parent container

Visual states:
- **Enabled**: Full alpha (1.0), interactive
- **Disabled**: Reduced alpha (0.5), non-interactive

Button title format:
- Displays as "+{amount}" (e.g., "+100", "+250", "+500")

## Mock ViewModels

Available presets:
- `.amount100Mock()` - +100 button
- `.amount250Mock()` - +250 button
- `.amount500Mock()` - +500 button
- `.disabledMock()` - +100 button, disabled
