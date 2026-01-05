# WalletDetailView

A comprehensive wallet display with gradient background, multiple balance lines, action buttons, and pending withdrawals section.

## Overview

WalletDetailView displays a complete wallet summary with header (title, phone number), multiple balance rows (total, current, bonus, cashback, withdrawable), and deposit/withdraw action buttons. Features a horizontal gradient background and an optional expandable pending withdrawals section. Used in wallet screens and account detail views for showing full financial status.

## Component Relationships

### Used By (Parents)
- Wallet screens
- Account detail views
- Profile wallet sections

### Uses (Children)
- `ButtonView` - for deposit and withdraw actions
- `CustomExpandableSectionView` - for pending withdrawals
- `PendingWithdrawView` - individual pending withdrawal items
- `WalletDetailHeaderView` - wallet title and phone number
- `WalletDetailBalanceView` - balance lines display
- `GradientView` - gradient background

## Features

- Horizontal gradient background
- Multiple balance line displays
- Deposit and withdraw buttons
- Pending withdrawals expandable section
- Reactive balance updates via Combine
- Loading state support
- Long press for legacy cashier (DEBUG only)
- Phone number display

## Usage

```swift
let viewModel = MockWalletDetailViewModel.defaultMock
let walletView = WalletDetailView(viewModel: viewModel)

// Empty wallet state
let emptyViewModel = MockWalletDetailViewModel.emptyBalanceMock
let emptyWallet = WalletDetailView(viewModel: emptyViewModel)

// High balance state
let highBalanceViewModel = MockWalletDetailViewModel.highBalanceMock
let highBalanceWallet = WalletDetailView(viewModel: highBalanceViewModel)

// With pending withdrawals
let pendingViewModel = MockWalletDetailViewModel.defaultMock
pendingViewModel.pendingWithdrawSectionViewModel = MockCustomExpandableSectionViewModel(
    title: "Pending Withdraws",
    isExpanded: false,
    leadingIconName: "arrow.down.circle"
)
let walletWithPending = WalletDetailView(viewModel: pendingViewModel)
```

## Data Model

```swift
struct WalletDetailData: Equatable, Hashable {
    let walletTitle: String
    let phoneNumber: String
    let totalBalance: String
    let currentBalance: String
    let bonusBalance: String
    let cashbackBalance: String
    let withdrawableAmount: String
}

struct WalletDetailDisplayState: Equatable {
    let walletData: WalletDetailData
    let isLoading: Bool
}

protocol WalletDetailViewModelProtocol {
    var displayStatePublisher: AnyPublisher<WalletDetailDisplayState, Never> { get }
    var totalBalancePublisher: AnyPublisher<String, Never> { get }
    var currentBalancePublisher: AnyPublisher<String, Never> { get }
    var bonusBalancePublisher: AnyPublisher<String, Never> { get }
    var cashbackBalancePublisher: AnyPublisher<String, Never> { get }
    var withdrawableAmountPublisher: AnyPublisher<String, Never> { get }
    var withdrawButtonViewModel: ButtonViewModelProtocol { get }
    var depositButtonViewModel: ButtonViewModelProtocol { get }
    var pendingWithdrawSectionViewModel: CustomExpandableSectionViewModelProtocol? { get set }
    var pendingWithdrawViewModels: [PendingWithdrawViewModelProtocol] { get set }
    var pendingWithdrawViewModelsPublisher: AnyPublisher<[PendingWithdrawViewModelProtocol], Never> { get }

    func performWithdraw()
    func performDeposit()
    func refreshWalletData()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundGradientDark` - gradient start color
- `StyleProvider.Color.backgroundGradientLight` - gradient end color
- `StyleProvider.fontWith(type: .bold, size: 16)` - title font

Layout constants:
- Container corner radius: 8pt
- Stack spacing: 12pt vertical
- Content padding: 16pt all sides
- Button container height: 40pt
- Button spacing: 12pt horizontal

Gradient:
- Direction: horizontal (left to right)
- Colors: backgroundGradientDark to backgroundGradientLight

## Mock ViewModels

Available presets:
- `.defaultMock` - Standard wallet with 2,000.00 total
- `.emptyBalanceMock` - All balances at 0.00
- `.highBalanceMock` - Large amounts (150,000.50)
- `.bonusOnlyMock` - Only bonus balance (500.00), no withdrawable
- `.cashbackFocusMock` - Emphasis on cashback balance

Test helper methods:
- `simulateBalanceUpdate(total:current:bonus:cashback:withdrawable:)` - Update specific balances
- `simulateLoadingState()` - Show loading indicator
- `simulateDepositComplete(amount:)` - Simulate deposit transaction
- `simulateWithdrawalComplete(amount:)` - Simulate withdrawal transaction
