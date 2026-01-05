# MarketOutcomesMultiLineView

A vertical container for multiple market outcome lines with group title, loading, error, and empty states.

## Overview

MarketOutcomesMultiLineView aggregates multiple MarketOutcomesLineView instances into a vertical stack, supporting optional group titles and various loading/empty states. It handles smart view reuse during cell recycling and applies multi-line corner radius logic to create a cohesive grid appearance. The component is designed for displaying market groups like "Over/Under Goals" with multiple line options.

## Component Relationships

### Used By (Parents)
- None (standalone market group component)

### Uses (Children)
- `MarketOutcomesLineView` - individual outcome lines

## Features

- Vertical stack of market outcome lines
- Optional group title label
- Loading state with activity indicator
- Error state with message display
- Empty state with customizable message
- Placeholder line for empty markets (single disabled "-" button)
- Smart view reuse (reconfigure vs recreate)
- Multi-line corner radius logic (grid appearance)
- 2-column and 3-column line support
- Immediate synchronous configuration for UITableView sizing
- Reactive updates via Combine publishers
- Configure method for cell reuse
- Cleanup method for proper cell recycling

## Usage

```swift
let viewModel = MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup
let multiLineView = MarketOutcomesMultiLineView(viewModel: viewModel)

multiLineView.onOutcomeSelected = { outcomeId, outcomeType in
    print("Selected: \(outcomeId)")
}

multiLineView.onOutcomeDeselected = { outcomeId, outcomeType in
    print("Deselected: \(outcomeId)")
}

multiLineView.onOutcomeLongPress = { lineId, outcomeType in
    print("Long press on line: \(lineId)")
}

// Manual state control
multiLineView.showLoadingState()
multiLineView.showErrorState("Failed to load markets")

// For cell reuse
multiLineView.cleanupForReuse()
multiLineView.configure(with: newViewModel)
```

## Data Model

```swift
struct MarketLineData: Equatable, Hashable {
    let id: String
    let leftOutcome: MarketOutcomeData?
    let middleOutcome: MarketOutcomeData?
    let rightOutcome: MarketOutcomeData?
    let displayMode: MarketDisplayMode
    let lineType: MarketLineType
}

enum MarketLineType: Equatable, Hashable {
    case twoColumn   // Left + Right (Over/Under)
    case threeColumn // Left + Middle + Right (Home/Draw/Away)
}

struct MarketGroupData: Equatable, Hashable {
    let id: String
    let groupTitle: String?
    let marketLines: [MarketLineData]
}

struct MarketOutcomesMultiLineDisplayState: Equatable {
    let groupTitle: String?
    let lineCount: Int
    let isEmpty: Bool
    let emptyStateMessage: String?
}

protocol MarketOutcomesMultiLineViewModelProtocol {
    // Synchronous access for UITableView sizing
    var lineViewModels: [MarketOutcomesLineViewModelProtocol] { get }
    var currentDisplayState: MarketOutcomesMultiLineDisplayState { get }

    // Asynchronous publishers for updates
    var lineViewModelsPublisher: AnyPublisher<[MarketOutcomesLineViewModelProtocol], Never> { get }
    var displayStatePublisher: AnyPublisher<MarketOutcomesMultiLineDisplayState, Never> { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textPrimary` - group title color
- `StyleProvider.Color.backgroundPrimary` - loading/error/empty container background
- `StyleProvider.Color.highlightPrimary` - loading indicator color
- `StyleProvider.Color.textDisabledOdds` - error/empty text color
- `StyleProvider.fontWith(type: .medium, size: 16)` - group title font
- `StyleProvider.fontWith(type: .regular, size: 14)` - error/empty label font

Layout constants:
- Line spacing: 1pt
- Group title bottom spacing: 12pt
- Container padding: 0pt
- Empty state height: 50pt
- Corner radius: 4.5pt (state containers)
- Disabled alpha: 0.5

Multi-line corner radius:
- **First line**: Top-left and top-right corners rounded
- **Middle lines**: No corners rounded
- **Last line**: Bottom-left and bottom-right corners rounded
- **Single line**: Default single-line corner logic

## Mock ViewModels

Available presets:
- `.overUnderMarketGroup` - Over/Under 0.5, 1.0, 1.5 (3 lines, 2-column)
- `.homeDrawAwayMarketGroup` - Full Time and Half Time 1X2 (2 lines, 3-column)
- `.overUnderWithSuspendedLine` - 3 lines with middle suspended
- `.mixedLayoutMarketGroup` - 3-column + 2-column lines with "Popular Markets" title
- `.marketGroupWithOddsChanges` - Lines with up/down indicators and selection
- `.emptyMarketGroupWithTitle` - Empty with "Total Goals" title
- `.emptyMarketGroup` - Empty without title
- `.loadingMarketGroup` - Loading state placeholder
