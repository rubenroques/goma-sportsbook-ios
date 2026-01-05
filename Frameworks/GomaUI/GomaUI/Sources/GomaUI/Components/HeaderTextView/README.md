# HeaderTextView

A simple header text component with styled title and background container.

## Overview

HeaderTextView displays a single-line title text inside a rounded container with secondary background. It's designed for section headers, category labels, or any simple header text display that needs visual separation from surrounding content.

## Component Relationships

### Used By (Parents)
- None (standalone header component)

### Uses (Children)
- None (leaf component)

## Features

- Single-line title text
- Rounded container background (4pt corner radius)
- Bold 14pt title font
- Primary text color
- Secondary background color
- 8pt padding on all sides
- Dynamic title updates via callback
- Configurable title text

## Usage

```swift
let viewModel = MockHeaderTextViewModel()
viewModel.updateTitle("Suggested Events")
let headerView = HeaderTextView(viewModel: viewModel)

// Update title dynamically
viewModel.updateTitle("Popular Matches")
```

## Data Model

```swift
protocol HeaderTextViewModelProtocol: AnyObject {
    var title: String { get }
    var refreshData: (() -> Void)? { get set }

    func updateTitle(_ title: String)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.fontWith(type: .bold, size: 14)` - title font

Layout constants:
- Container corner radius: 4pt
- Container padding: 8pt (all sides)
- Text lines: 1 (single line)
- Text alignment: left

## Mock ViewModels

No dedicated mock presets - use MockHeaderTextViewModel directly and call `updateTitle(_:)` to set content.
