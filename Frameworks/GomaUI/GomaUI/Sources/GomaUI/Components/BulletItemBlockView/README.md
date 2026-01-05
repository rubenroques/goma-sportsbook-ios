# BulletItemBlockView

A simple bullet point list item with highlighted bullet character.

## Overview

BulletItemBlockView displays a single bullet point item with the bullet character styled in the highlight color and the text in the primary text color. It's designed for use in promotional content, terms, and informational lists.

## Component Relationships

### Used By (Parents)
- `ListBlockView` - renders multiple bullet items in a list
- `StackViewBlockView` - displays bullet items within stacked content

### Uses (Children)
- None (leaf component)

## Features

- Bullet character with highlight color
- Multi-line text support
- 1.2x line height multiplier with 2pt line spacing
- 15pt horizontal padding, 5pt vertical padding
- Clear background

## Usage

```swift
let viewModel = MockBulletItemBlockViewModel(title: "Free bet on your first deposit")
let bulletView = BulletItemBlockView(viewModel: viewModel)
```

## Data Model

```swift
protocol BulletItemBlockViewModelProtocol {
    var title: String { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - bullet character color
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.fontWith(type: .semibold, size: 14)` - title font

## Mock ViewModels

Create via `MockBulletItemBlockViewModel(title:)`:
- Custom title text for each bullet point
