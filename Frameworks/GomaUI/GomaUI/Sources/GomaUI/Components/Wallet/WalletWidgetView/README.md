# WalletWidgetView

A compact wallet widget displaying balance with dropdown indicator and deposit button for toolbar integration.

## Overview

WalletWidgetView provides a compact horizontal widget showing the current wallet balance with a chevron dropdown indicator and a deposit action button. The balance section has a semi-transparent background, while the deposit button uses a solid white background. Designed for integration into navigation bars and toolbar views.

## Component Relationships

### Used By (Parents)
- `MultiWidgetToolbarView` - toolbar with multiple widgets

### Uses (Children)
- None (leaf component)

## Features

- Compact horizontal layout
- Balance display with dropdown chevron
- Deposit button with solid background
- Tap callback for balance area
- Deposit tap callback
- Reactive balance updates via Combine
- Widget type identifier for tracking
- Fixed 32pt height

## Usage

```swift
let viewModel = MockWalletWidgetViewModel.defaultMock
let walletWidget = WalletWidgetView(viewModel: viewModel)

// Handle tap events
walletWidget.onBalanceTapped = { widgetId in
    showWalletDetails(for: widgetId)
}
walletWidget.onDepositTapped = { widgetId in
    navigateToDeposit(for: widgetId)
}

// Custom balance
let customViewModel = MockWalletWidgetViewModel(
    walletData: WalletWidgetData(
        id: .wallet,
        balance: "50,250.75",
        depositButtonTitle: "DEPOSIT"
    )
)
let customWidget = WalletWidgetView(viewModel: customViewModel)

// Update balance dynamically
viewModel.updateBalance("3,500.00")
```

## Data Model

```swift
struct WalletWidgetData: Equatable, Hashable {
    let id: WidgetTypeIdentifier
    let balance: String
    let depositButtonTitle: String
}

struct WalletWidgetDisplayState: Equatable {
    let walletData: WalletWidgetData
}

protocol WalletWidgetViewModelProtocol {
    var displayStatePublisher: AnyPublisher<WalletWidgetDisplayState, Never> { get }
    func deposit()
    func updateBalance(_ balance: String)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimaryContrast` - balance container background (0.1 alpha)
- `StyleProvider.Color.allWhite` - balance text, chevron, deposit button background
- `StyleProvider.Color.topBarGradient1` - deposit button text
- `StyleProvider.fontWith(type: .semibold, size: 14)` - balance label
- `StyleProvider.fontWith(type: .bold, size: 14)` - deposit button

Layout constants:
- Widget height: 32pt (fixed)
- Container corner radius: 8pt
- Balance container padding: 12pt left, 6pt right
- Balance stack spacing: 5pt
- Chevron width: 12pt
- Deposit button padding: 6pt horizontal

Corner masking:
- Balance container: left corners only
- Deposit button: right corners only

Icons:
- Chevron: SF Symbol "chevron.down"

## Callbacks

- `onDepositTapped: ((WidgetTypeIdentifier) -> Void)` - Called when deposit button tapped
- `onBalanceTapped: ((WidgetTypeIdentifier) -> Void)` - Called when balance area tapped

## Mock ViewModels

Available presets:
- `.defaultMock` - Standard wallet with 2,000.00 balance

Factory initialization:
```swift
MockWalletWidgetViewModel(walletData: WalletWidgetData)
```

Methods:
- `updateBalance(_:)` - Update displayed balance
- `deposit()` - Called when deposit button tapped
