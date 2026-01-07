# CasinoGameImagePairView

A vertical container displaying two casino game images stacked in a column.

## Overview

CasinoGameImagePairView displays two CasinoGameImageView components arranged vertically with consistent spacing. The top game is always required, while the bottom game is optional to handle odd-numbered game lists. When the bottom game is absent, the view maintains its height with an invisible placeholder to ensure consistent 2-row grid layout.

## Component Relationships

### Used By (Parents)
- `CasinoGameImageGridSectionView` - displays pairs in horizontal collection

### Uses (Children)
- `CasinoGameImageView` - individual game image card (2 instances: top and bottom)

## Features

- Vertical stack of 2 game images
- Optional bottom game for odd-numbered lists
- 8pt vertical spacing between images
- Maintains consistent height when bottom is missing (alpha = 0)
- Tap callbacks for both top and bottom games
- Cell reuse support via prepareForReuse()
- Placeholder state when no ViewModel

## Usage

```swift
let viewModel = MockCasinoGameImagePairViewModel.fullPair
let pairView = CasinoGameImagePairView(viewModel: viewModel)

pairView.onGameSelected = { gameId in
    print("Game selected: \(gameId)")
}
```

## Data Model

```swift
protocol CasinoGameImagePairViewModelProtocol: AnyObject {
    var topGameViewModel: CasinoGameImageViewModelProtocol { get }
    var bottomGameViewModel: CasinoGameImageViewModelProtocol? { get }
    var pairId: String { get }
}
```

## Styling

StyleProvider properties used:
- Inherits styling from child `CasinoGameImageView` components
- `StyleProvider.Color.backgroundPrimary` - used for preview backgrounds

Layout constants:
- Vertical spacing: 8pt
- Total height: 208pt (2 x 100pt cards + 8pt spacing)

## Mock ViewModels

Available presets:
- `.fullPair` - both top and bottom games present
- `.topOnly` - only top game (odd number scenario)
- `.noImages` - both games with no images (failure state)
- `.pairs(from: [CasinoGameImageData])` - creates array of pairs from game list
