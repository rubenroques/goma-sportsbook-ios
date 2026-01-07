# AmountPillView

A pill-shaped button displaying a monetary amount with selection state.

## Overview

AmountPillView displays a single amount value in a rounded pill container. It's used as part of amount selection interfaces where users can pick from predefined deposit or stake amounts. The component updates reactively based on selection state changes.

## Component Relationships

### Used By (Parents)
- `AmountPillsContainerView` - displays multiple pills in a horizontal scrollable container

### Uses (Children)
- None (leaf component)

## Features

- Displays amount with "+" prefix
- Selected/unselected visual states
- Reactive updates via Combine publisher
- Fixed 32pt height with 16pt horizontal padding
- Rounded corners (16pt radius) for pill appearance
- Automatic color inversion on selection

## Usage

```swift
let pillData = AmountPillData(id: "500", amount: "500", isSelected: false)
let viewModel = MockAmountPillViewModel(pillData: pillData)
let pillView = AmountPillView(viewModel: viewModel)
```

## Data Model

```swift
struct AmountPillData: Equatable, Hashable {
    let id: String
    let amount: String
    let isSelected: Bool
}

protocol AmountPillViewModelProtocol {
    var pillDataPublisher: AnyPublisher<AmountPillData, Never> { get }
    func setSelected(_ isSelected: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.navPills` - unselected background color
- `StyleProvider.Color.highlightPrimary` - selected background color
- `StyleProvider.Color.textPrimary` - unselected text color
- `StyleProvider.Color.buttonTextPrimary` - selected text color
- `StyleProvider.fontWith(type: .bold, size: 12)` - amount label font

## Mock ViewModels

Available presets:
- `.defaultMock` - unselected pill with "250" amount
- `.selectedMock` - selected pill with "250" amount
