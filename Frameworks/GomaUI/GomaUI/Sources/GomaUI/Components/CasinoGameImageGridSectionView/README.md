# CasinoGameImageGridSectionView

A casino section displaying games in a 2-row horizontal scrolling image grid.

## Overview

CasinoGameImageGridSectionView displays a category header (via CasinoCategoryBarView) followed by a horizontal scrolling collection of game images arranged in 2-row vertical pairs. Each column contains a CasinoGameImagePairView with up to 2 game images stacked vertically. This compact layout is ideal for "Lite Games" or "Crash Games" sections where images alone convey the game.

## Component Relationships

### Used By (Parents)
- None (standalone section component, typically used in table/collection views)

### Uses (Children)
- `CasinoCategoryBarView` - section header with title and "See All" button
- `CasinoGameImagePairView` - vertical pairs of game images (via collection view cells)

## Features

- Category header bar with title and action button
- 2-row horizontal scrolling grid layout
- 100x100pt game image cards with 16pt corner radius
- Vertical spacing: 8pt between rows
- Horizontal spacing: 12pt between columns
- 16pt horizontal edge padding
- Handles odd number of games (last column shows only top image)
- Tertiary background color
- Placeholder state with 3 empty pairs when no ViewModel
- Game selection and category button callbacks
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockCasinoGameImageGridSectionViewModel.liteGamesSection
let sectionView = CasinoGameImageGridSectionView(viewModel: viewModel)

viewModel.onGameSelected = { gameId in
    print("Game selected: \(gameId)")
}

viewModel.onCategoryButtonTapped = {
    print("Category button tapped")
}

sectionView.onGameSelected = { gameId in
    print("Game selected via view callback: \(gameId)")
}
```

## Data Model

```swift
struct CasinoGameImageGridSectionData: Equatable, Hashable, Identifiable {
    let id: String
    let categoryTitle: String
    let categoryButtonText: String
    let games: [CasinoGameImageData]
}

protocol CasinoGameImageGridSectionViewModelProtocol: AnyObject {
    var categoryBarViewModel: CasinoCategoryBarViewModelProtocol { get }
    var gamePairViewModels: [CasinoGameImagePairViewModelProtocol] { get }
    var gamePairViewModelsPublisher: AnyPublisher<[CasinoGameImagePairViewModelProtocol], Never> { get }
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
- `StyleProvider.Color.backgroundPrimary` - used for view backgrounds
- Inherits styling from child `CasinoCategoryBarView` and `CasinoGameImageView` components

Layout constants:
- Category bar height: 48pt
- Card size: 100pt (from CasinoGameImageView)
- Collection height: 208pt (2 cards + 8pt spacing)
- Horizontal padding: 16pt
- Horizontal spacing: 12pt
- Vertical spacing: 8pt

## Mock ViewModels

Available presets:
- `.liteGamesSection` - "Lite Games" with 8 games (4 full columns)
- `.oddGamesSection` - "Crash Games" with 7 games (last column has only top)
- `.emptySection` - empty category (shows placeholders)
- `.fewGamesSection` - section with only 2 games (1 column)
