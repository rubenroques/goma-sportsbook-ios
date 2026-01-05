# BetslipTypeTabItemView

An individual tab item for betslip type selection with icon and label.

## Overview

BetslipTypeTabItemView represents a single tab option within BetslipTypeSelectorView. It displays an icon and title with visual feedback for selected/unselected states. The component includes an animated bottom indicator line that highlights the selected state.

## Component Relationships

### Used By (Parents)
- `BetslipTypeSelectorView` - container managing multiple tab items

### Uses (Children)
- None (leaf component)

## Features

- Icon and title horizontal layout (centered)
- Selected/unselected visual states with animation
- Bottom indicator line (3pt height) for selected state
- Custom or SF Symbol icon support
- Tap gesture for selection
- 0.3s animated state transitions

## Usage

```swift
let viewModel = MockBetslipTypeTabItemViewModel.sportsSelectedMock()
let tabItemView = BetslipTypeTabItemView(viewModel: viewModel)

viewModel.onTabTapped = {
    print("Tab tapped")
}
```

## Data Model

```swift
protocol BetslipTypeTabItemViewModelProtocol {
    var title: String { get }
    var icon: String { get }
    var isSelected: Bool { get }
    var onTabTapped: (() -> Void)? { get set }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - selected icon, title, and indicator colors
- `StyleProvider.Color.textPrimary` - unselected icon and title colors
- `StyleProvider.Color.textSecondary` - default icon/title tint
- `StyleProvider.Color.separatorLineSecondary` - unselected indicator color
- `StyleProvider.fontWith(type: .semibold, size: 16)` - title font

## Mock ViewModels

Available presets:
- `.sportsSelectedMock()` - "Sports" with sportscourt icon, selected
- `.sportsUnselectedMock()` - "Sports" with sportscourt icon, unselected
- `.virtualsSelectedMock()` - "Virtuals" with gamecontroller icon, selected
- `.virtualsUnselectedMock()` - "Virtuals" with gamecontroller icon, unselected
