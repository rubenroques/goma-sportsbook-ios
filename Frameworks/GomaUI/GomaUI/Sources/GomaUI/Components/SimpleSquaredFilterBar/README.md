# SimpleSquaredFilterBar

A horizontal filter bar with squared buttons for time range, status, or category selection.

## Overview

SimpleSquaredFilterBarView displays a horizontal row of equally-distributed squared filter buttons. When a button is tapped, it becomes selected and the callback notifies the parent. Commonly used for time range filters (All, 1D, 1W, 1M, 3M), status filters (Active, Pending, Completed), or category filters.

## Component Relationships

### Used By (Parents)
- Transaction history screens
- Activity filter sections
- Status filter bars

### Uses (Children)
- `SimpleSquaredFilterBarButton` - individual filter button

## Features

- Horizontal equal-spacing layout
- Single selection mode
- Tap callback with filter ID
- Selected state styling
- Dynamic button creation from data
- Programmatic selection support
- Fixed 40pt height

## Usage

```swift
// Time range filters
let data = SimpleSquaredFilterBarData(
    items: [
        ("all", "All"),
        ("1d", "1D"),
        ("1w", "1W"),
        ("1m", "1M"),
        ("3m", "3M")
    ],
    selectedId: "all"
)
let filterBar = SimpleSquaredFilterBarView(data: data)

// Handle selection
filterBar.onFilterSelected = { filterId in
    print("Selected: \(filterId)")
}

// Programmatic selection
filterBar.setSelected("1w")

// Reconfigure with new data
filterBar.configure(with: newData)
```

## Data Model

```swift
struct SimpleSquaredFilterBarData: Equatable {
    let items: [(id: String, title: String)]
    let selectedId: String?

    init(items: [(String, String)], selectedId: String? = nil)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - bar background

Layout constants:
- Bar height: 40pt (fixed)
- Horizontal padding: 16pt
- Stack distribution: equal spacing
- Stack spacing: 0pt (handled by distribution)

Button styling (handled by SimpleSquaredFilterBarButton):
- Selected: highlight background with contrasting text
- Unselected: secondary background with primary text

## Callbacks

- `onFilterSelected: ((String) -> Void)?` - Called with filter ID when selection changes

## Mock ViewModels

Available presets (via `MockSimpleSquaredFilterBarViewModel`):
- `.defaultMock` - Same as timeFilters
- `.timeFilters` - All, 1D, 1W, 1M, 3M
- `.statusFilters` - Active, Pending, Completed, Cancelled
- `.priorityFilters` - Low, Medium, High, Urgent
- `.categoryFilters` - All, Payments, Games, Bonuses
- `.gameTypeFilters` - Live, Upcoming, Finished
