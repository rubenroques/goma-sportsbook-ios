# InfoRowView

A key-value information row with left and right labels in a styled container.

## Overview

InfoRowView displays a horizontal row with a label on the left and a value on the right, contained in a rounded background. It's designed for displaying financial information, balance summaries, or any key-value data pairs.

## Component Relationships

### Used By (Parents)
- None (standalone info display component)

### Uses (Children)
- None (leaf component)

## Features

- Left-aligned label (semibold 12pt)
- Right-aligned value (bold 12pt, highlight color)
- Rounded container background (4pt corner radius)
- Secondary background color
- 16pt padding on all sides
- 12pt spacing between labels
- Customizable text colors for both labels
- Customizable container background color
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockInfoRowViewModel.defaultMock
let infoRow = InfoRowView(viewModel: viewModel)

// Update with new data
let newData = InfoRowData(
    leftText: "Your Balance",
    rightText: "XAF 5,000"
)
viewModel.configure(with: newData)

// With custom colors
let customData = InfoRowData(
    leftText: "Bonus Balance",
    rightText: "XAF 500",
    leftTextColor: StyleProvider.Color.highlightTertiary,
    rightTextColor: StyleProvider.Color.highlightSecondary,
    backgroundColor: StyleProvider.Color.highlightSecondary.withAlphaComponent(0.1)
)
```

## Data Model

```swift
struct InfoRowData {
    let id: String
    let leftText: String
    let rightText: String
    let leftTextColor: UIColor?
    let rightTextColor: UIColor?
    let backgroundColor: UIColor?
}

protocol InfoRowViewModelProtocol {
    var data: InfoRowData { get }
    var dataPublisher: AnyPublisher<InfoRowData, Never> { get }

    func configure(with data: InfoRowData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background (default)
- `StyleProvider.Color.textPrimary` - left label text color (default)
- `StyleProvider.Color.highlightPrimary` - right label text color (default)
- `StyleProvider.fontWith(type: .semibold, size: 12)` - left label font
- `StyleProvider.fontWith(type: .bold, size: 12)` - right label font

Layout constants:
- Container corner radius: 4pt
- Container padding: 16pt (all sides)
- Stack spacing: 12pt
- Number of lines: unlimited (0)

## Mock ViewModels

Available presets:
- `.defaultMock` - "Your Deposit" / "XAF 1000"
- `.balanceMock` - "Account Balance" / "XAF 25,000"
- `.customBackgroundMock` - "Bonus Balance" / "XAF 500" with custom colors
