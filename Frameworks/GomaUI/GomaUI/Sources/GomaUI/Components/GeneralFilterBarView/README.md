# GeneralFilterBarView

A horizontal filter bar with scrollable filter pills and a main filter button.

## Overview

GeneralFilterBarView displays a horizontal collection of filter options (sports, leagues, sort options) with a pinned main filter button on the right side. The component uses a horizontal collection view for scrollable filter items and a dedicated container for the main filter pill.

## Component Relationships

### Used By (Parents)
- None (standalone filter bar component)

### Uses (Children)
- `MainFilterPillView` - main filter button on the right
- `SportSelectorCell` - sport filter cells
- `FilterOptionCell` - other filter option cells

## Features

- Horizontal scrolling collection view for filter items
- Fixed main filter pill on the right
- 8pt minimum spacing between items
- 16pt horizontal content inset
- Self-sizing cells (automatic size estimation)
- Primary background color
- Filter item tap callbacks
- Main filter tap callback
- Dynamic item updates
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockGeneralFilterBarViewModel.defaultMock
let filterBarView = GeneralFilterBarView(viewModel: viewModel)

filterBarView.onItemSelected = { filterType in
    print("Selected filter type: \(filterType)")
}

filterBarView.onMainFilterTapped = {
    print("Main filter tapped - show filter modal")
}

// Update items dynamically
filterBarView.updateFilterItems(filterOptionItems: newItems)
```

## Data Model

```swift
struct GeneralFilterBarItems {
    var items: [FilterOptionItem]
    let mainFilterItem: MainFilterItem
}

struct FilterOptionItem {
    let type: FilterOptionType
    let title: String
    let icon: String
}

struct MainFilterItem {
    let type: FilterOptionType
    let title: String
    let icon: String?
    let actionIcon: String?
}

protocol GeneralFilterBarViewModelProtocol {
    var generalFilterItemsPublisher: CurrentValueSubject<GeneralFilterBarItems, Never> { get }

    func updateFilterOptionItems(filterOptionItems: [FilterOptionItem])
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - view background

Layout constants:
- Collection view content inset: 16pt left/right
- Item spacing: 8pt
- Main filter container padding: 10pt horizontal
- Height: 56pt (typical)

## Mock ViewModels

Available presets:
- `.defaultMock` - Football sport, Popular sort, All Leagues, and "Filter" main button
