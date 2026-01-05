# BetDetailValuesSummaryView

A grouped container displaying bet values in a header-content-footer card layout.

## Overview

BetDetailValuesSummaryView organizes multiple BetDetailRowView components into a structured summary card with optional header (date), content rows (bet values like odds, amounts, stake), and optional footer (result). The component uses internal 8pt padding and 1pt spacing between content rows for visual separation.

## Component Relationships

### Used By (Parents)
- None (standalone component)

### Uses (Children)
- `BetDetailRowView` - individual rows for header, content, and footer sections

## Features

- Three-section layout: header, content, footer
- Optional header and footer rows
- Dynamic content row count
- Automatic corner radius handling per row position
- Reactive updates via Combine publisher
- 8pt internal padding around content stack

## Usage

```swift
let viewModel = MockBetDetailValuesSummaryViewModel.defaultMock()
let summaryView = BetDetailValuesSummaryView(viewModel: viewModel)
```

## Data Model

```swift
struct BetDetailValuesSummaryData: Equatable {
    let headerRow: BetDetailRowData?     // Optional header (e.g., date)
    let contentRows: [BetDetailRowData]  // Main value rows
    let footerRow: BetDetailRowData?     // Optional footer (e.g., result)
}

protocol BetDetailValuesSummaryViewModelProtocol {
    var dataPublisher: AnyPublisher<BetDetailValuesSummaryData, Never> { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - section container backgrounds
- Inherits styling from child `BetDetailRowView` components

## Mock ViewModels

Available presets:
- `.defaultMock()` - full layout with header (date), 6 content rows, footer (result)
- `.singleRowMock()` - minimal layout with single "Total Amount" row
- `.customMock(headerRow:contentRows:footerRow:)` - custom configuration
