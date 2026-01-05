# GradientHeaderView

A gradient banner header with centered title text for promotional content.

## Overview

GradientHeaderView displays a banner with a customizable diagonal gradient background and centered title text. It's designed for promotional headers, welcome banners, or section headers that need visual emphasis.

## Component Relationships

### Used By (Parents)
- `StackViewBlockView` - promotional stack headers

### Uses (Children)
- `GradientView` - gradient background

## Features

- Diagonal gradient background (bottom-left to top-right)
- Centered multi-line title text
- Bold 24pt white text
- Fixed 208pt height
- Customizable gradient colors with location stops
- Clear background on container
- Static content (reconfigurable via configure method)

## Usage

```swift
let viewModel = MockGradientHeaderViewModel.defaultMock
let headerView = GradientHeaderView(viewModel: viewModel)

// Reconfigure with different view model
let newViewModel = MockGradientHeaderViewModel.blueGradientMock
headerView.configure(viewModel: newViewModel)
```

## Data Model

```swift
protocol GradientHeaderViewModelProtocol {
    var title: String { get }
    var gradientColors: [(color: UIColor, location: NSNumber)] { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.buttonTextPrimary` - title text color
- `StyleProvider.fontWith(type: .bold, size: 24)` - title font

Layout constants:
- Header height: 208pt
- Title padding: 15pt horizontal
- Gradient direction: diagonal (bottom-left to top-right)

## Mock ViewModels

Available presets:
- `.defaultMock` - "Welcome Bonus" with orange-to-red gradient
- `.blueGradientMock` - "Special Promotion" with blue-to-cyan gradient
- `.purpleGradientMock` - "Premium Offer" with purple-to-pink gradient
- `.longTitleMock` - "Amazing Welcome Bonus Promotion" with green-to-yellow gradient
