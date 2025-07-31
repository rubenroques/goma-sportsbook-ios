# MatchHeaderCompactView

A compact header component for displaying match information including team names, competition details, and an optional statistics button.

## Overview

`MatchHeaderCompactView` provides a clean, compact layout for match headers with:
- Team names displayed vertically
- Competition breadcrumb with tappable elements
- Optional statistics button with icon
- Responsive layout that adapts to content

## Features

- **Team Display**: Shows home and away team names in a vertical stack
- **Competition Breadcrumb**: Displays sport, competition, and league with underlined tappable elements
- **Statistics Button**: Optional button with text and icon for accessing match statistics
- **Themeable**: Uses StyleProvider for consistent theming across light/dark modes
- **Reactive**: Updates automatically based on view model data changes

## Usage

```swift
// Create view model with match data
let matchData = MatchHeaderCompactData(
    homeTeamName: "Manchester United",
    awayTeamName: "Glasgow Rangers",
    sport: "Football",
    competition: "International",
    league: "UEFA Europa League",
    hasStatistics: true
)

let viewModel = MockMatchHeaderCompactViewModel(headerData: matchData)

// Set up callbacks
viewModel.onStatisticsTapped = {
    // Handle statistics tap
}

viewModel.onCompetitionTapped = {
    // Handle competition tap
}

viewModel.onLeagueTapped = {
    // Handle league tap
}

// Create the view
let headerView = MatchHeaderCompactView(viewModel: viewModel)
```

## Layout Structure

```
┌─────────────────────────────────────────────────┐
│ ┌─────────────────────┐   ┌──────────────────┐ │
│ │ Manchester United    │   │ Statistics 📊    │ │
│ │ Glasgow Rangers      │   └──────────────────┘ │
│ │ Football / Intl / UEFA │                      │
│ └─────────────────────┘                         │
└─────────────────────────────────────────────────┘
```

## Data Model

```swift
struct MatchHeaderCompactData {
    let homeTeamName: String      // Home team name
    let awayTeamName: String      // Away team name
    let sport: String             // Sport category
    let competition: String       // Competition name (tappable)
    let league: String            // League name (tappable)
    let hasStatistics: Bool       // Show/hide statistics button
}
```

## Styling

The component uses StyleProvider colors:
- `gameHeaderTextPrimary`: Team names
- `gameHeaderTextSecondary`: Competition breadcrumb
- `highlightTertiary`: Statistics button text and icon
- `backgroundCards`: Component background
- `separatorLine`: Bottom border

## Customization

### Hiding Statistics Button

```swift
let matchData = MatchHeaderCompactData(
    // ... other properties
    hasStatistics: false  // Hides statistics button
)
```

### Handling Taps

The view model provides three tap handlers:
- `onStatisticsTapped`: Called when statistics button is tapped
- `onCompetitionTapped`: Called when competition text is tapped
- `onLeagueTapped`: Called when league text is tapped

## Mock ViewModels

Several preset mock view models are available for testing:
- `.default`: Standard football match
- `.withoutStatistics`: Match without statistics button
- `.longNames`: Teams with long names
- `.basketball`: NBA basketball match
- `.tennis`: Tennis match example

## Preview

The component includes SwiftUI previews for easy development:
- Default view with statistics
- View without statistics
- View with long team names