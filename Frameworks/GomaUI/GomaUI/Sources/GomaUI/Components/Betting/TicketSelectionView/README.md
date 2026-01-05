# TicketSelectionView

A ticket selection component for displaying match information with two distinct states: preLive and Live. The component shows competition details, team names, scores (only in live state), and either a date label or live indicator based on the match state.

## Overview

`TicketSelectionView` is designed for sports betting applications that need to display match tickets with different visual states. It follows the GomaUI architecture with protocol-based design, reactive data flow, and unified visual state management.

## Features

- **Dual State Support**: Automatically switches between preLive and Live states
- **Competition Display**: Shows competition name with sport icon and country flag
- **Team Information**: Displays home and away team names
- **Dynamic Scoring**: Shows scores only in live state, hidden in preLive state
- **State Indicators**: Date label for preLive matches, live indicator for live matches
- **Reactive Updates**: Real-time data updates through Combine publishers
- **Accessibility**: Full accessibility support with proper labels
- **Theming**: Consistent styling through StyleProvider integration

## Visual States

### PreLive State
- Shows competition info (sport icon, country flag, competition name)
- Displays team names
- Shows date/time information in top right
- Scores are hidden
- Orange separator line
- Betting market information (Market, Selection, Odds, 0.00)

### Live State
- Shows competition info (sport icon, country flag, competition name)
- Displays team names
- Shows live scores (home - away format)
- Displays orange "LIVE" indicator with circle icon in top right
- Orange separator line
- Betting market information (Market, Selection, Odds, 0.00)

## Basic Usage

```swift


// Create with mock data
let viewModel = MockTicketSelectionViewModel.preLiveMock
let ticketView = TicketSelectionView(viewModel: viewModel)

// Set up callbacks
viewModel.onTicketTapped = {
    // Handle ticket tap
}

// Add to your view hierarchy
view.addSubview(ticketView)
ticketView.translatesAutoresizingMaskIntoConstraints = false
```

## Layout Structure

```
┌─────────────────────────────────────────────────┐
│ ⚽ 🏁 Premier League                   20:00   │ ← PreLive State
│ Manchester United                               │
│ Liverpool                                       │
│ ─────────────────────────────────────────────── │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ ⚽ 🏁 La Liga                        [LIVE ●]  │ ← Live State
│ Barcelona                                       │
│ Atletico Madrid                          2 - 1  │
│ ─────────────────────────────────────────────── │
└─────────────────────────────────────────────────┘
```

## Data Model

```swift
public struct TicketSelectionData {
    public let id: String
    public let competitionName: String
    public let homeTeamName: String
    public let awayTeamName: String
    public let homeScore: Int
    public let awayScore: Int
    public let matchDate: String
    public let isLive: Bool
    public let sportIcon: UIImage?
    public let countryFlag: UIImage?
    public let marketName: String
    public let selectionName: String
    public let oddsValue: String
}
```

## Mock Examples

### PreLive Matches
```swift
// Premier League match
let preLiveViewModel = MockTicketSelectionViewModel.preLiveMock

// Champions League match
let championsLeagueViewModel = MockTicketSelectionViewModel.preLiveChampionsLeagueMock
```

### Live Matches
```swift
// Live match with scores
let liveViewModel = MockTicketSelectionViewModel.liveMock

// Live draw
let liveDrawViewModel = MockTicketSelectionViewModel.liveDrawMock

// High scoring live match
let highScoreViewModel = MockTicketSelectionViewModel.liveHighScoreMock
```

### Edge Cases
```swift
// Long team names
let longNamesViewModel = MockTicketSelectionViewModel.longTeamNamesMock

// No icons
let noIconsViewModel = MockTicketSelectionViewModel.noIconsMock
```

## State Management

The component automatically handles state transitions:

```swift
// Toggle between preLive and Live states
mockViewModel.toggleLiveState()

// Update with new data
let newData = TicketSelectionData(...)
mockViewModel.updateTicketData(newData)
```

## Customization

### Colors
All colors are managed through `StyleProvider.Color`:
- `backgroundCards`: Component background
- `textPrimary`: Primary text (team names, scores)
- `textSecondary`: Secondary text (competition, date)
- `accent`: Live indicator background and separator
- `textOnAccent`: Text on accent backgrounds

### Fonts
Fonts are managed through `StyleProvider.fontWith`:
- Team names: Bold, 16pt
- Competition: Semibold, 14pt
- Date: Medium, 12pt
- Live indicator: Semibold, 10pt

## SwiftUI Previews

The component includes comprehensive SwiftUI previews for development:

```swift
// In Xcode, use the Canvas to see all preview states
TicketSelectionPreviewView_Previews
```

## Integration with Existing Components

This component follows the same architectural patterns as other GomaUI components:
- Protocol-driven ViewModel design
- Combine-based reactive updates
- StyleProvider theming integration
- Comprehensive mock implementations
- SwiftUI preview support

## Accessibility

- Proper accessibility labels for all UI elements
- VoiceOver support for screen readers
- Dynamic Type support for text scaling
- High contrast mode compatibility

## Performance Considerations

- Efficient constraint-based layout
- Minimal view hierarchy
- Combine-based reactive updates
- Proper memory management with cancellables 
