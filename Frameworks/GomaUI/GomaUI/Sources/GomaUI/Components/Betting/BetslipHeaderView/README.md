# BetslipHeaderView

A betslip header displaying user authentication state with balance or login prompts.

## Overview

BetslipHeaderView adapts its content based on user authentication status. For logged-in users, it shows their balance. For guests, it displays "Join Now" and "Log In" action buttons. A close button is always visible for dismissing the betslip.

## Component Relationships

### Used By (Parents)
- None (standalone component, typically at top of betslip screen)

### Uses (Children)
- None (leaf component)

## Features

- Two authentication states: notLoggedIn and loggedIn
- Betslip icon with title on left side
- Auth buttons with underline styling for guests
- Balance display for logged-in users
- Close button always visible on right
- Enabled/disabled state with alpha dimming
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockBetslipHeaderViewModel.loggedInMock()
let headerView = BetslipHeaderView(viewModel: viewModel)

viewModel.onCloseTapped = {
    // Dismiss betslip
}
```

## Data Model

```swift
enum BetslipHeaderState: Equatable {
    case notLoggedIn
    case loggedIn(balance: String)
}

struct BetslipHeaderData: Equatable {
    let state: BetslipHeaderState
    let isEnabled: Bool
}

protocol BetslipHeaderViewModelProtocol {
    var dataPublisher: AnyPublisher<BetslipHeaderData, Never> { get }
    var currentData: BetslipHeaderData { get }
    func updateState(_ state: BetslipHeaderState)
    func setEnabled(_ isEnabled: Bool)

    var onJoinNowTapped: (() -> Void)? { get set }
    var onLogInTapped: (() -> Void)? { get set }
    var onCloseTapped: (() -> Void)? { get set }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - container background
- `StyleProvider.Color.highlightPrimary` - betslip icon and close button tint
- `StyleProvider.Color.highlightPrimaryContrast` - text and button colors
- `StyleProvider.fontWith(type: .bold, size: 14)` - betslip title and balance value font
- `StyleProvider.fontWith(type: .regular, size: 14)` - balance label font
- `StyleProvider.fontWith(type: .medium, size: 14)` - auth button underlined font

## Mock ViewModels

Available presets:
- `.notLoggedInMock()` - shows Join Now | or | Log In buttons
- `.loggedInMock()` - shows "Balance: XAF 50,000"
