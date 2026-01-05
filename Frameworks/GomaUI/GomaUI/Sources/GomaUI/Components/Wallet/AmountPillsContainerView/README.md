# AmountPillsContainerView

A horizontally scrollable container displaying multiple amount selection pills.

## Overview

AmountPillsView (located in AmountPillsContainerView folder) manages a collection of AmountPillView components in a horizontal scroll view. It handles pill selection, maintains selection state, and provides callbacks for amount selection events. Commonly used for quick deposit amount selection.

## Component Relationships

### Used By (Parents)
- None (standalone component)

### Uses (Children)
- `AmountPillView` - individual pill buttons for each amount option

## Features

- Horizontal scrollable pill container
- Single selection management (one pill selected at a time)
- Reactive state updates via Combine
- Selection callback for parent integration
- Hidden scroll indicators for clean appearance
- 12pt spacing between pills
- Fixed 40pt container height

## Usage

```swift
let viewModel = MockAmountPillsViewModel.defaultMock
let pillsView = AmountPillsView(viewModel: viewModel)

pillsView.onPillSelected = { amountId in
    print("Selected amount: \(amountId)")
}
```

## Data Model

```swift
struct AmountPillsData: Equatable {
    let id: String
    let pills: [AmountPillData]
    let selectedPillId: String?
}

protocol AmountPillsViewModelProtocol {
    var pillsDataPublisher: AnyPublisher<AmountPillsData, Never> { get }
    var pillsDataSubject: CurrentValueSubject<AmountPillsData, Never> { get }

    func selectPill(withId id: String)
    func clearSelection()
}
```

## Styling

StyleProvider properties used:
- Inherits styling from child `AmountPillView` components
- Clear background for scroll view container

## Mock ViewModels

Available presets:
- `.defaultMock` - 8 pills (250, 500, 1000, 2000, 3000, 5000, 10000, 20000) with no selection
- `.selectedMock` - 4 pills with 500 pre-selected
