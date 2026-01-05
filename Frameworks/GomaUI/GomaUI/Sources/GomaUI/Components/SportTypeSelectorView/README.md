# SportTypeSelectorView

A 2-column grid of sport type cards for selecting sports categories.

## Overview

SportTypeSelectorView displays a vertically scrolling 2-column grid of sport type cards using UICollectionView. Each card shows a sport icon and name, allowing users to select their preferred sport category. The component uses SportTypeSelectorItemView cells internally and supports dynamic updates to the sports list.

## Component Relationships

### Used By (Parents)
- Sport navigation screens
- Filter panels
- Settings screens

### Uses (Children)
- `SportTypeSelectorItemView` (via collection view cells)

## Features

- 2-column grid layout using UICollectionViewFlowLayout
- Horizontal item spacing: 8pt
- Vertical line spacing: 8pt
- Section insets: 8pt all sides
- Sport selection callback
- Dynamic sports list updates
- Fixed cell height: 58pt
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockSportTypeSelectorViewModel.defaultMock
let selectorView = SportTypeSelectorView(viewModel: viewModel)

// Handle sport selection
selectorView.onSportSelected = { sportData in
    navigateToSport(sportData.id)
}

// Update sports list dynamically
viewModel.updateSports(newSports)

// Add or remove sports
viewModel.addSport(SportTypeData(id: "cricket", name: "Cricket", iconName: "cricket"))
viewModel.removeSport(withId: "hockey")
```

## Data Model

```swift
struct SportTypeData: Equatable, Hashable {
    let id: String
    let name: String
    let iconName: String
}

struct SportTypeSelectorDisplayState: Equatable {
    let sports: [SportTypeData]
}

protocol SportTypeSelectorViewModelProtocol {
    var displayStatePublisher: AnyPublisher<SportTypeSelectorDisplayState, Never> { get }

    func selectSport(_ sport: SportTypeData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - collection view background

Layout constants:
- Column count: 2
- Item spacing: 8pt
- Line spacing: 8pt
- Section insets: 8pt (top, left, bottom, right)
- Cell height: 58pt (from SportTypeSelectorItemView.defaultHeight)
- Cell width: calculated based on available width

Collection view:
- Vertical scrolling
- No paging
- Standard scroll indicators

## Mock ViewModels

Available presets:
- `.defaultMock` - 4 sports (Football, Basketball, Tennis, Baseball)
- `.manySportsMock` - 12 sports for scrolling tests
- `.fewSportsMock` - 2 sports (Football, Basketball)
- `.emptySportsMock` - No sports (empty state)

Methods:
- `updateSports(_ sports:)` - Replace entire sports list
- `addSport(_ sport:)` - Add single sport (deduplicates by ID)
- `removeSport(withId:)` - Remove sport by ID
- `selectSport(_ sport:)` - Handle sport selection
