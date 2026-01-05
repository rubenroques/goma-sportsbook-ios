# DepositBonusInfoView

A gradient banner displaying deposit bonus information with icon and currency amount.

## Overview

DepositBonusInfoView displays a horizontal banner with a diagonal gradient background showing deposit bonus details. It includes an icon on the left, descriptive text in the center, and a currency amount on the right. The component is commonly used on deposit screens to show the user's potential bonus amount.

## Component Relationships

### Used By (Parents)
- None (standalone banner component)

### Uses (Children)
- `GradientView` - diagonal gradient background

## Features

- Diagonal gradient background (live border colors)
- Left icon (asset or SF Symbol, white tinted)
- Balance description text
- Right-aligned currency amount
- 8pt corner radius
- 16pt internal padding
- Fixed 60pt height in previews
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockDepositBonusInfoViewModel.defaultMock
let bonusInfoView = DepositBonusInfoView(viewModel: viewModel)

// Update amount dynamically
viewModel.updateAmount("XAF 10,000")
```

## Data Model

```swift
struct DepositBonusInfoData: Equatable, Hashable {
    let id: String
    let icon: String
    let balanceText: String
    let currencyAmount: String
}

protocol DepositBonusBalanceViewModelProtocol {
    var depositBonusInfoPublisher: AnyPublisher<DepositBonusInfoData, Never> { get }

    func updateAmount(_ newAmount: String)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.liveBorder1` - gradient start color
- `StyleProvider.Color.liveBorder2` - gradient end color
- `StyleProvider.Color.buttonTextPrimary` - balance text color
- `StyleProvider.Color.allWhite` - icon tint color
- `StyleProvider.fontWith(type: .medium, size: 12)` - balance text font
- `StyleProvider.fontWith(type: .bold, size: 12)` - currency amount font

Layout constants:
- Container corner radius: 8pt
- Icon size: 24pt
- Stack spacing: 12pt
- Padding: 16pt all sides

## Mock ViewModels

Available presets:
- `.defaultMock` - "Your deposit + Bonus" with "XAF --" amount, gift icon
- `.usdMock` - "Your deposit + Bonus" with "USD $150.00" amount, SF Symbol gift icon
