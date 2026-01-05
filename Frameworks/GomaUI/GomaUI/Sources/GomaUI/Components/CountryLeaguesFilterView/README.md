# CountryLeaguesFilterView

A collapsible country/league filter panel with nested expandable sections.

## Overview

CountryLeaguesFilterView displays a list of countries with their associated leagues in a collapsible structure. Each country can be expanded to show its leagues, and individual leagues can be selected for filtering. The component supports dynamic data updates, collapse/expand animations, and league selection tracking.

## Component Relationships

### Used By (Parents)
- None (standalone filter component)

### Uses (Children)
- `CountryLeagueOptionRowView` - internal row for each country with leagues

## Features

- Collapsible header with title and chevron icon
- Multiple country rows with nested league lists
- Country expansion to show/hide leagues
- Single league selection across all countries
- League selection callback
- Animated collapse/expand with rotation transform
- Dynamic data refresh support
- Chevron rotation animation (180 degrees)
- Tertiary background color
- Reactive updates via Combine publishers

## Usage

```swift
let countryOptions = [
    CountryLeagueOptions(
        id: "1",
        icon: "england_flag",
        title: "England",
        leagues: [
            LeagueOption(id: "1", icon: nil, title: "Premier League", count: 25),
            LeagueOption(id: "2", icon: nil, title: "Championship", count: 24)
        ],
        isExpanded: true
    )
]

let viewModel = MockCountryLeaguesFilterViewModel(
    title: "Popular Countries",
    countryLeagueOptions: countryOptions
)
let filterView = CountryLeaguesFilterView(viewModel: viewModel)

filterView.onLeagueFilterSelected = { leagueId in
    print("Selected league: \(leagueId)")
}
```

## Data Model

```swift
struct CountryLeagueOptions {
    let id: String
    let icon: String
    let title: String
    let leagues: [LeagueOption]
    var isExpanded: Bool
}

struct LeagueOption {
    let id: String
    let icon: String?
    let title: String
    let count: Int
}

protocol CountryLeaguesFilterViewModelProtocol {
    var title: String { get }
    var countryLeagueOptions: [CountryLeagueOptions] { get }
    var selectedOptionId: CurrentValueSubject<String, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    var shouldRefreshData: PassthroughSubject<Void, Never> { get }

    func toggleCollapse()
    func toggleCountryExpansion(at index: Int)
    func updateCountryLeagueOptions(_ newOptions: [CountryLeagueOptions])
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - container background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.iconPrimary` - chevron icon tint
- `StyleProvider.fontWith(type: .bold, size: 14)` - title font

Layout constants:
- Title padding: 16pt leading, 12pt top
- Chevron size: 14pt
- Chevron trailing: 21pt
- Stack spacing: 0pt

## Mock ViewModels

Available presets:
- `MockCountryLeaguesFilterViewModel(title:countryLeagueOptions:selectedId:)` - custom configuration

Sample countries supported in previews:
- England (Premier League, Championship, League One, League Two, FA Cup, EFL Cup)
- France (Ligue 1, Ligue 2, Coupe de France)
- Germany (Bundesliga, 2. Bundesliga, DFB-Pokal)
- Italy (Serie A, Serie B, Coppa Italia)
- Spain (La Liga, La Liga 2, Copa del Rey)
- International (Champions League, Europa League, Conference League, World Cup Qualifiers, Nations League)
