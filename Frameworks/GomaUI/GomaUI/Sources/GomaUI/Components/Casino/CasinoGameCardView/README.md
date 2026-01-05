# CasinoGameCardView

A detailed casino game card with image, title, provider, minimum stake, and thunderbolt rating.

## Overview

CasinoGameCardView displays a rich game card featuring the game image, title, provider name, minimum stake amount, and a 5-thunderbolt rating indicator. It supports image loading with loading and failure states, and provides tap interaction for game selection. The card uses a fixed size (164x272pt) optimized for horizontal scrolling collections.

## Component Relationships

### Used By (Parents)
- `CasinoCategorySectionView` - displays cards in horizontal collection

### Uses (Children)
- None (leaf component)

## Features

- Game thumbnail image with async loading
- Loading indicator and failure state ("?") for images
- Game title (up to 2 lines)
- Provider name label
- Minimum stake display with localized prefix
- 5-thunderbolt rating system (filled/unfilled based on rating)
- Rounded corners (8pt) with shadow
- Fixed 164x272pt card size
- Tap gesture for game selection
- Placeholder state when no ViewModel
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockCasinoGameCardViewModel.plinkGoal
let gameCardView = CasinoGameCardView(viewModel: viewModel)

gameCardView.onGameSelected = { gameId in
    print("Game selected: \(gameId)")
}
```

## Data Model

```swift
struct CasinoGameCardData: Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    let gameURL: String
    let iconURL: String?
    let rating: Double       // 0.0 to 5.0
    let provider: String?
    let minStake: String
    let subProvider: String?
}

struct CasinoGameCardDisplayState: Equatable {
    let isLoading: Bool
    let imageLoadingFailed: Bool
}

protocol CasinoGameCardViewModelProtocol: AnyObject {
    var displayStatePublisher: AnyPublisher<CasinoGameCardDisplayState, Never> { get }
    var gameNamePublisher: AnyPublisher<String, Never> { get }
    var providerNamePublisher: AnyPublisher<String?, Never> { get }
    var minStakePublisher: AnyPublisher<String, Never> { get }
    var iconURLPublisher: AnyPublisher<String?, Never> { get }
    var ratingPublisher: AnyPublisher<Double, Never> { get }

    var gameId: String { get }
    var gameURL: String { get }
    var onGameSelected: ((String) -> Void) { get set }

    func imageLoadingFailed()
    func imageLoadingSucceeded()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - card container background
- `StyleProvider.Color.backgroundCards` - image placeholder background
- `StyleProvider.Color.backgroundPrimary` - rating capsule background
- `StyleProvider.Color.shadow` - card shadow color
- `StyleProvider.Color.textPrimary` - game title color
- `StyleProvider.Color.textSecondary` - provider and min stake color
- `StyleProvider.Color.textDisablePrimary` - failure "?" label color
- `StyleProvider.fontWith(type: .bold, size: 14)` - game title font
- `StyleProvider.fontWith(type: .semibold, size: 12)` - provider and min stake font

Layout constants:
- Card size: 164x272pt
- Image height: 164pt
- Corner radius: 8pt
- Content padding: 11pt
- Thunderbolt size: 15pt

## Mock ViewModels

Available presets:
- `.plinkGoal` - "Plink Goal" game with 4.5 rating
- `.aviator` - "Aviator" game with 4.8 rating
- `.beastBelow` - long title/provider example with 4.2 rating
- `.loadingGame` - loading state example
- `.imageFailedGame` - image failure state example
- `.customGame(id:name:gameURL:iconURL:rating:provider:minStake:)` - custom configuration
