# BetTicketStatusView

A color-coded status indicator for bet ticket outcomes.

## Overview

BetTicketStatusView displays the result status of a settled bet ticket with an icon and label. It uses color-coded backgrounds and icons to visually communicate won, lost, draw, or cashed out states.

## Component Relationships

### Used By (Parents)
- `TicketBetInfoView` - displays ticket status within bet info cards

### Uses (Children)
- None (leaf component)

## Features

- Four status states: won, lost, draw, cashedOut
- Color-coded backgrounds per state
- Status icon with tint color matching state
- Localized status labels
- Fixed 48pt height with 16pt horizontal padding
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockBetTicketStatusViewModel.wonMock()
let statusView = BetTicketStatusView(viewModel: viewModel)
```

## Data Model

```swift
enum BetTicketStatus: Equatable {
    case won
    case lost
    case draw
    case cashedOut
}

struct BetTicketStatusData: Equatable {
    let status: BetTicketStatus
}

protocol BetTicketStatusViewModelProtocol {
    var dataPublisher: AnyPublisher<BetTicketStatusData, Never> { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightSecondary` - won background
- `StyleProvider.Color.backgroundGradient2` - lost background
- `StyleProvider.Color.alertWarning` - draw background
- `StyleProvider.Color.buttonBackgroundSecondary` - cashed out background
- `StyleProvider.Color.alertError` - lost text color
- `StyleProvider.Color.allWhite` - default text and icon color
- `StyleProvider.fontWith(type: .bold, size: 16)` - status label font

## Mock ViewModels

Available presets:
- `.wonMock()` - green "Won" state with checkmark icon
- `.lostMock()` - red "Lost" state (icon hidden)
- `.drawMock()` - yellow "Draw" state (icon hidden)
- `.cashedOutMock()` - secondary "Cashed Out" state (icon hidden)
