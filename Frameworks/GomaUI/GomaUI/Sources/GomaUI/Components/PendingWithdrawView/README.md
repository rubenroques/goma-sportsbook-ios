# PendingWithdrawView

A card displaying pending withdrawal transaction details with date, status badge, amount, and transaction ID.

## Overview

PendingWithdrawView shows information about a pending withdrawal transaction including the date/time, status with a styled badge, amount value, and a copyable transaction ID. The component is typically used in wallet detail views to display withdrawal requests that are still being processed.

## Component Relationships

### Used By (Parents)
- `WalletDetailView`

### Uses (Children)
- None (leaf component)

## Features

- Date/time label
- Status badge with customizable colors and border
- Amount display with title and value
- Transaction ID with copy button
- Copy to clipboard functionality
- SF Symbols and custom image support for copy icon
- Rounded container with secondary background
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockPendingWithdrawViewModel()
let pendingView = PendingWithdrawView(viewModel: viewModel)

// Handle copy action
viewModel.onCopyRequested = { transactionId in
    UIPasteboard.general.string = transactionId
    showCopiedToast()
}

// Update with new state
viewModel.update(displayState: PendingWithdrawViewDisplayState(
    dateText: "05/08/2025, 11:17",
    statusText: "In Progress",
    statusStyle: PendingWithdrawStatusStyle(
        textColor: .systemGreen,
        backgroundColor: .systemGreen.withAlphaComponent(0.2),
        borderColor: .systemGreen
    ),
    amountValueText: "XAF 200,000",
    transactionIdValueText: "HFD90230NRF"
))
```

## Data Model

```swift
struct PendingWithdrawViewDisplayState {
    let dateText: String
    let statusText: String
    let statusStyle: PendingWithdrawStatusStyle
    let amountTitleText: String      // Default: "Amount"
    let amountValueText: String
    let transactionIdTitleText: String // Default: "Transaction ID"
    let transactionIdValueText: String
    let copyIconName: String?        // Default: "doc.on.doc"
}

struct PendingWithdrawStatusStyle {
    let textColor: UIColor
    let backgroundColor: UIColor
    let borderColor: UIColor?
}

protocol PendingWithdrawViewModelProtocol: AnyObject {
    var currentDisplayState: PendingWithdrawViewDisplayState { get }
    var displayStatePublisher: AnyPublisher<PendingWithdrawViewDisplayState, Never> { get }

    func handleCopyTransactionID()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.Color.backgroundPrimary` - view background (via parent)
- `StyleProvider.Color.textPrimary` - date, amount title/value, transaction title/value
- `StyleProvider.Color.buttonActiveHoverPrimary` - default status text color
- `StyleProvider.Color.myTicketsWonFaded` - default status badge background
- `StyleProvider.Color.highlightPrimary` - copy button tint
- `StyleProvider.fontWith(type: .regular, size: 12)` - date, amount title, transaction title
- `StyleProvider.fontWith(type: .semibold, size: 12)` - status label
- `StyleProvider.fontWith(type: .bold, size: 12)` - amount value, transaction value

Layout constants:
- Container corner radius: 8pt
- Container padding: 8pt all sides
- Content stack spacing: 8pt
- Header/amount/transaction stack spacing: 6pt
- Status badge height: 24pt
- Status badge insets: 4pt vertical, 12pt horizontal
- Status badge corner radius: 12pt
- Copy button size: 24pt x 24pt
- Copy button padding: 4pt

Icon resolution:
1. First tries custom image (UIImage(named:))
2. Falls back to SF Symbol (UIImage(systemName:))

## Mock ViewModels

Available presets:
- `MockPendingWithdrawViewModel()` - Default with sample pending state
- `.samplePending` - Static sample state: "05/08/2025, 11:17", "In Progress", XAF 200,000
