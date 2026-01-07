# ActionButtonBlockView

A styled action button for promotional content blocks with customizable title and enabled state.

## Overview

ActionButtonBlockView displays a prominent call-to-action button typically used in promotional sections, bonus claims, and marketing content blocks. It supports enabled/disabled states and delegates tap actions to the view model.

## Component Relationships

### Used By (Parents)
- None (standalone component)

### Uses (Children)
- None (leaf component)

## Features

- Customizable button title through view model
- Enabled/disabled state support
- Rounded corners with fixed 8pt corner radius
- Horizontal padding with 15pt margins
- Fixed height of 50pt for consistent layout
- Action URL support for navigation

## Usage

```swift
let viewModel = MockActionButtonBlockViewModel.defaultMock
let buttonView = ActionButtonBlockView(viewModel: viewModel)
```

## Data Model

```swift
protocol ActionButtonBlockViewModelProtocol {
    var title: String { get }
    var actionName: String { get }
    var actionURL: String? { get }
    var isEnabled: Bool { get }

    func didTapActionButton()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - button background color
- `StyleProvider.Color.buttonTextPrimary` - button text color
- `StyleProvider.fontWith(type: .semibold, size: 16)` - button title font

## Mock ViewModels

Available presets:
- `.defaultMock` - enabled button with "Claim Bonus" title
- `.disabledMock` - disabled button for unavailable actions
- `.longTextMock` - button with longer "Get Your Welcome Bonus Now" title
