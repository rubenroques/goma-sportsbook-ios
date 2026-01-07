# CasinoCategoryBarView

A section header bar for casino game categories with title and "See All" action button.

## Overview

CasinoCategoryBarView displays a category title on the left and an action button with count on the right. It's designed for use above game collections to indicate the category and provide quick navigation to the full category view. The component supports placeholder state when no ViewModel is provided.

## Component Relationships

### Used By (Parents)
- `CasinoCategorySectionView` - header for game category sections
- `CasinoGameImageGridSectionView` - header for grid-based sections

### Uses (Children)
- None (leaf component)

## Features

- Category title with bold styling
- Action button with count and chevron icon
- Horizontal layout with equal spacing distribution
- 16pt horizontal padding, 12pt vertical padding
- Secondary background color
- Placeholder state for nil ViewModel
- Callback for button tap with category ID
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockCasinoCategoryBarViewModel.newGames
let categoryBar = CasinoCategoryBarView(viewModel: viewModel)

categoryBar.onButtonTapped = { categoryId in
    print("Navigate to category: \(categoryId)")
}
```

## Data Model

```swift
struct CasinoCategoryBarData: Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let buttonText: String
}

protocol CasinoCategoryBarViewModelProtocol: AnyObject {
    var titlePublisher: AnyPublisher<String, Never> { get }
    var buttonTextPublisher: AnyPublisher<String, Never> { get }
    var categoryId: String { get }

    func buttonTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.highlightPrimary` - button background
- `StyleProvider.Color.buttonTextPrimary` - button text and icon color
- `StyleProvider.fontWith(type: .bold, size: 16)` - title font
- `StyleProvider.fontWith(type: .semibold, size: 14)` - button text font

## Mock ViewModels

Available presets:
- `.newGames` - "New Games" with 41 count
- `.popularGames` - "Popular Games" with 127 count
- `.slotGames` - "Slot Games" with 89 count
- `.liveGames` - "Live Games" with 23 count
- `.jackpotGames` - "Jackpot Games" with 12 count
- `.customCategory(id:title:buttonText:)` - custom configuration
