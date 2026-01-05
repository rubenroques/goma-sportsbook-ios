# BetDetailResultSummaryView

A card displaying match details and bet result status with visual indicators.

## Overview

BetDetailResultSummaryView presents a two-card layout showing match information with bet type in the top card, and a result status pill in the bottom card. The result pill uses color-coded states to indicate won, lost, draw, or open (pending) outcomes.

## Component Relationships

### Used By (Parents)
- None (standalone component)

### Uses (Children)
- None (leaf component)

## Features

- Two-card stacked layout with 8pt spacing
- Match details with bet type description
- Color-coded result pill (won/lost/draw/open)
- Reactive updates via Combine publisher
- Rounded 8pt corners on container and inner cards
- Localized result labels

## Usage

```swift
let viewModel = MockBetDetailResultSummaryViewModel.wonMock()
let summaryView = BetDetailResultSummaryView(viewModel: viewModel)
```

## Data Model

```swift
enum BetDetailResultState: Equatable {
    case won
    case lost
    case draw
    case open
}

struct BetDetailResultSummaryData: Equatable {
    let matchDetails: String
    let betType: String
    let resultState: BetDetailResultState
}

protocol BetDetailResultSummaryViewModelProtocol {
    var dataPublisher: AnyPublisher<BetDetailResultSummaryData, Never> { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - outer container background
- `StyleProvider.Color.backgroundTertiary` - inner card backgrounds
- `StyleProvider.Color.textPrimary` - match details and bet type text
- `StyleProvider.Color.alertSuccess` - won pill background
- `StyleProvider.Color.alertWarning` - draw pill background
- `StyleProvider.Color.alertError` - lost pill text
- `StyleProvider.Color.backgroundGradient2` - lost pill background
- `StyleProvider.fontWith(type: .bold, size: 14)` - match details font
- `StyleProvider.fontWith(type: .regular, size: 14)` - bet type and result label fonts
- `StyleProvider.fontWith(type: .semibold, size: 12)` - result pill label font

## Mock ViewModels

Available presets:
- `.wonMock()` - green "Won" pill state
- `.lostMock()` - red "Lost" pill state
- `.drawMock()` - yellow "Draw" pill state
- `.customMock(matchDetails:betType:resultState:)` - custom configuration
