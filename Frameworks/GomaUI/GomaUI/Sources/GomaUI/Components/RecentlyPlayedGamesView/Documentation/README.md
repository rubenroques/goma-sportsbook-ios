# RecentlyPlayedGamesView

A horizontal collection view component for displaying recently played casino games with a selectable pill header.

## Overview

The `RecentlyPlayedGamesView` provides a clean, scrollable interface for displaying recently played casino games. It features a "Recently Played" pill header using the existing `PillItemView` component and a horizontal collection view displaying game tiles with images, titles, and provider information.

## Features

- **PillView Header**: Uses existing `PillItemView` component in selected state without icon
- **Horizontal Collection**: Smooth scrolling collection view with custom cell layout
- **Separate Cell Component**: `RecentlyPlayedGamesCellView` for reusable game tile UI
- **Image Loading**: Smart image loading supporting both bundle images and network URLs
- **Optional ViewModel**: Can be initialized with or without a viewModel
- **Runtime Configuration**: Supports changing viewModel after initialization
- **Reactive Updates**: Uses Combine publishers for real-time UI updates
- **Game Selection**: Interactive tiles with selection callbacks
- **Placeholder States**: Shows placeholder tiles when no games are available

## Architecture

### MVVM Pattern
The component follows the MVVM (Model-View-ViewModel) architectural pattern:

- **Model**: `RecentlyPlayedGameData` - Contains game information
- **View**: `RecentlyPlayedGamesView` - Main container with collection view
- **Cell View**: `RecentlyPlayedGamesCellView` - Individual game tile component
- **ViewModel**: `RecentlyPlayedGamesViewModelProtocol` - Business logic and data binding

### Components Structure
```
RecentlyPlayedGamesView/
├── RecentlyPlayedGamesViewModelProtocol.swift    # Protocol and data models
├── RecentlyPlayedGamesView.swift                 # Main UI component with collection view
├── RecentlyPlayedGamesCellView.swift             # Separate cell component
├── MockRecentlyPlayedGamesViewModel.swift        # Mock implementation
└── Documentation/
    └── README.md                                 # This file
```

## Usage

### Basic Usage
```swift
import GomaUI

// With viewModel
let viewModel = MockRecentlyPlayedGamesViewModel.defaultRecentlyPlayed
let recentlyPlayedView = RecentlyPlayedGamesView(viewModel: viewModel)

// Without viewModel (shows placeholder)
let recentlyPlayedView = RecentlyPlayedGamesView()
```

### Runtime Configuration
```swift
let recentlyPlayedView = RecentlyPlayedGamesView()

// Configure with viewModel
recentlyPlayedView.configure(with: viewModel)

// Clear viewModel (shows placeholder)
recentlyPlayedView.configure(with: nil)
```

### Game Selection Handling
```swift
recentlyPlayedView.onGameSelected = { gameId in
    print("Game selected: \(gameId)")
    // Handle navigation to game or launch game
}
```

## Data Models

### RecentlyPlayedGameData
```swift
public struct RecentlyPlayedGameData: Equatable, Hashable, Identifiable {
    public let id: String           // game identifier
    public let name: String         // game name (e.g., "Gonzo's Quest")
    public let provider: String     // provider name (e.g., "Netent")
    public let imageURL: String?    // game image URL or bundle name
    public let gameURL: String      // URL for launching the game
}
```

## ViewModel Protocol

### RecentlyPlayedGamesViewModelProtocol
```swift
public protocol RecentlyPlayedGamesViewModelProtocol: AnyObject {
    // Publishers for reactive updates
    var gamesPublisher: AnyPublisher<[RecentlyPlayedGameData], Never> { get }
    var titlePublisher: AnyPublisher<String, Never> { get }
    
    // Read-only properties
    var sectionId: String { get }
    
    // Actions
    func gameSelected(_ gameId: String)
    func refreshGames()
}
```

## Cell Component

### RecentlyPlayedGamesCellView
The separate cell component (`RecentlyPlayedGamesCellView`) provides:

- **Fixed dimensions**: 210×56pt following Figma specifications
- **Game image**: 56×56pt with rounded corners and loading states
- **Content area**: Game title (bold 12pt) and provider (regular 12pt)
- **Interactive**: Tap gesture with selection callback
- **Image loading**: Supports bundle images and network URLs with loading/error states

```swift
let cellView = RecentlyPlayedGamesCellView()
cellView.configure(with: gameData)
cellView.onGameSelected = { gameId in
    // Handle game selection
}
```

## Mock ViewModel

The `MockRecentlyPlayedGamesViewModel` provides several factory methods for different scenarios:

```swift
// Predefined scenarios
let defaultGames = MockRecentlyPlayedGamesViewModel.defaultRecentlyPlayed      // 5 games
let fewGames = MockRecentlyPlayedGamesViewModel.fewGames                      // 2 games
let longNames = MockRecentlyPlayedGamesViewModel.longGameNames                // Long text testing
let emptyGames = MockRecentlyPlayedGamesViewModel.emptyRecentlyPlayed         // No games

// Custom scenario
let custom = MockRecentlyPlayedGamesViewModel.customRecentlyPlayed(
    sectionId: "custom-id",
    title: "Custom Title",
    games: customGamesArray
)
```

## Visual Design

The component follows the Figma design specifications:

### Header (PillView)
- **Component**: Uses existing `PillItemView` from GomaUI
- **State**: Selected (orange background)
- **Text**: "Recently Played" 
- **Icon**: None
- **Padding**: 16px horizontal from screen edges

### Collection View
- **Layout**: Horizontal scrolling
- **Cell size**: 210×56pt
- **Spacing**: 12pt between cells
- **Content insets**: 16pt horizontal

### Game Tiles
- **Background**: `primaryInteractionLow` color (#FFF0E7)
- **Corner radius**: 12pt
- **Image**: 56×56pt, left-aligned with 8pt corner radius
- **Title**: Bold 12pt, `textPrimary` color
- **Provider**: Regular 12pt, `textSecondary` color
- **Content padding**: 12pt horizontal

## States

### Normal State
- Displays games from viewModel
- Collection scrolls horizontally
- Tiles are interactive
- Publishers provide real-time updates

### Placeholder State
- Shows when no viewModel is provided or games array is empty
- Displays 3 placeholder tiles with generic content
- Tiles still interactive but return empty IDs

### Loading State
- Individual game images show loading indicators
- Graceful fallback to placeholder images on load failure

## Integration

### With Existing Components
- **PillItemView**: Uses existing GomaUI component for header
- **StyleProvider**: Follows GomaUI color and typography system
- **Collection patterns**: Follows established GomaUI collection view patterns

### Performance Considerations
- **Image caching**: Images are cached by URLSession
- **Reusable cells**: Collection view cells are reused efficiently
- **Memory management**: Weak references prevent retain cycles

## Accessibility

The component supports:
- VoiceOver navigation for header and individual games
- Dynamic type scaling for text elements
- High contrast support through StyleProvider
- Proper touch target sizing (minimum 44pt)

## Collection View Integration

For use within UICollectionView layouts, use the provided wrapper cell:

### RecentlyPlayedGamesCollectionViewCell

```swift
import GomaUI

// Register the cell
collectionView.register(RecentlyPlayedGamesCollectionViewCell.self, forCellWithReuseIdentifier: "RecentlyPlayedCell")

// Configure in cellForItemAt
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentlyPlayedCell", for: indexPath) as! RecentlyPlayedGamesCollectionViewCell
    
    // Configure with your view model
    cell.configure(with: recentlyPlayedGamesViewModel)
    
    // Setup callbacks
    cell.onGameSelected = { gameId in
        print("Recently played game selected: \(gameId)")
        // Handle game selection navigation
    }
    
    return cell
}

// Size for collection view layout
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 100)
}
```

### Collection View Cell Features

- **Automatic cleanup**: Properly handles reuse and memory management
- **Callback forwarding**: All RecentlyPlayedGamesView callbacks are available
- **Configuration support**: Works with any RecentlyPlayedGamesViewModelProtocol
- **Placeholder handling**: Falls back to placeholder state when no viewModel provided

## Demo

See `RecentlyPlayedGamesViewController` in the GomaUI Demo app for interactive examples showcasing:
- Different game collections (default, few games, long names, empty)
- Runtime configuration switching
- Game selection handling
- Refresh functionality
- Placeholder state demonstration