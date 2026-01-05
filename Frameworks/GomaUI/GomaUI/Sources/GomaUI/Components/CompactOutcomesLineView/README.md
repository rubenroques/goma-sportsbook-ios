# CompactOutcomesLineView

A compact single-line display of betting outcomes for inline match cards.

## Overview

CompactOutcomesLineView displays 2-3 OutcomeItemView instances horizontally in a fixed-height row. It supports both 2-way markets (tennis, over/under) and 3-way markets (football 1X2). The component manages child outcome views efficiently, handling selection states through publishers and supporting cell reuse.

## Component Relationships

### Used By (Parents)
- `InlineMatchCardView` - outcomes section of inline match cards

### Uses (Children)
- `OutcomeItemView` - individual betting outcomes (2-3 instances)

## Features

- Two display modes: double (2-way) and triple (3-way)
- Fixed 50pt row height
- 4pt spacing between outcomes
- Equal-width outcome distribution
- Minimum 60pt width per outcome
- Selection state management via publishers
- Odds change direction indicators
- Locked outcome support
- Cell reuse support via cleanupForReuse()
- Clear background
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockCompactOutcomesLineViewModel.threeWayMarket
let outcomesLine = CompactOutcomesLineView(viewModel: viewModel)

outcomesLine.onOutcomeSelected = { outcomeId, outcomeType in
    print("Selected outcome \(outcomeId) at position \(outcomeType)")
}

outcomesLine.onOutcomeDeselected = { outcomeId, outcomeType in
    print("Deselected outcome \(outcomeId)")
}
```

## Data Model

```swift
enum CompactOutcomesDisplayMode: Equatable, Hashable {
    case double  // 2 outcomes (tennis, over/under)
    case triple  // 3 outcomes (football 1X2)
}

struct CompactOutcomesLineDisplayState: Equatable, Hashable {
    let displayMode: CompactOutcomesDisplayMode
    let leftOutcome: OutcomeItemData?
    let middleOutcome: OutcomeItemData?
    let rightOutcome: OutcomeItemData?

    static func twoWay(left:right:) -> CompactOutcomesLineDisplayState
    static func threeWay(left:middle:right:) -> CompactOutcomesLineDisplayState
}

struct CompactOutcomeSelectionEvent: Equatable {
    let outcomeId: String
    let bettingOfferId: String?
    let outcomeType: OutcomeType
    let isSelected: Bool
    let timestamp: Date
}

protocol CompactOutcomesLineViewModelProtocol: AnyObject {
    var displayStatePublisher: AnyPublisher<CompactOutcomesLineDisplayState, Never> { get }
    var currentDisplayState: CompactOutcomesLineDisplayState { get }

    var leftOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> { get }
    var middleOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> { get }
    var rightOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> { get }

    var currentLeftOutcomeViewModel: OutcomeItemViewModelProtocol? { get }
    var currentMiddleOutcomeViewModel: OutcomeItemViewModelProtocol? { get }
    var currentRightOutcomeViewModel: OutcomeItemViewModelProtocol? { get }

    var outcomeSelectionDidChangePublisher: AnyPublisher<CompactOutcomeSelectionEvent, Never> { get }

    func onOutcomeSelected(outcomeId: String, outcomeType: OutcomeType)
    func onOutcomeDeselected(outcomeId: String, outcomeType: OutcomeType)
    func setOutcomeSelected(outcomeType: OutcomeType)
    func setOutcomeDeselected(outcomeType: OutcomeType)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - preview background

Layout constants:
- Row height: 50pt
- Stack spacing: 4pt
- Minimum outcome width: 60pt
- Distribution: fillEqually

## Mock ViewModels

Available presets:
- `.threeWayMarket` - standard 1X2 market (2.90 / 3.05 / 2.68)
- `.withSelectedOutcome` - 3-way with home selected
- `.highOdds` - 3-way with high odds values
- `.twoWayMarket` - standard 2-way market (tennis)
- `.overUnderMarket` - over/under market
- `.twoWayWithSelection` - 2-way with selection
- `.lockedMarket` - all outcomes locked
- `.withOddsChanges` - outcomes with odds change indicators
- `.custom(displayMode:leftOutcome:middleOutcome:rightOutcome:)` - custom configuration
