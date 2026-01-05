# BetslipFloatingView

Floating betslip indicators showing selection count and odds boost progress.

## Overview

BetslipFloatingView provides two view variants (tall and thin) for displaying betslip status as floating overlays. The tall variant shows odds boost promotion progress with animated segments, while the thin variant provides a compact display. Both hide automatically when no tickets are present.

## Component Relationships

### Used By (Parents)
- None (standalone floating component, typically anchored to bottom of screen)

### Uses (Children)
- `ProgressSegments` (internal) - animated progress bar segments

## Features

- Two display variants: `BetslipFloatingTallView` and `BetslipFloatingThinView`
- Odds boost promotion display with percentage tiers
- Animated progress segments showing selections toward boost
- Auto-hide when no tickets or no boost available
- Shadow effect for floating appearance
- Tap gesture for opening betslip
- 12pt corner radius on container
- Reactive updates via Combine publisher

## Usage

```swift
// Tall variant with boost progress
let viewModel = MockBetslipFloatingViewModel(
    state: .withTickets(
        selectionCount: 2,
        odds: "5.71",
        winBoostPercentage: nil,
        totalEligibleCount: 3,
        nextTierPercentage: "5%"
    )
)
let floatingView = BetslipFloatingTallView(viewModel: viewModel)
```

## Data Model

```swift
enum BetslipFloatingState: Equatable {
    case noTickets
    case withTickets(
        selectionCount: Int,
        odds: String,
        winBoostPercentage: String?,
        totalEligibleCount: Int,
        nextTierPercentage: String?
    )
}

struct BetslipFloatingData: Equatable {
    let state: BetslipFloatingState
    let isEnabled: Bool
}

protocol BetslipFloatingViewModelProtocol {
    var dataPublisher: AnyPublisher<BetslipFloatingData, Never> { get }
    var currentData: BetslipFloatingData { get }
    var onBetslipTapped: (() -> Void)? { get set }
    func updateState(_ state: BetslipFloatingState)
    func setEnabled(_ isEnabled: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundGradient2` - container background
- `StyleProvider.Color.highlightPrimary` - title and boost icon color
- `StyleProvider.Color.textPrimary` - heading text color
- `StyleProvider.Color.textSecondary` - description text color
- `StyleProvider.fontWith(type: .bold, size: 12)` - title font
- `StyleProvider.fontWith(type: .bold, size: 16)` - heading font
- `StyleProvider.fontWith(type: .regular, size: 12)` - description font

## Mock ViewModels

Available via `MockBetslipFloatingViewModel(state:isEnabled:)`:
- `.noTickets` - hidden state
- `.withTickets(selectionCount:odds:winBoostPercentage:totalEligibleCount:nextTierPercentage:)` - visible with progress
