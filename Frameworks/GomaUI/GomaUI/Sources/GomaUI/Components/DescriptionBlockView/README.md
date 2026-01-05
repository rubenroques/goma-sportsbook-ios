# DescriptionBlockView

A simple text block for displaying promotional or informational descriptions.

## Overview

DescriptionBlockView displays a multi-line text label with consistent styling for promotional content or informational text blocks. It's designed to be used within stack views or promotional layouts where descriptive text is needed.

## Component Relationships

### Used By (Parents)
- `StackViewBlockView` - content block in promotional stacks

### Uses (Children)
- None (leaf component)

## Features

- Multi-line text support
- Left-aligned text
- Secondary highlight contrast color
- 15pt horizontal padding
- 5pt vertical padding
- Clear background
- Static content (no reactive updates)

## Usage

```swift
let viewModel = MockDescriptionBlockViewModel.defaultMock
let descriptionView = DescriptionBlockView(viewModel: viewModel)
```

## Data Model

```swift
protocol DescriptionBlockViewModelProtocol {
    var description: String { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightSecondaryContrast` - text color
- `StyleProvider.fontWith(type: .regular, size: 14)` - text font

Layout constants:
- Horizontal padding: 15pt
- Vertical padding: 5pt
- Number of lines: unlimited (0)
- Text alignment: left

## Mock ViewModels

Available presets:
- `.defaultMock` - welcome promotion text
- `.shortMock` - "Limited time offer available now."
- `.longMock` - extended promotional description with multiple sentences
