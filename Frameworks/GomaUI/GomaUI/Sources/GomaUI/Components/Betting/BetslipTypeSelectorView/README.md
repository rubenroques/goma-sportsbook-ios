# BetslipTypeSelectorView

A horizontal tab selector for switching between betslip types (Sports, Virtuals).

## Overview

BetslipTypeSelectorView displays a row of selectable tabs allowing users to filter their betslip by bet category. It manages a collection of BetslipTypeTabItemView components and coordinates selection state across all tabs. Common use cases include separating sports bets from virtual sports bets.

## Component Relationships

### Used By (Parents)
- None (standalone component, typically in betslip screens)

### Uses (Children)
- `BetslipTypeTabItemView` - individual tab item buttons

## Features

- Horizontal tab layout with equal distribution
- Single selection management
- Selection event publishing for parent integration
- Animated selection state transitions
- 16pt horizontal padding with 8pt corner radius
- Fixed 50pt height
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockBetslipTypeSelectorViewModel.sportsSelectedMock()
let selectorView = BetslipTypeSelectorView(viewModel: viewModel)

// Listen for selection changes
viewModel.selectionEventPublisher
    .sink { event in
        print("Selected: \(event.selectedId)")
    }
    .store(in: &cancellables)
```

## Data Model

```swift
struct BetslipTypeTabData: Equatable, Hashable {
    let id: String
    let title: String
    let icon: String
    var isSelected: Bool
}

struct BetslipTypeSelectionEvent: Equatable {
    let selectedId: String
    let previouslySelectedId: String?
}

protocol BetslipTypeSelectorViewModelProtocol {
    var tabsPublisher: AnyPublisher<[BetslipTypeTabData], Never> { get }
    var selectedTabIdPublisher: AnyPublisher<String?, Never> { get }
    var selectionEventPublisher: AnyPublisher<BetslipTypeSelectionEvent, Never> { get }
    var currentSelectedTabId: String? { get }
    var currentTabs: [BetslipTypeTabData] { get }

    func selectTab(id: String)
    func updateTabs(_ tabs: [BetslipTypeTabData])
    func clearSelection()
    func selectFirstAvailableTab()
}
```

## Styling

StyleProvider properties used:
- Clear background on container
- Inherits styling from child `BetslipTypeTabItemView` components

## Mock ViewModels

Available presets:
- `.sportsSelectedMock()` - Sports tab selected
- `.virtualsSelectedMock()` - Virtuals tab selected
