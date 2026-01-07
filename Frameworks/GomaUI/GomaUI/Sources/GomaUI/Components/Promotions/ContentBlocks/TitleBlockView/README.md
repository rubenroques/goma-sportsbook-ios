# TitleBlockView

A simple title block component for displaying promotional or section headings.

## Overview

TitleBlockView displays a large title label with configurable text alignment (centered or left-aligned). It uses a semibold font at 24pt with the secondary contrast highlight color. The component is designed for promotional banners, welcome messages, and section headings within stack-based layouts.

## Component Relationships

### Used By (Parents)
- `StackViewBlockView` - CMS block containers
- Promotional screens
- Welcome sections

### Uses (Children)
- None (leaf component)

## Features

- Large semibold title text (24pt)
- Configurable text alignment (center or left)
- Multi-line support
- Clear background
- Used in CMS stack-based layouts

## Usage

```swift
let viewModel = MockTitleBlockViewModel(title: "Welcome Bonus")
let titleBlock = TitleBlockView(viewModel: viewModel)

// Centered title (default)
let centered = TitleBlockView(
    viewModel: MockTitleBlockViewModel(
        title: "Centered Title",
        isCentered: true
    )
)

// Left-aligned title
let leftAligned = TitleBlockView(
    viewModel: MockTitleBlockViewModel(
        title: "Left Aligned Title",
        isCentered: false
    )
)

// Long promotional title
let promo = TitleBlockView(
    viewModel: MockTitleBlockViewModel(
        title: "Amazing Welcome Bonus Promotion"
    )
)
```

## Data Model

```swift
protocol TitleBlockViewModelProtocol {
    var title: String { get }
    var isCentered: Bool { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightSecondaryContrast` - title text color
- `StyleProvider.fontWith(type: .semibold, size: 24)` - title font

Layout constants:
- Leading padding: 15pt
- Trailing padding: 15pt
- Top padding: 5pt
- Bottom padding: 5pt
- Number of lines: 0 (unlimited)
- Background: clear

Text alignment:
- Centered: `.center` (when `isCentered` is true)
- Left-aligned: `.left` (when `isCentered` is false)

## Mock ViewModels

Available presets:
- `.defaultMock` - "Welcome Bonus" centered
- `.centeredMock` - "Centered Title" centered
- `.leftAlignedMock` - "Left Aligned Title" left
- `.longTitleMock` - "Amazing Welcome Bonus Promotion"

Factory initialization:
```swift
MockTitleBlockViewModel(
    title: String,
    isCentered: Bool = true
)
```
