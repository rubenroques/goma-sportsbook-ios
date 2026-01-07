# StackViewBlockView

A vertical stack container for CMS content blocks with dynamic child view composition.

## Overview

StackViewBlockView displays a vertical stack of child views provided by its view model, typically used for CMS-driven content layouts. The component accepts any UIView array and arranges them vertically with zero spacing. Commonly used to compose title blocks, description blocks, and bullet items into cohesive content sections.

## Component Relationships

### Used By (Parents)
- CMS promotional screens
- Content detail views
- Onboarding flows

### Uses (Children)
- `BulletItemBlockView` - bullet point items
- `DescriptionBlockView` - text descriptions
- `TitleBlockView` - section titles
- Any UIView can be added dynamically

## Features

- Dynamic vertical stack layout
- Zero spacing between items
- Accepts any UIView array
- Clear background
- Automatic view recycling on reconfigure
- CMS block composition

## Usage

```swift
let viewModel = MockStackViewBlockViewModel.defaultMock
let stackBlock = StackViewBlockView(viewModel: viewModel)

// Multiple views composition
let multiViewModel = MockStackViewBlockViewModel.multipleViewsMock
let multiStackBlock = StackViewBlockView(viewModel: multiViewModel)

// Single view
let singleViewModel = MockStackViewBlockViewModel.singleViewMock
let singleStackBlock = StackViewBlockView(viewModel: singleViewModel)

// Custom views
let customViews = [
    TitleBlockView(viewModel: MockTitleBlockViewModel.defaultMock),
    DescriptionBlockView(viewModel: MockDescriptionBlockViewModel.defaultMock)
]
let customViewModel = MockStackViewBlockViewModel(views: customViews)
let customStack = StackViewBlockView(viewModel: customViewModel)
```

## Data Model

```swift
protocol StackViewBlockViewModelProtocol {
    var views: [UIView] { get }
}
```

## Styling

Layout constants:
- Stack spacing: 0pt
- Stack axis: vertical
- Top padding: 10pt
- Bottom padding: 10pt
- Leading/trailing: edge to edge

Background:
- View: clear
- Stack: clear

## Mock ViewModels

Available presets:
- `.defaultMock` - TitleBlockView + DescriptionBlockView
- `.multipleViewsMock` - Title + Description + 2 BulletItemBlockViews
- `.singleViewMock` - Single TitleBlockView only

Factory initialization:
```swift
MockStackViewBlockViewModel(views: [UIView])
```
