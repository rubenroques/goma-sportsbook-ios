# SortFilterView

A collapsible sort/filter options panel with header and vertical option list.

## Overview

SortFilterView displays a collapsible panel with a "Sort By" header and a vertical list of sort options. Each option shows an icon, title, and optional count. The panel can be expanded/collapsed with an animated chevron indicator. When an option is selected, the selection is visually indicated and a callback is triggered. This component is used for sorting and filtering content lists.

## Component Relationships

### Used By (Parents)
- Filter panels
- Listing screens
- Search results screens

### Uses (Children)
- `SortOptionRowView` (internal helper for each option)

## Features

- Collapsible panel with animated chevron
- Header with customizable title
- Vertical list of sort options
- Single-selection with visual feedback
- Option icons and counts
- Selection callback
- Dynamic option updates
- Reactive updates via Combine publishers

## Usage

```swift
let sortOptions: [SortOption] = [
    SortOption(id: "1", icon: "flame.fill", title: "Popular", count: 25),
    SortOption(id: "2", icon: "clock.fill", title: "Upcoming", count: 15),
    SortOption(id: "3", icon: "heart.fill", title: "Favourites", count: 0)
]
let viewModel = MockSortFilterViewModel(
    title: "Sort By",
    sortOptions: sortOptions
)
let sortView = SortFilterView(viewModel: viewModel)

// Handle selection
sortView.onSortFilterSelected = { selectedId in
    applySortFilter(selectedId)
}

// Update options dynamically
viewModel.updateSortOptions(newOptions)
```

## Data Model

```swift
enum SortFilterType {
    case regular
    case league
}

protocol SortFilterViewModelProtocol {
    var title: String { get }
    var sortOptions: [SortOption] { get }
    var sortFilterType: SortFilterType { get }
    var selectedFilter: CurrentValueSubject<LeagueFilterIdentifier, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    var shouldRefreshData: PassthroughSubject<Void, Never> { get }

    func selectFilter(_ filter: LeagueFilterIdentifier)
    func toggleCollapse()
    func updateSortOptions(_ newSortOptions: [SortOption])
}

// SortOption from SharedModels
struct SortOption {
    let id: String
    let icon: String?
    let title: String
    let count: Int
    let iconTintChange: Bool
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - panel background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.iconPrimary` - collapse chevron tint
- `StyleProvider.fontWith(type: .bold, size: 14)` - title font

Layout constants:
- Header horizontal padding: 16pt
- Header vertical padding: 12pt
- Chevron size: 24pt
- Option row height: 56pt
- Stack spacing: 0pt

Collapse animation:
- Duration: 0.3s
- Chevron rotates 180 degrees
- Content fades in/out

Icons:
- Bundle "chevron_up_icon" or SF Symbol "chevron.down"

## Mock ViewModels

Parameters:
- `title: String` - Header title
- `sortOptions: [SortOption]` - List of sort options
- `selectedFilter: LeagueFilterIdentifier` - Initially selected filter
- `sortFilterType: SortFilterType` - Filter type (regular/league)

Methods:
- `selectFilter(_ filter:)` - Select an option
- `toggleCollapse()` - Toggle expanded/collapsed state
- `updateSortOptions(_ newSortOptions:)` - Update available options
