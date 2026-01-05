# CasinoCategorySectionView

A complete casino category section with header bar and horizontal scrolling game cards.

## Overview

CasinoCategorySectionView displays a category header (via CasinoCategoryBarView) followed by a horizontal scrolling collection of casino game cards (via CasinoGameCardView). It manages the composition of these child components and coordinates game selection and category navigation events. Common uses include displaying "New Games", "Popular Games", or other categorized game sections on casino home screens.

## Component Relationships

### Used By (Parents)
- None (standalone section component, typically used in table/collection views)

### Uses (Children)
- `CasinoCategoryBarView` - section header with title and "See All" button
- `CasinoGameCardView` - individual game cards in horizontal scroll

## Features

- Category header bar with title and action button
- Horizontal scrolling game card collection
- Fixed 164pt x 272pt game card size
- 12pt cell spacing with 16pt horizontal edge padding
- Tertiary background color
- Placeholder state with 3 empty cards when no ViewModel
- Game selection and category button callbacks
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockCasinoCategorySectionViewModel.newGamesSection
let sectionView = CasinoCategorySectionView(viewModel: viewModel)

sectionView.onGameSelected = { gameId in
    print("Game selected: \(gameId)")
}

sectionView.onCategoryButtonTapped = { categoryId in
    print("Navigate to category: \(categoryId)")
}
```

## Data Model

```swift
struct CasinoCategorySectionData: Equatable, Hashable, Identifiable {
    let id: String
    let categoryTitle: String
    let categoryButtonText: String
    let games: [CasinoGameCardData]
}

protocol CasinoCategorySectionViewModelProtocol: AnyObject {
    var categoryBarViewModel: CasinoCategoryBarViewModelProtocol { get }
    var gameCardViewModels: [CasinoGameCardViewModelProtocol] { get }
    var gameCardViewModelsPublisher: AnyPublisher<[CasinoGameCardViewModelProtocol], Never> { get }
    var sectionId: String { get }
    var categoryTitle: String { get }

    func gameSelected(_ gameId: String)
    func categoryButtonTapped()
    func refreshGames()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - section background
- Inherits styling from child `CasinoCategoryBarView` and `CasinoGameCardView` components

Layout constants:
- Category bar height: 48pt
- Collection height: 266pt
- Horizontal padding: 16pt
- Cell spacing: 12pt

## Mock ViewModels

Available presets:
- `.newGamesSection` - "New Games" with 4 sample games
- `.popularGamesSection` - "Popular Games" with 3 sample games
- `.slotGamesSection` - "Slot Games" with 2 sample games
- `.emptySection` - empty category (shows placeholders)
- `.customSection(id:categoryTitle:categoryButtonText:games:)` - custom configuration
