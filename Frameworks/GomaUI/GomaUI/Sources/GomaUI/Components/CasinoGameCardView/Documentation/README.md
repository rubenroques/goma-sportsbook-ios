# CasinoGameCardView

A GomaUI component for displaying casino game cards with optional viewModel initialization and runtime configuration support.

## Overview

CasinoGameCardView is a self-contained UIView component that displays casino game information including game image, title, provider, star rating, minimum stake, and optional badges/favorite icons. The component follows GomaUI's MVVM architecture with protocol-based ViewModels and supports both optional initialization and runtime configuration.

## Features

- **Optional ViewModel Initialization**: Can be initialized with or without a viewModel
- **Runtime Configuration**: Supports configuring with a new viewModel at any time
- **Self-Rendering Placeholder**: Displays placeholder content when no viewModel is provided
- **Reactive UI Updates**: Uses Combine framework for reactive data binding
- **Image Loading**: Built-in image loading with loading states and error handling
- **Interactive Elements**: Supports game selection and favorite toggling
- **Consistent Theming**: Uses StyleProvider for consistent colors and fonts

## Architecture

### Core Components

1. **CasinoGameCardViewModelProtocol**: Defines the contract for ViewModels
2. **CasinoGameCardView**: Main UI component with optional viewModel support
3. **MockCasinoGameCardViewModel**: Mock implementation for testing and previews
4. **README.md**: This documentation file

### ViewModel Protocol

```swift
public protocol CasinoGameCardViewModelProtocol: AnyObject {
    // Data Publishers
    var displayStatePublisher: AnyPublisher<CasinoGameCardDisplayState, Never> { get }
    var gameNamePublisher: AnyPublisher<String, Never> { get }
    var providerNamePublisher: AnyPublisher<String, Never> { get }
    var ratingPublisher: AnyPublisher<Double, Never> { get }
    var minStakePublisher: AnyPublisher<String, Never> { get }
    var imageURLPublisher: AnyPublisher<String?, Never> { get }
    var showNewBadgePublisher: AnyPublisher<Bool, Never> { get }
    var showFavoriteIconPublisher: AnyPublisher<Bool, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    
    // Properties
    var gameId: String { get }
    
    // Actions
    func selectGame()
    func toggleFavorite()
    func imageLoadingSucceeded()
    func imageLoadingFailed()
}
```

## Usage

### Basic Usage (Optional ViewModel)

```swift
// Initialize without viewModel (shows placeholder)
let gameCardView = CasinoGameCardView()

// Configure with viewModel later
let viewModel = MockCasinoGameCardViewModel.plinkGoal()
gameCardView.configure(with: viewModel)
```

### Direct Initialization

```swift
// Initialize with viewModel directly
let viewModel = MockCasinoGameCardViewModel.aviator()
let gameCardView = CasinoGameCardView(viewModel: viewModel)
```

### Handling User Interactions

```swift
gameCardView.onGameSelected = { gameId in
    // Handle game selection
    print("Game selected: \(gameId)")
}

gameCardView.onFavoriteToggled = { gameId, isFavorite in
    // Handle favorite toggle
    print("Game \(gameId) favorite status: \(isFavorite)")
}
```

## Data Models

### CasinoGameCardData

```swift
public struct CasinoGameCardData {
    public let gameId: String
    public let gameName: String
    public let providerName: String
    public let imageURL: String?
    public let rating: Double
    public let minStake: String
    public let currency: String
    public let isNew: Bool
    public let isFavorite: Bool
    public let isSelected: Bool
}
```

### CasinoGameCardDisplayState

```swift
public struct CasinoGameCardDisplayState {
    public let isLoading: Bool
    public let imageLoadingFailed: Bool
    
    public static let loading = CasinoGameCardDisplayState(isLoading: true, imageLoadingFailed: false)
    public static let normal = CasinoGameCardDisplayState(isLoading: false, imageLoadingFailed: false)
    public static let imageError = CasinoGameCardDisplayState(isLoading: false, imageLoadingFailed: true)
}
```

## Visual Specifications

- **Card Dimensions**: 160×220 points
- **Corner Radius**: 12 points
- **Image Height**: 120 points
- **Shadow**: Subtle shadow with StyleProvider.Color.shadow
- **Star Rating**: 5-star system with half-star support
- **Typography**: Uses StyleProvider fonts (bold 14pt for title, regular 12pt for provider)

## States

### Loading State
- Shows activity indicator over placeholder image
- Displays "Loading..." text for game name
- Shows placeholder text for other fields

### Normal State
- Displays all game information
- Shows loaded game image
- Interactive elements enabled

### Image Error State
- Shows "?" placeholder when image fails to load
- All other information displayed normally
- User can still interact with the card

### Placeholder State (No ViewModel)
- Shows when initialized without viewModel
- Displays placeholder content
- Non-interactive until viewModel is configured

## Mock Data

The component includes comprehensive mock data for testing and previews:

- `MockCasinoGameCardViewModel.plinkGoal()`: Popular game example
- `MockCasinoGameCardViewModel.beastBelow()`: Horror-themed game
- `MockCasinoGameCardViewModel.aviator()`: High-rating crash game
- `MockCasinoGameCardViewModel.loadingGame()`: Loading state example
- `MockCasinoGameCardViewModel.imageFailedGame()`: Image error state

## Testing

### Unit Tests
- Test optional viewModel initialization
- Test runtime configuration
- Test state transitions
- Test user interaction callbacks

### SwiftUI Previews
- Placeholder state preview (no viewModel)
- Various game examples
- Different states (loading, error, normal)

## Implementation Notes

1. **Memory Management**: Uses weak references in Combine bindings to prevent retain cycles
2. **Thread Safety**: All UI updates dispatched to main queue
3. **Image Loading**: Simple URLSession implementation (production should use proper image caching)
4. **Accessibility**: Component supports accessibility features through standard UIKit properties
5. **Performance**: Minimal view hierarchy with efficient constraint setup

## Dependencies

- **UIKit**: Core UI framework
- **Combine**: Reactive data binding
- **SwiftUI**: Preview support (iOS 17.0+)
- **GomaUI StyleProvider**: Consistent theming and colors

## Version History

- **1.0.0**: Initial implementation with optional viewModel support
  - Basic game card layout
  - MVVM architecture with protocols
  - Combine-based reactive updates
  - Mock implementations for testing