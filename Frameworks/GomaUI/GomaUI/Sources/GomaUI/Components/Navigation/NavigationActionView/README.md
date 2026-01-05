# NavigationActionView

A tappable navigation action row with title and trailing icon.

## Overview

NavigationActionView displays a simple navigation action with a title on the left and an icon on the right. It's commonly used for actions like "Open Betslip Details" or "Share your Betslip". The component supports enabled/disabled states and uses either custom or SF Symbols icons.

## Component Relationships

### Used By (Parents)
- Betslip screens
- Action sheets
- Menu lists

### Uses (Children)
- None (leaf component)

## Features

- Title label (left-aligned)
- Trailing icon (right-aligned)
- SF Symbols and custom image support
- Enabled/disabled states (alpha 0.5 when disabled)
- Tap gesture with callback
- 48pt fixed height
- Rounded container (8pt)
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockNavigationActionViewModel.openBetslipDetailsMock()
let actionView = NavigationActionView(viewModel: viewModel)

// Note: Tap handling is done through the ViewModel
// The view calls viewModel.onNavigationTapped() when tapped

// Update title dynamically
viewModel.updateTitle("View Details")

// Update icon
viewModel.updateIcon("arrow.right")

// Disable the action
viewModel.setEnabled(false)
```

## Data Model

```swift
struct NavigationActionData: Equatable {
    let title: String
    let icon: String?        // SF Symbol name or custom image name
    let isEnabled: Bool
}

protocol NavigationActionViewModelProtocol {
    var dataPublisher: AnyPublisher<NavigationActionData, Never> { get }
    var currentData: NavigationActionData { get }

    func updateTitle(_ title: String)
    func updateIcon(_ icon: String?)
    func setEnabled(_ isEnabled: Bool)
    func onNavigationTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - container background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.highlightPrimary` - icon tint color
- `StyleProvider.fontWith(type: .semibold, size: 12)` - title font

Layout constants:
- Container height: 48pt
- Container corner radius: 8pt
- Horizontal padding: 16pt
- Icon size: 22pt x 22pt
- Title-to-icon gap: 12pt minimum

Icon resolution:
1. First tries custom image (UIImage(named:))
2. Falls back to SF Symbol (UIImage(systemName:))

## Mock ViewModels

Available presets:
- `.openBetslipDetailsMock()` - "Open Betslip Details" with chevron.right
- `.shareBetslipMock()` - "Share your Betslip" with square.and.arrow.up
- `.disabledMock()` - "Disabled Action" with chevron.right, disabled state
