# SquareSeeMoreView

A square "See More" card matching casino game grid dimensions.

## Overview

SquareSeeMoreView displays a simple, tappable "See More" card that matches the size of CasinoGameImageView (100pt x 100pt). It shows a chevron icon and localized "See More" text, and is typically used as the last item in a casino game grid to navigate to the full category listing. The component supports tap callbacks via the view model.

## Component Relationships

### Used By (Parents)
- Casino game grids
- Game category sections

### Uses (Children)
- None (leaf component)

## Features

- Fixed 100pt x 100pt size
- Centered chevron icon (24pt)
- Localized "See More" label
- Rounded corners (16pt)
- Tap gesture with callback
- Card background styling
- Optional ViewModel for tap handling

## Usage

```swift
let viewModel = MockSquareSeeMoreViewModel.default
let seeMoreView = SquareSeeMoreView(viewModel: viewModel)

// With tap callback
let interactiveVM = MockSquareSeeMoreViewModel.interactive
interactiveVM.onSeeMoreTapped = {
    navigateToFullCategory()
}
let interactiveView = SquareSeeMoreView(viewModel: interactiveVM)

// Without ViewModel (placeholder)
let placeholderView = SquareSeeMoreView()

// Reconfigure for reuse
seeMoreView.configure(with: newViewModel)
```

## Data Model

```swift
protocol SquareSeeMoreViewModelProtocol: AnyObject {
    func seeMoreTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundCards` - card background
- `StyleProvider.Color.textPrimary` - icon and label color
- `StyleProvider.fontWith(type: .medium, size: 12)` - label font

Layout constants:
- Card size: 100pt x 100pt
- Corner radius: 16pt
- Icon size: 24pt
- Label top spacing: 4pt
- Vertical stack alignment: center

Content:
- Icon: SF Symbol "chevron.right"
- Label: Localized "see_more" string

## Mock ViewModels

Available presets:
- `.default` - Basic mock (no action on tap)
- `.interactive` - Prints "See More tapped" on tap

Parameters:
- `onSeeMoreTapped: (() -> Void)?` - Optional callback for tap action
