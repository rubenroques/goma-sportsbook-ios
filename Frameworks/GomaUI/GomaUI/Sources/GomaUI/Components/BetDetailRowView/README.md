# BetDetailRowView

A label-value row for displaying bet details with configurable corner radius styles.

## Overview

BetDetailRowView displays a single row with a left-aligned label and right-aligned value. It supports two display styles (standard and header) and configurable corner radius for use in grouped lists. The component is designed for bet detail screens showing odds, amounts, and other transactional information.

## Component Relationships

### Used By (Parents)
- `BetDetailValuesSummaryView` - displays multiple rows in a summary card

### Uses (Children)
- None (leaf component)

## Features

- Label-value pair layout with left/right alignment
- Two display styles: standard and header (centered)
- Four corner radius options: none, topOnly, bottomOnly, all
- Fixed 52pt height for consistent layout
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockBetDetailRowViewModel.defaultMock()
let rowView = BetDetailRowView(viewModel: viewModel, cornerStyle: .topOnly(radius: 8))
```

## Data Model

```swift
enum BetDetailRowCornerStyle {
    case none
    case topOnly(radius: CGFloat)
    case bottomOnly(radius: CGFloat)
    case all(radius: CGFloat)
}

enum BetDetailRowStyle {
    case standard   // Left-aligned label, right-aligned value
    case header     // Centered text, value hidden
}

struct BetDetailRowData: Equatable {
    let label: String
    let value: String
    let style: BetDetailRowStyle
}

protocol BetDetailRowViewModelProtocol {
    var dataPublisher: AnyPublisher<BetDetailRowData, Never> { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - row background
- `StyleProvider.Color.textPrimary` - value text and header label
- `StyleProvider.Color.textSecondary` - standard label text
- `StyleProvider.fontWith(type: .regular, size: 14)` - label font
- `StyleProvider.fontWith(type: .bold, size: 14)` - value font

## Mock ViewModels

Available presets:
- `.defaultMock()` - "Amount" / "XAF 100.75" standard row
- `.headerMock()` - "Bet Placed on Sun 01/01 - 18:59" centered header
- `.customMock(label:value:style:)` - custom configuration
