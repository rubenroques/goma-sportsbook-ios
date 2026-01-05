# SportGamesFilterView

A collapsible grid of sport type filter cards for filtering games by sport.

## Overview

SportGamesFilterView displays a collapsible section with a title header and a 2-column grid of sport cards. Each card shows a sport icon and name, and can be selected to filter content by that sport. The panel supports expand/collapse animation with a rotating chevron indicator. It handles odd numbers of sports by adding empty spacer views to maintain grid layout.

## Component Relationships

### Used By (Parents)
- Game listing screens
- Filter panels
- Sports navigation

### Uses (Children)
- `SportCardView` (internal helper for each sport)

## Features

- Collapsible panel with animated chevron
- Header with customizable title
- 2-column grid layout
- Single-selection with visual feedback
- Sport icons (custom or SF Symbols)
- Sport selection callback
- Dynamic sport configuration
- Handles odd number of sports
- Reactive updates via Combine publishers

## Usage

```swift
let sportFilters = [
    SportFilter(id: "1", title: "Football", icon: "sportscourt.fill"),
    SportFilter(id: "2", title: "Basketball", icon: "basketball.fill"),
    SportFilter(id: "3", title: "Tennis", icon: "tennis.racket"),
    SportFilter(id: "4", title: "Cricket", icon: "figure.cricket")
]
let viewModel = MockSportGamesFilterViewModel(
    title: "Games",
    sportFilters: sportFilters,
    selectedSport: .singleSport(id: "1")
)
let filterView = SportGamesFilterView(viewModel: viewModel)

// Handle selection
filterView.onSportSelected = { sportId in
    filterGamesBySport(sportId)
}
```

## Data Model

```swift
enum SportGamesFilterStateType {
    case expanded
    case collapsed
}

protocol SportGamesFilterViewModelProtocol {
    var title: String { get }
    var sportFilters: [SportFilter] { get }
    var selectedSport: CurrentValueSubject<FilterIdentifier, Never> { get set }
    var sportFilterState: CurrentValueSubject<SportGamesFilterStateType, Never> { get }

    func selectSport(_ sport: FilterIdentifier)
    func didTapCollapseButton()
}

// SportFilter from SharedModels
struct SportFilter {
    let id: String
    let title: String
    let icon: String
}

// FilterIdentifier from SharedModels
enum FilterIdentifier {
    case all
    case singleSport(id: String)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - panel background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.iconPrimary` - collapse button tint
- `StyleProvider.fontWith(type: .bold, size: 14)` - title font

Layout constants:
- Corner radius: 8pt
- Content padding: 16pt
- Grid spacing: 8pt (vertical and horizontal)
- Chevron size: 24pt
- Columns: 2 (fillEqually distribution)

Collapse animation:
- Duration: 0.3s
- Chevron rotates 180 degrees
- Grid fades and collapses
- Bottom padding adjusts (16pt -> 0pt)

Icons:
- Bundle "chevron_up_icon" or SF Symbol "chevron.down"

## Mock ViewModels

Parameters:
- `title: String` - Section header title
- `sportFilters: [SportFilter]` - Available sports
- `selectedSport: FilterIdentifier` - Initially selected sport
- `sportFilterState: SportGamesFilterStateType` - Initial expand/collapse state

Methods:
- `selectSport(_ sport:)` - Select a sport
- `didTapCollapseButton()` - Toggle expanded/collapsed state
