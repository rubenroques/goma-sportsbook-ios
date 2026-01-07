# CasinoGameImageView

A simple image-only card for displaying casino games in compact grid layouts.

## Overview

CasinoGameImageView displays a square game image with rounded corners, supporting async image loading from URLs or bundle assets. It shows loading and failure states, and responds to tap gestures for game selection. This minimal component is designed for use in the 2-row compact grid layout of casino sections.

## Component Relationships

### Used By (Parents)
- `CasinoGameImagePairView` - stacks two images vertically
- `SquareSeeMoreView` - uses as game preview thumbnail

### Uses (Children)
- None (leaf component)

## Features

- Fixed 100x100pt square card size
- 16pt corner radius
- Async image loading from URL or bundle
- Loading indicator during fetch
- Failure state with "?" placeholder
- Tap gesture for game selection
- Cell reuse support via prepareForReuse()
- Cancellable image loading task
- Placeholder state when no ViewModel

## Usage

```swift
let viewModel = MockCasinoGameImageViewModel.aviator
let gameImageView = CasinoGameImageView(viewModel: viewModel)

// Handle game selection via ViewModel callback
viewModel.onGameSelected = { gameId in
    print("Game selected: \(gameId)")
}
```

## Data Model

```swift
struct CasinoGameImageData: Equatable, Hashable, Identifiable {
    let id: String
    let iconURL: String?    // URL or bundle image name
    let gameURL: String
}

protocol CasinoGameImageViewModelProtocol: AnyObject {
    var gameId: String { get }
    var gameURL: String { get }
    var iconURL: String? { get }

    func gameSelected()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundCards` - container and image background
- `StyleProvider.Color.textSecondary` - loading indicator color
- `StyleProvider.Color.textDisablePrimary` - failure "?" label color
- `StyleProvider.fontWith(type: .bold, size: 32)` - failure label font

Layout constants:
- Card size: 100pt x 100pt
- Corner radius: 16pt

## Mock ViewModels

Available presets:
- `.plinkGoal` - game with placeholder image
- `.aviator` - game with placeholder image
- `.sambaSoccer` - game with placeholder image
- `.failed` - game with invalid URL (triggers failure state)
- `.noImage` - game with nil iconURL
