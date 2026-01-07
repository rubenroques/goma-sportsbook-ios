# WalletStatusView

A wallet balance status display with multiple balance lines and deposit/withdraw action buttons.

## Overview

WalletStatusView displays a vertical list of wallet balance information including total balance (with icon), current balance, bonus, cashback, and withdrawable amount. Features separator lines between sections and deposit/withdraw buttons at the bottom. Used in wallet overlays, dialogs, and account balance summaries.

## Component Relationships

### Used By (Parents)
- Wallet overlay dialogs
- Balance summary sections
- Account status views

### Uses (Children)
- `ButtonView` - for deposit and withdraw actions
- `WalletBalanceLineView` - individual balance rows

## Features

- Multiple balance line displays
- Total balance with cash icon
- Separator lines between sections
- Deposit button (solid style)
- Withdraw button (bordered style)
- Reactive balance updates via Combine
- Button tap callbacks
- Tertiary background styling
- Rounded corners

## Usage

```swift
let viewModel = MockWalletStatusViewModel.defaultMock
let walletStatus = WalletStatusView(viewModel: viewModel)

// Handle button taps
walletStatus.onDepositButtonTapped = {
    navigateToDeposit()
}
walletStatus.onWithdrawButtonTapped = {
    navigateToWithdraw()
}

// Empty balance state
let emptyViewModel = MockWalletStatusViewModel.emptyBalanceMock
let emptyStatus = WalletStatusView(viewModel: emptyViewModel)

// High balance state
let highViewModel = MockWalletStatusViewModel.highBalanceMock
let highBalanceStatus = WalletStatusView(viewModel: highViewModel)
```

## Data Model

```swift
protocol WalletStatusViewModelProtocol {
    var totalBalancePublisher: AnyPublisher<String, Never> { get }
    var currentBalancePublisher: AnyPublisher<String, Never> { get }
    var bonusBalancePublisher: AnyPublisher<String, Never> { get }
    var cashbackBalancePublisher: AnyPublisher<String, Never> { get }
    var withdrawableAmountPublisher: AnyPublisher<String, Never> { get }
    var depositButtonViewModel: ButtonViewModelProtocol { get }
    var withdrawButtonViewModel: ButtonViewModelProtocol { get }

    func setTotalBalance(amount: String)
    func setCurrentBalance(amount: String)
    func setBonusBalance(amount: String)
    func setCashbackBalance(amount: String)
    func setWithdrawableBalance(amount: String)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - container background
- `StyleProvider.Color.separatorLine` - separator lines
- `StyleProvider.fontWith(type: .medium, size: 14)` - balance labels

Layout constants:
- Container corner radius: 8pt
- Container padding: 16pt all sides
- Stack spacing: 8pt vertical
- Separator height: 1pt
- Button spacing: 2pt before buttons
- Button height: 34pt
- Button font size: 12pt

Balance lines:
- Total balance: includes banknote cash icon
- Current balance: text only
- Bonus balance: text only
- Cashback balance: text only
- Withdrawable: text only

## Callbacks

- `onDepositButtonTapped: (() -> Void)?` - Called when deposit button tapped
- `onWithdrawButtonTapped: (() -> Void)?` - Called when withdraw button tapped

## Mock ViewModels

Available presets:
- `.defaultMock` - Standard wallet (2,000.01 total)
- `.emptyBalanceMock` - All balances at 0.00
- `.highBalanceMock` - Large amounts (15,750.50 total)
- `.bonusOnlyMock` - Only bonus balance, no withdrawable

Test helper methods:
- `simulateBalanceUpdate(total:current:bonus:cashback:withdrawable:)` - Update specific balances
- `simulateDepositComplete(amount:)` - Simulate deposit
- `simulateWithdrawalComplete(amount:)` - Simulate withdrawal
