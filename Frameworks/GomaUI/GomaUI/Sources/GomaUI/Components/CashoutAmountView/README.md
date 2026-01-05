# CashoutAmountView

A compact display component showing cashout title and amount with currency.

## Overview

CashoutAmountView displays a simple row with a title label on the left and a formatted currency amount on the right. It's designed for showing partial or full cashout amounts within bet ticket interfaces, with a rounded container background.

## Component Relationships

### Used By (Parents)
- `TicketBetInfoView` - displays cashout amount within bet ticket

### Uses (Children)
- None (leaf component)

## Features

- Title and amount horizontal layout
- Currency symbol prefix
- Secondary background with 8pt corner radius
- Fixed 35pt height
- Bold amount styling
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCashoutAmountViewModel.defaultMock()
let cashoutAmountView = CashoutAmountView(viewModel: viewModel)
```

## Data Model

```swift
struct CashoutAmountData: Equatable {
    let title: String
    let currency: String
    let amount: String
}

protocol CashoutAmountViewModelProtocol {
    var dataPublisher: AnyPublisher<CashoutAmountData, Never> { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.Color.textPrimary` - title and amount text color
- `StyleProvider.fontWith(type: .regular, size: 14)` - title font
- `StyleProvider.fontWith(type: .bold, size: 14)` - amount font

## Mock ViewModels

Available presets:
- `.defaultMock()` - "Partial Cashout" with XAF 32.00
- `.customMock(title:currency:amount:)` - custom values
