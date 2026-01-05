# ListBlockView

A numbered list block with icon/counter and vertical stack of child views.

## Overview

ListBlockView displays a block with an icon or numbered counter on the left and a vertical stack of child views on the right. It's designed for displaying ordered lists, step-by-step instructions, or grouped content with visual indicators.

## Component Relationships

### Used By (Parents)
- None (standalone list block component)

### Uses (Children)
- `BulletItemBlockView` - bullet item content views

## Features

- Left-side icon (56x56pt) from URL or numbered counter
- Circular border for counter display (when no icon)
- Semibold 24pt counter text
- Vertical stack of child views
- Clear background
- 15pt horizontal padding
- 10pt vertical padding on icon
- 5pt vertical padding on stack

## Usage

```swift
let bulletView1 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.defaultMock)
let bulletView2 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.shortMock)

let viewModel = MockListBlockViewModel(
    iconUrl: "",
    counter: "1",
    views: [bulletView1, bulletView2]
)
let listBlock = ListBlockView(viewModel: viewModel)

// With icon from URL
let iconViewModel = MockListBlockViewModel(
    iconUrl: "https://example.com/icon.jpg",
    counter: nil,
    views: [bulletView1]
)
```

## Data Model

```swift
protocol ListBlockViewModelProtocol {
    var iconUrl: String { get }
    var counter: String? { get }
    var views: [UIView] { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightSecondaryContrast` - counter text color, border color
- `StyleProvider.fontWith(type: .semibold, size: 24)` - counter font

Layout constants:
- Icon/counter size: 56x56pt
- Icon leading padding: 15pt
- Icon top padding: 10pt
- Stack leading (from icon): 10pt
- Stack trailing padding: 15pt
- Stack vertical padding: 5pt
- Counter border width: 2pt
- Counter corner radius: circular (28pt)
- Stack spacing: 0pt

## Mock ViewModels

Available presets:
- `.defaultMock` - icon URL with 2 bullet views
- `.withIconMock` - valid picsum URL with 2 bullet views
- `.noIconMock` - empty icon URL (shows counter) with 1 bullet view
