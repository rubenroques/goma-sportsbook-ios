# UserLimitCardView

A user limit display card showing limit type, value, and a removal action button.

## Overview

UserLimitCardView displays a responsible gambling limit entry with the limit type (e.g., "Daily", "Weekly"), the limit value (e.g., "5 XAF"), and an action button for removing or modifying the limit. The component is used in responsible gambling settings screens where users can manage their deposit, loss, or wagering limits.

## Component Relationships

### Used By (Parents)
- Responsible gambling settings screens
- Limit management views
- Account limits sections

### Uses (Children)
- `ButtonView` - for the action button

## Features

- Limit type label (bold)
- Limit value label (bold)
- Action button (customizable style and color)
- Horizontal layout with info and button
- Action tap callback with limit ID
- Disabled state support for button

## Usage

```swift
let viewModel = MockUserLimitCardViewModel.removalMock()
let limitCard = UserLimitCardView(viewModel: viewModel)

// Handle action tap
limitCard.onActionTapped = { limitId in
    removeLimit(id: limitId)
}

// Disabled button state
let disabledViewModel = MockUserLimitCardViewModel.disabledMock()
let disabledCard = UserLimitCardView(viewModel: disabledViewModel)
```

## Data Model

```swift
protocol UserLimitCardViewModelProtocol: AnyObject {
    var limitId: String { get }
    var typeText: String { get }
    var valueText: String { get }
    var actionButtonViewModel: ButtonViewModelProtocol { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - container background
- `StyleProvider.Color.textPrimary` - type and value labels
- `StyleProvider.Color.alertError` - default action button background
- `StyleProvider.fontWith(type: .bold, size: 14)` - type and value fonts

Layout constants:
- Container padding: 12pt vertical
- Stack spacing: 16pt horizontal
- Action button height: 35pt
- Action button min width: 100pt
- Info stack spacing: 4pt vertical

Stack configuration:
- Main: horizontal, center aligned
- Info: vertical, leading aligned

## Mock ViewModels

Available presets:
- `.removalMock()` - Daily limit with "Remove" button
- `.disabledMock()` - Weekly limit with disabled button

Factory initialization:
```swift
MockUserLimitCardViewModel(
    limitId: String = UUID().uuidString,
    typeText: String = "Daily",
    valueText: String = "5.0 XAF",
    actionButtonTitle: String = "Remove",
    buttonStyle: ButtonStyle = .solidBackground
)
```
