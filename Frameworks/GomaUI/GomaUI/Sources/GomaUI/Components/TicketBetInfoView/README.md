# TicketBetInfoView

A comprehensive betting ticket card displaying bet details, selections, financial summary, and cashout options.

## Overview

TicketBetInfoView displays complete information about a placed bet including header with title and bet ID, action buttons (rebet/cashout), ticket selections, financial summary (odds, stake, potential winnings), and optional cashout components. The component supports both pending and settled bet states with status indicators for won, lost, and draw outcomes. It includes loading overlay for cashout operations.

## Component Relationships

### Used By (Parents)
- My Bets screens
- Bet history views
- Cashout flow screens

### Uses (Children)
- `BetTicketStatusView` - settled bet status display
- `ButtonIconView` - rebet and cashout buttons
- `TicketSelectionView` - individual selection cards
- `CashoutAmountView` - partial cashout amount display
- `CashoutSliderView` - cashout amount slider

## Features

- Header with bet title, details, and navigation button
- Rebet and cashout action buttons
- Multiple ticket selection display
- Financial summary (total odds, bet amount, possible winnings)
- Settled bet status indicator (won/lost/draw)
- Cashout amount view for partial cashouts
- Cashout slider for selecting cashout amount
- Loading overlay during cashout operations
- Configurable corner radius styles (all, top, bottom)
- Cell reuse support with prepareForReuse()
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockTicketBetInfoViewModel.pendingMock()
let ticketView = TicketBetInfoView(viewModel: viewModel)

// With corner radius style
let topCornersView = TicketBetInfoView(
    viewModel: viewModel,
    cornerRadiusStyle: .topOnly
)

// Handle callbacks
viewModel.onNavigationTap = { navigateToBetDetails() }
viewModel.onRebetTap = { rebetTicket() }
viewModel.onCashoutTap = { initiateCashout() }

// Reconfigure for cell reuse
ticketView.configure(with: newViewModel)
```

## Data Model

```swift
struct TicketBetInfoData: Equatable {
    let id: String
    let title: String
    let betDetails: String
    let tickets: [TicketSelectionData]
    let totalOdds: String
    let betAmount: String
    let possibleWinnings: String
    let partialCashoutValue: String?
    let cashoutTotalAmount: String?
    let betStatus: BetTicketStatusData?
    let isSettled: Bool
}

enum CornerRadiusStyle {
    case all
    case topOnly
    case bottomOnly
}

protocol TicketBetInfoViewModelProtocol {
    var currentBetInfo: TicketBetInfoData { get }
    var betInfoPublisher: AnyPublisher<TicketBetInfoData, Never> { get }

    var rebetButtonViewModel: ButtonIconViewModelProtocol { get }
    var cashoutButtonViewModel: ButtonIconViewModelProtocol { get }
    var cashoutSliderViewModel: CashoutSliderViewModelProtocol? { get }
    var cashoutAmountViewModel: CashoutAmountViewModelProtocol? { get }

    var isCashoutLoading: Bool { get }
    var isCashoutLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var cashoutComponentsDidChangePublisher: AnyPublisher<Void, Never> { get }

    func handleNavigationTap()
    func handleRebetTap()
    func handleCashoutTap()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - wrapper background
- `StyleProvider.Color.backgroundTertiary` - container background
- `StyleProvider.Color.backgroundSecondary` - button backgrounds
- `StyleProvider.Color.highlightPrimary` - navigation button, separator
- `StyleProvider.Color.textPrimary` - title, value labels
- `StyleProvider.Color.textSecondary` - bet details label
- `StyleProvider.fontWith(type: .semibold, size: 14)` - title font
- `StyleProvider.fontWith(type: .regular, size: 10)` - details font
- `StyleProvider.fontWith(type: .semibold, size: 12)` - summary labels

Layout constants:
- Wrapper corner radius: 8pt
- Main stack corner radius: 8pt
- Container padding: 8pt from wrapper
- Header padding: 8pt from container
- Action buttons height: 24pt
- Button corner radius: 12pt
- Separator height: 1pt
- Navigation button size: 24pt

## Mock ViewModels

Available presets:
- `.pendingMock()` - Single pending bet
- `.multipleTicketsMock()` - Multiple selections
- `.longCompetitionNamesMock()` - Overflow text test
- `.pendingMockWithCashout()` - With cashout amount view
- `.pendingMockWithSlider()` - With cashout slider
- `.pendingMockWithBoth()` - Both cashout components
- `.wonBetMock()` - Settled won bet
- `.lostBetMock()` - Settled lost bet
- `.drawBetMock()` - Settled draw bet

Methods:
- `configure(with:)` - Reconfigure with new ViewModel
- `prepareForReuse()` - Clear state for cell reuse
- `updateBetInfo(_:)` - Update bet data reactively
