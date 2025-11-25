# CompactOutcomesLineView

A compact single-line outcomes display for inline match cards. Displays 2-3 OutcomeItemView instances horizontally.

## Overview

`CompactOutcomesLineView` provides a simplified outcomes row for compact match cards. Unlike `MarketOutcomesLineView`, it:
- Only supports single-line display (no multi-line)
- No market name pill
- No suspended/seeAll states
- Simpler layout for card integration

## Architecture

### Files
```
CompactOutcomesLineView/
├── CompactOutcomesLineView.swift              # Main view
├── CompactOutcomesLineViewModelProtocol.swift # Protocol + data models
├── MockCompactOutcomesLineViewModel.swift     # Mock implementation
└── Documentation/
    └── README.md
```

### Component Structure
```
CompactOutcomesLineView
├── containerStackView (horizontal, fillEqually)
│   ├── OutcomeItemView (left - "1")
│   ├── OutcomeItemView (middle - "X", hidden in double mode)
│   └── OutcomeItemView (right - "2")
```

## Usage

### Basic Usage

```swift
// 3-way market (Football)
let threeWayView = CompactOutcomesLineView(
    viewModel: MockCompactOutcomesLineViewModel.threeWayMarket
)

// 2-way market (Tennis)
let twoWayView = CompactOutcomesLineView(
    viewModel: MockCompactOutcomesLineViewModel.twoWayMarket
)
```

### Handle Selection Callbacks

```swift
outcomesView.onOutcomeSelected = { [weak self] outcomeId, outcomeType in
    self?.coordinator?.addToBetslip(outcomeId: outcomeId)
}

outcomesView.onOutcomeDeselected = { [weak self] outcomeId, outcomeType in
    self?.coordinator?.removeFromBetslip(outcomeId: outcomeId)
}
```

### Cell Reuse

```swift
override func prepareForReuse() {
    super.prepareForReuse()
    outcomesView.cleanupForReuse()
}

func configure(with viewModel: CompactOutcomesLineViewModelProtocol) {
    outcomesView.configure(with: viewModel)

    // Re-establish callbacks after configure
    outcomesView.onOutcomeSelected = { ... }
    outcomesView.onOutcomeDeselected = { ... }
}
```

## Display Modes

### Double (2-way)
```
[   1   ] [   2   ]
[  2.90 ] [  3.05 ]
```

Used for:
- Tennis (Player 1 / Player 2)
- Over/Under markets
- Yes/No markets

### Triple (3-way)
```
[   1   ] [   X   ] [   2   ]
[  2.90 ] [  3.05 ] [  2.68 ]
```

Used for:
- Football 1X2
- Home/Draw/Away markets

## Data Models

### CompactOutcomesDisplayMode

```swift
enum CompactOutcomesDisplayMode {
    case double  // 2 outcomes
    case triple  // 3 outcomes
}
```

### CompactOutcomesLineDisplayState

```swift
struct CompactOutcomesLineDisplayState {
    let displayMode: CompactOutcomesDisplayMode
    let leftOutcome: OutcomeItemData?
    let middleOutcome: OutcomeItemData?  // nil for double mode
    let rightOutcome: OutcomeItemData?
}
```

## Mock Configurations

### 3-Way Markets
```swift
MockCompactOutcomesLineViewModel.threeWayMarket      // Standard 1X2
MockCompactOutcomesLineViewModel.withSelectedOutcome // With selection
MockCompactOutcomesLineViewModel.highOdds            // High odds values
```

### 2-Way Markets
```swift
MockCompactOutcomesLineViewModel.twoWayMarket        // Standard 1/2
MockCompactOutcomesLineViewModel.overUnderMarket     // Over/Under
MockCompactOutcomesLineViewModel.twoWayWithSelection // With selection
```

### Special States
```swift
MockCompactOutcomesLineViewModel.lockedMarket        // All locked
MockCompactOutcomesLineViewModel.withOddsChanges     // Odds arrows
```

## Integration with InlineMatchCardView

```swift
// In InlineMatchCardView
private lazy var outcomesView = CompactOutcomesLineView()

// Configuration
func configureOutcomes(with viewModel: CompactOutcomesLineViewModelProtocol) {
    outcomesView.configure(with: viewModel)
    setupOutcomesCallbacks()
}

private func setupOutcomesCallbacks() {
    outcomesView.onOutcomeSelected = { [weak self] id, type in
        self?.onOutcomeSelected(id)
        self?.viewModel?.onOutcomeSelected(outcomeId: id)
    }
}
```

## Differences from MarketOutcomesLineView

| Feature | CompactOutcomesLineView | MarketOutcomesLineView |
|---------|------------------------|------------------------|
| Multi-line | No | Yes |
| Market name pill | No | Yes |
| Suspended state | No | Yes |
| See All state | No | Yes |
| Use case | Inline cards | Full market display |

## Styling

Uses `OutcomeItemView` directly, inheriting all its styling:
- Background: `StyleProvider.Color.backgroundOdds`
- Selected: `StyleProvider.Color.highlightPrimary`
- Text: `StyleProvider.fontWith(type: .bold, size: 16)`

## Constants

```swift
stackSpacing: 4.0pt      // Between outcomes
outcomeHeight: 52.0pt    // Fixed height
outcomeMinWidth: 60.0pt  // Minimum width per outcome
```
