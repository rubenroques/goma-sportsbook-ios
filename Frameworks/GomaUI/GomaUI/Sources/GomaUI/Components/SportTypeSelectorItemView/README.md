# SportTypeSelectorItemView

A compact sport type selector item with icon and title.

## Overview

SportTypeSelectorItemView displays a compact card-style item for selecting a sport type. It shows a centered sport icon above a sport name label. The component is designed for use in horizontal sport type selectors and grid layouts. It supports both custom named images and SF Symbols for icons.

## Component Relationships

### Used By (Parents)
- `SportTypeSelectorView`
- Sport navigation bars
- Sport selection grids

### Uses (Children)
- None (leaf component)

## Features

- Centered sport icon (custom or SF Symbol)
- Sport name label below icon
- Tap gesture with callback
- Fixed 58pt height
- Rounded corners (8pt)
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockSportTypeSelectorItemViewModel.footballMock
let selectorItem = SportTypeSelectorItemView(viewModel: viewModel)

// Handle selection
selectorItem.onTap = { sportData in
    navigateToSport(sportData.id)
}

// Update sport data dynamically
viewModel.updateSportData(newSportData)
```

## Data Model

```swift
struct SportTypeData: Equatable, Hashable {
    let id: String
    let name: String
    let iconName: String
}

struct SportTypeSelectorItemDisplayState: Equatable {
    let sportData: SportTypeData
}

protocol SportTypeSelectorItemViewModelProtocol {
    var displayStatePublisher: AnyPublisher<SportTypeSelectorItemDisplayState, Never> { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - item background
- `StyleProvider.Color.textPrimary` - icon tint and title color
- `StyleProvider.fontWith(type: .medium, size: 12)` - title font

Layout constants:
- Fixed height: 58pt
- Corner radius: 8pt
- Container padding: 8pt top, 6pt bottom, 12pt horizontal
- Icon size: 23pt x 23pt
- Icon to title spacing: -2pt
- Title alignment: center

Icon handling:
- Tries custom named image first
- Falls back to SF Symbol
- Uses template rendering for tinting

## Mock ViewModels

Available presets:
- `.footballMock` - Football sport
- `.basketballMock` - Basketball sport
- `.tennisMock` - Tennis sport
- `.baseballMock` - Baseball sport
- `.hockeyMock` - Hockey sport
- `.golfMock` - Golf sport
- `.volleyballMock` - Volleyball sport
- `.soccerMock` - Soccer sport

Methods:
- `updateSportData(_ sportData:)` - Update displayed sport
