# BetInfoSubmissionView

A comprehensive bet submission form with summary, amount input, and place bet action.

## Overview

BetInfoSubmissionView provides the complete bet placement interface including bet summary rows (odds, potential winnings, win bonus, payout), an amount input field with quick-add buttons (+100, +250, +500), and a place bet button. The component coordinates multiple child view models for a cohesive betting experience.

## Component Relationships

### Used By (Parents)
- None (standalone component, typically used in betslip screens)

### Uses (Children)
- `BetSummaryRowView` - displays odds, potential winnings, win bonus, and payout rows
- `BorderedTextFieldView` - amount input field
- `ButtonView` - place bet button
- `QuickAddButtonView` - quick amount add buttons (+100, +250, +500)

## Features

- Four bet summary rows with live values
- Amount text field with numeric keyboard
- Three quick-add buttons for common amounts
- Place bet button with dynamic title showing amount
- Enabled/disabled state management
- Ticket validation integration
- Return key dismisses keyboard
- Reactive updates via Combine publisher
- Currency-aware formatting

## Usage

```swift
let viewModel = MockBetInfoSubmissionViewModel.defaultMock(currency: "XAF")
let submissionView = BetInfoSubmissionView(viewModel: viewModel)

viewModel.onPlaceBetTapped = {
    print("Place bet tapped with amount: \(viewModel.currentData.amount)")
}
```

## Data Model

```swift
struct BetInfoSubmissionData: Equatable {
    let odds: String
    let potentialWinnings: String
    let winBonus: String
    let payout: String
    let amount: String
    let placeBetAmount: String
    let isEnabled: Bool
    let currency: String
}

protocol BetInfoSubmissionViewModelProtocol {
    var dataPublisher: AnyPublisher<BetInfoSubmissionData, Never> { get }
    var currentData: BetInfoSubmissionData { get }

    // Child view models
    var oddsRowViewModel: BetSummaryRowViewModelProtocol { get }
    var potentialWinningsRowViewModel: BetSummaryRowViewModelProtocol { get }
    var winBonusRowViewModel: BetSummaryRowViewModelProtocol { get }
    var payoutRowViewModel: BetSummaryRowViewModelProtocol { get }
    var amount100ButtonViewModel: QuickAddButtonViewModelProtocol { get }
    var amount250ButtonViewModel: QuickAddButtonViewModelProtocol { get }
    var amount500ButtonViewModel: QuickAddButtonViewModelProtocol { get }
    var amountTextFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var placeBetButtonViewModel: ButtonViewModelProtocol { get }

    // Actions
    func onQuickAddTapped(_ amount: Int)
    func onAmountChanged(_ amount: String)
    var onPlaceBetTapped: (() -> Void)? { get set }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background with 8pt corner radius
- Inherits styling from child components

## Mock ViewModels

Available presets:
- `.defaultMock(currency:)` - empty state with zero values
- `.withAmountsMock(potentialWinnings:winBonus:payout:amount:currency:)` - preset values
- `.disabledMock(currency:)` - disabled state
