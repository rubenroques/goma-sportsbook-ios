# TransactionItemView

A transaction history item card displaying category, status, amount, transaction ID, date, and balance.

## Overview

TransactionItemView displays a single transaction record with three rows: header (category, status badge, amount), transaction ID row with copy button, and footer (date, balance). It supports various transaction types including deposits, withdrawals, bets placed, bets won, and tax deductions. The component includes a status badge with color-coded backgrounds and configurable corner radius styles for use in grouped lists.

## Component Relationships

### Used By (Parents)
- Transaction history screens
- Wallet detail views
- Account statement lists

### Uses (Children)
- None (leaf component)

## Features

- Three-row layout (header, ID, footer)
- Status badge with color-coded backgrounds
- Amount display with +/- prefix and color
- Transaction ID with copy-to-clipboard button
- Date and balance display
- Configurable corner radius (all, top, bottom, none)
- Optional balance row (hidden when nil)
- Cell reuse support with reset()
- TableViewCell wrapper available

## Usage

```swift
let viewModel = MockTransactionItemViewModel.depositMock
let transactionView = TransactionItemView(viewModel: viewModel)

// With corner radius style for grouped lists
let topCard = TransactionItemView(
    viewModel: viewModel,
    cornerRadiusStyle: .topOnly
)

// Reconfigure for cell reuse
transactionView.configure(with: newViewModel)

// Update corner style only
transactionView.configure(with: .bottomOnly)

// Reset for reuse
transactionView.reset()
```

## Data Model

```swift
struct TransactionItemData {
    let id: String
    let category: String
    let status: TransactionStatus?
    let amount: Double
    let currency: String
    let transactionId: String
    let date: Date
    let balance: Double?
    let isPositive: Bool
    let amountIndicator: String?

    var formattedAmount: String
    var formattedDate: String
    var formattedBalance: String
}

enum TransactionStatus {
    case placed
    case won
    case lost
    case tax

    var displayName: String
    var backgroundColor: UIColor
    var textColor: UIColor
}

enum TransactionCornerRadiusStyle {
    case all
    case topOnly
    case bottomOnly
    case none
}

protocol TransactionItemViewModelProtocol {
    var data: TransactionItemData? { get }
    var balancePrefix: String { get }
    var balanceAmount: String { get }

    func copyTransactionId()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - wrapper background
- `StyleProvider.Color.backgroundTertiary` - container background
- `StyleProvider.Color.highlightTertiary` - category label, negative amounts
- `StyleProvider.Color.alertSuccess` - positive amounts
- `StyleProvider.Color.textPrimary` - transaction ID
- `StyleProvider.Color.textSecondary` - copy button tint
- `StyleProvider.Color.iconSecondary` - date, balance labels
- `StyleProvider.Color.separatorLine` - row separators
- `StyleProvider.fontWith(type: .regular, size: 14)` - category font
- `StyleProvider.fontWith(type: .medium, size: 12)` - status badge font
- `StyleProvider.fontWith(type: .medium, size: 14)` - amount, ID, date fonts
- `StyleProvider.fontWith(type: .bold, size: 14)` - balance amount font

Layout constants:
- Wrapper padding: 12pt all sides
- Container corner radius: 8pt
- Row heights: 44pt each
- Horizontal padding: 16pt
- Status badge corner radius: 12pt
- Status badge padding: 4pt vertical, 8pt horizontal
- Copy button size: 24pt x 24pt
- Separator height: 1pt

Icons:
- Copy button: "doc.on.clipboard" SF Symbol

## Mock ViewModels

Available presets:
- `.defaultMock` - Deposit transaction
- `.depositMock` - Deposit with balance
- `.withdrawalMock` - Negative withdrawal
- `.betPlacedMock` - Bet placed with status badge
- `.betWonMock` - Bet won with status badge
- `.taxMock` - Tax deduction with status badge
- `.emptyMock` - No data (nil)
- `.noBalanceMock` - Transaction without balance

Methods:
- `copyTransactionId()` - Copy ID to clipboard
