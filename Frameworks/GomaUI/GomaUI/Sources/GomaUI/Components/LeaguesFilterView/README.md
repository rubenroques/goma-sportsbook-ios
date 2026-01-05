# LeaguesFilterView

A collapsible filter panel for league selection with animated expand/collapse.

## Overview

LeaguesFilterView displays a list of league filter options with a collapsible panel design. It includes a header with title and collapse button, and a vertical stack of selectable league option rows. The component supports animated collapse/expand transitions and selection state management.

## Component Relationships

### Used By (Parents)
- None (standalone filter panel component)

### Uses (Children)
- `LeagueOptionRowView` - individual league option row

## Features

- "Leagues" header title (localized)
- Collapse/expand toggle button with animated arrow rotation
- Vertical stack of league option rows
- Selection state tracking
- Animated collapse/expand (0.3s duration)
- Chevron rotation animation on collapse
- Tertiary background color
- 56pt row height
- Selection callback
- Reactive updates via Combine publishers

## Usage

```swift
let leagueOptions = [
    LeagueOption(id: "1", icon: "trophy.fill", title: "Premier League", count: 32),
    LeagueOption(id: "2", icon: "trophy.fill", title: "La Liga", count: 28),
    LeagueOption(id: "3", icon: "trophy.fill", title: "Bundesliga", count: 25)
]

let viewModel = MockLeaguesFilterViewModel(leagueOptions: leagueOptions)
let filterView = LeaguesFilterView(viewModel: viewModel)

filterView.onLeagueFilterSelected = { leagueId in
    print("Selected league: \(leagueId)")
}

// Select a specific filter
viewModel.selectFilter(.init(stringValue: "1"))

// Toggle collapse state
viewModel.toggleCollapse()
```

## Data Model

```swift
struct LeagueOption {
    let id: String
    let icon: String
    let title: String
    let count: Int
}

struct LeagueFilterIdentifier {
    let rawValue: String

    static let all: LeagueFilterIdentifier

    init(stringValue: String)
}

protocol LeaguesFilterViewModelProtocol {
    var leagueOptions: [LeagueOption] { get }
    var selectedFilter: CurrentValueSubject<LeagueFilterIdentifier, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }

    func selectFilter(_ filter: LeagueFilterIdentifier)
    func toggleCollapse()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - panel background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.iconPrimary` - collapse button tint
- `StyleProvider.fontWith(type: .bold, size: 14)` - title font

Layout constants:
- Title horizontal padding: 16pt
- Title vertical padding: 12pt
- Collapse button size: 24x24pt
- Row height: 56pt
- Stack spacing: 0pt
- Animation duration: 0.3s

## Mock ViewModels

No dedicated mock presets - use MockLeaguesFilterViewModel directly with array of LeagueOption.
