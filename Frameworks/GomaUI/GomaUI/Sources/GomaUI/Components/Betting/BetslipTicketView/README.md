# BetslipTicketView

A betslip ticket card displaying match details, selection, and odds with live updates.

## Overview

BetslipTicketView presents a single bet selection within the betslip. It shows league, match date, team names, the user's selected outcome, and current odds. The component supports animated odds change indicators (up/down arrows) and a swipe-to-delete affordance via the left strip close button.

## Component Relationships

### Used By (Parents)
- None (standalone component, typically in a list within betslip screen)

### Uses (Children)
- None (leaf component)

## Features

- Left strip with close/remove tap gesture
- League and date info line
- Home and away team display
- Selected outcome with "Your Selection" label
- Odds value with animated change indicators (up/down arrows)
- Odds change animations with 4-second auto-hide
- Disabled state overlay with message
- Enabled/disabled alpha dimming
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockBetslipTicketViewModel.typicalMock()
let ticketView = BetslipTicketView(viewModel: viewModel)

viewModel.onCloseTapped = {
    // Remove ticket from betslip
}
```

## Data Model

```swift
enum OddsChangeState: Equatable {
    case none
    case increased
    case decreased
}

struct BetslipTicketData: Equatable {
    let leagueName: String
    let startDate: String
    let homeTeam: String
    let awayTeam: String
    let selectedTeam: String
    let oddsValue: String
    let oddsChangeState: OddsChangeState
    let isEnabled: Bool
    let bettingOfferId: String?
    let disabledMessage: String?
}

protocol BetslipTicketViewModelProtocol: AnyObject {
    var dataPublisher: AnyPublisher<BetslipTicketData, Never> { get }
    var oddsChangeStatePublisher: AnyPublisher<OddsChangeState, Never> { get }
    var currentData: BetslipTicketData { get }
    var onCloseTapped: (() -> Void)? { get set }

    func updateOddsValue(_ oddsValue: String)
    func updateOddsChangeState(_ state: OddsChangeState)
    func setEnabled(_ isEnabled: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container and disabled overlay background
- `StyleProvider.Color.highlightPrimary` - left strip tint, close icon, and outcome/odds colors
- `StyleProvider.Color.textPrimary` - team name colors
- `StyleProvider.Color.textSecondary` - league/date and selection label colors
- `StyleProvider.Color.alertSuccess` - up arrow (odds increased)
- `StyleProvider.Color.alertError` - down arrow (odds decreased)
- `StyleProvider.fontWith(type: .bold, size: 14)` - team names font
- `StyleProvider.fontWith(type: .bold, size: 16)` - odds value font
- `StyleProvider.fontWith(type: .bold, size: 12)` - outcome font
- `StyleProvider.fontWith(type: .regular, size: 12)` - league/date font
- `StyleProvider.fontWith(type: .medium, size: 10)` - selection label font

## Mock ViewModels

Available presets:
- `.typicalMock()` - standard ticket with no odds change
- `.increasedOddsMock()` - shows green up arrow
- `.decreasedOddsMock()` - shows red down arrow
- `.disabledMock()` - dimmed with disabled overlay
