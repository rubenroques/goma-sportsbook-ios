# MarketOutcomesLineView

A horizontal line of market outcome items (2 or 3 column) with selection, odds change, and suspended/see-all states.

## Overview

MarketOutcomesLineView displays a single row of betting outcomes for a market, supporting two-way (left/right) and three-way (left/middle/right) layouts. It handles outcome selection, live odds change animations, suspended market states, and "see all" navigation. The component manages child OutcomeItemView instances and coordinates their selection states through the parent ViewModel.

## Component Relationships

### Used By (Parents)
- `MarketOutcomesMultiLineView` - multi-line market display
- `MatchBannerView` - match banner betting outcomes
- `TallOddsMatchCardView` - match card betting section

### Uses (Children)
- `OutcomeItemView` - individual outcome button

## Features

- Two-column layout (left + right outcomes)
- Three-column layout (left + middle + right outcomes)
- Single placeholder mode for empty markets
- Suspended state with centered text message
- "See all" state with tap navigation
- Outcome selection/deselection with callbacks
- Live odds change direction indicators (up/down)
- Long press gesture for outcome details
- Position-based corner radius (first/middle/last)
- Position overrides for multi-line grid layouts
- Configure method for cell reuse
- Cleanup method for proper cell recycling
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockMarketOutcomesLineViewModel.threeWayMarket
let outcomesLine = MarketOutcomesLineView(viewModel: viewModel)

outcomesLine.onOutcomeSelected = { outcomeId, outcomeType in
    print("Selected: \(outcomeId)")
}

outcomesLine.onOutcomeDeselected = { outcomeId, outcomeType in
    print("Deselected: \(outcomeId)")
}

outcomesLine.onOutcomeLongPress = { outcomeType in
    print("Long press on: \(outcomeType)")
}

outcomesLine.onSeeAllTapped = {
    print("See all tapped")
}

// For cell reuse
outcomesLine.cleanupForReuse()
outcomesLine.configure(with: newViewModel)

// For multi-line scenarios (grid corner radius)
outcomesLine.setPositionOverrides([
    .left: .multiTopLeft,
    .middle: .middle,
    .right: .multiTopRight
])
```

## Data Model

```swift
struct MarketOutcomeData: Equatable, Hashable {
    let id: String
    let bettingOfferId: String?
    let title: String
    let completeName: String?
    let value: String
    let oddsChangeDirection: OddsChangeDirection
    let isSelected: Bool
    let isDisabled: Bool
    let previousValue: String?
    let changeTimestamp: Date?
}

enum OddsChangeDirection: Equatable {
    case up
    case down
    case none
}

enum MarketDisplayMode: Equatable, Hashable {
    case triple       // Three-way market (left, middle, right)
    case double       // Two-way market (left, right only)
    case single       // Single non-interactive placeholder
    case suspended(text: String)
    case seeAll(text: String)
}

enum OutcomeType: Equatable {
    case left
    case middle
    case right
}

struct MarketOutcomesLineDisplayState: Equatable {
    let displayMode: MarketDisplayMode
    let leftOutcome: MarketOutcomeData?
    let middleOutcome: MarketOutcomeData?
    let rightOutcome: MarketOutcomeData?
}

struct MarketOutcomeSelectionEvent: Equatable {
    let outcomeId: String
    let bettingOfferId: String?
    let outcomeType: OutcomeType
    let isSelected: Bool
    let timestamp: Date
}

protocol MarketOutcomesLineViewModelProtocol {
    var marketStateSubject: CurrentValueSubject<MarketOutcomesLineDisplayState, Never> { get }
    var marketStatePublisher: AnyPublisher<MarketOutcomesLineDisplayState, Never> { get }
    var oddsChangeEventPublisher: AnyPublisher<OddsChangeEvent, Never> { get }
    var outcomeSelectionDidChangePublisher: AnyPublisher<MarketOutcomeSelectionEvent, Never> { get }

    func setOutcomeSelected(type: OutcomeType)
    func setOutcomeDeselected(type: OutcomeType)
    func updateOddsValue(type: OutcomeType, newValue: String)
    func updateOddsValue(type: OutcomeType, value: String, changeDirection: OddsChangeDirection)
    func setDisplayMode(_ mode: MarketDisplayMode)
    func clearOddsChangeIndicator(type: OutcomeType)
    func createOutcomeViewModel(for outcomeType: OutcomeType) -> OutcomeItemViewModelProtocol?
    func updateSelectionStates(selectedOfferIds: Set<String>)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightSecondary` - suspended background (10% alpha), border
- `StyleProvider.Color.textPrimary` - see all text
- `StyleProvider.fontWith(type: .regular, size: 16)` - suspended/see all label font

Layout constants:
- View height: 52pt
- Stack spacing: 1pt
- Corner radius: 0pt (handled by child OutcomeItemViews)
- Distribution: fill equally

Display mode visibility:
- **Triple**: All three outcomes visible
- **Double**: Left and right visible, middle hidden
- **Single**: Only left outcome visible
- **Suspended**: Outcomes hidden, suspended message visible
- **See All**: Outcomes hidden, see all button visible

## Mock ViewModels

Available presets:
- `.threeWayMarket` - Home/Draw/Away (1.85/3.55/4.20)
- `.twoWayMarket` - Under/Over 2.5 (1.95/1.85)
- `.selectedOutcome` - Home outcome selected
- `.oddsChanges` - Home up, Away down indicators
- `.disabledOutcome` - Home outcome disabled
- `.suspendedMarket` - "Market Suspended" text
- `.seeAllMarket` - "See All Markets" text
- `.doubleChanceMarket` - 1X/12/X2 market
- `.asianHandicapMarket` - Home -1.5 / Away +1.5
- `.customMarket(displayMode:leftOutcome:middleOutcome:rightOutcome:)` - fully customizable
