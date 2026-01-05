# RecentlyPlayedGamesView

A horizontal scrolling section displaying recently played casino games with a header pill.

## Overview

RecentlyPlayedGamesView displays a section for recently played casino games with a highlighted "Recently Played" pill header and a horizontally scrollable collection of game cards. Each card shows a game thumbnail, name, and provider. The component supports placeholder states when no games are loaded and integrates with game selection callbacks.

## Component Relationships

### Used By (Parents)
- Casino home screens
- Game lobby sections

### Uses (Children)
- `RecentlyPlayedGamesCellView` (internal cell view)

## Features

- Header pill with localized title
- Horizontal scrolling UICollectionView
- Fixed-size game cards (210pt x 56pt)
- Game thumbnail, name, and provider display
- Placeholder state with empty cards
- Game selection callback
- Section refresh support
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockRecentlyPlayedGamesViewModel.defaultRecentlyPlayed
let recentlyPlayedView = RecentlyPlayedGamesView(viewModel: viewModel)

// Handle game selection
recentlyPlayedView.onGameSelected = { gameId in
    launchGame(gameId)
}

// Without ViewModel (placeholder state)
let placeholderView = RecentlyPlayedGamesView()

// Refresh games
viewModel.refreshGames()

// Update title dynamically
viewModel.updateTitle("Continue Playing")
```

## Data Model

```swift
struct RecentlyPlayedGameData: Equatable, Hashable, Identifiable {
    let id: String          // Game identifier
    let name: String        // Game name (e.g., "Gonzo's Quest")
    let provider: String?   // Provider name (optional)
    let imageURL: String?   // Image URL or bundle name
    let gameURL: String     // URL for launching the game
}

protocol RecentlyPlayedGamesViewModelProtocol: AnyObject {
    var gamesPublisher: AnyPublisher<[RecentlyPlayedGameData], Never> { get }
    var titlePublisher: AnyPublisher<String, Never> { get }
    var sectionId: String { get }

    func gameSelected(_ gameId: String)
    func refreshGames()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - view background
- `StyleProvider.Color.highlightPrimary` - header pill background
- `StyleProvider.Color.buttonTextPrimary` - header pill text
- `StyleProvider.fontWith(type: .bold, size: 12)` - header pill font

Layout constants:
- Vertical padding: 16pt
- Horizontal padding: 16pt
- Cell spacing: 12pt
- Collection height: 56pt
- Pill height: 32pt
- Pill horizontal padding: 16pt
- Cell width: 210pt
- Stack spacing: 12pt

Collection view:
- Horizontal scrolling
- No scroll indicators
- Fixed cell size: 210pt x 56pt
- Section insets: 16pt horizontal

Placeholder behavior:
- Shows 3 placeholder cells when empty

## Mock ViewModels

Available presets:
- `.defaultRecentlyPlayed` - 5 games (Gonzo's Quest, Starburst, Book of Dead, etc.)
- `.emptyRecentlyPlayed` - No games (placeholder state)
- `.fewGames` - 2 games (Aviator, Crazy Time)
- `.longGameNames` - Games with long names for truncation testing
- `.customRecentlyPlayed(sectionId:title:games:)` - Custom configuration
