# CasinoCategorySectionView

A composite component that combines a category header with a horizontal collection of casino game cards, following MVVM architecture with proper child ViewModel management.

## Overview

The `CasinoCategorySectionView` provides a complete category section for casino games, featuring a `CasinoCategoryBarView` header and a horizontal collection view of `CasinoGameCardView` components. This component strictly follows the MVVM Vertical Pattern where the parent ViewModel creates and manages child ViewModels for its subviews.

## Features

- **MVVM Compliant**: Follows Documentation/MVVM.md guidelines with proper Vertical Pattern implementation
- **Child ViewModel Management**: Parent ViewModel creates and manages child ViewModels for subcomponents
- **Composite Architecture**: Combines existing CasinoCategoryBarView and CasinoGameCardView components
- **Separate Cell Component**: CasinoGameCardCollectionViewCell for proper collection view architecture
- **Reactive Updates**: Uses Combine publishers for real-time UI updates
- **Interactive Elements**: Game selection and category button tap handling
- **Optional ViewModel**: Can be initialized with or without a viewModel
- **Runtime Configuration**: Supports changing viewModel after initialization

## Architecture

### MVVM Hierarchy (Vertical Pattern ✅)

```swift
CasinoCategorySectionViewModel (Parent)
    ├── CasinoCategoryBarViewModel (Child)
    └── [CasinoGameCardViewModel] (Children array)

// ✅ CORRECT: Parent ViewModel creates children for its subviews
class CasinoCategorySectionViewModel {
    let categoryBarViewModel: CasinoCategoryBarViewModelProtocol
    let gameCardViewModels: [CasinoGameCardViewModelProtocol]
    
    init(sectionData: CasinoCategorySectionData) {
        // Parent creates child ViewModels for its own component
        self.categoryBarViewModel = MockCasinoCategoryBarViewModel(...)
        self.gameCardViewModels = sectionData.games.map { game in
            MockCasinoGameCardViewModel(gameData: game)
        }
        
        setupChildCommunication()
    }
}
```

### Components Structure
```
CasinoCategorySectionView/
├── CasinoCategorySectionViewModelProtocol.swift    # Protocol and data models
├── CasinoCategorySectionView.swift                 # Main UI component
├── CasinoGameCardCollectionViewCell.swift          # Separate cell wrapper
├── MockCasinoCategorySectionViewModel.swift        # Mock implementation
└── Documentation/
    └── README.md                                   # This file
```

## Usage

### Basic Usage
```swift


// With viewModel
let viewModel = MockCasinoCategorySectionViewModel.newGamesSection
let categorySection = CasinoCategorySectionView(viewModel: viewModel)

// Without viewModel (shows placeholder)
let categorySection = CasinoCategorySectionView()
```

### Runtime Configuration
```swift
let categorySection = CasinoCategorySectionView()

// Configure with viewModel
categorySection.configure(with: viewModel)

// Clear viewModel (shows placeholder)
categorySection.configure(with: nil)
```

### Callback Handling
```swift
categorySection.onGameSelected = { gameId in
    print("Game selected: \(gameId)")
    // Handle navigation to game or launch game
}

categorySection.onCategoryButtonTapped = { categoryId in
    print("Category button tapped: \(categoryId)")
    // Handle navigation to full category view
}
```

## Data Models

### CasinoCategorySectionData
```swift
public struct CasinoCategorySectionData: Equatable, Hashable, Identifiable {
    public let id: String               // category identifier  
    public let categoryTitle: String    // category title (e.g., "New Games")
    public let categoryButtonText: String // button text (e.g., "All 41")
    public let games: [CasinoGameCardData] // array of games in this category
}
```

## ViewModel Protocol

### CasinoCategorySectionViewModelProtocol
```swift
public protocol CasinoCategorySectionViewModelProtocol: AnyObject {
    // Child ViewModels (Vertical Pattern - Parent creates children)
    var categoryBarViewModel: CasinoCategoryBarViewModelProtocol { get }
    var gameCardViewModels: [CasinoGameCardViewModelProtocol] { get }
    
    // Publishers for reactive updates
    var gameCardViewModelsPublisher: AnyPublisher<[CasinoGameCardViewModelProtocol], Never> { get }
    
    // Read-only properties
    var sectionId: String { get }
    var categoryTitle: String { get }
    
    // Actions
    func gameSelected(_ gameId: String)
    func categoryButtonTapped()
    func refreshGames()
}
```

## Child ViewModel Management

### MVVM Compliance
The component follows the **Vertical Pattern** from Documentation/MVVM.md:

**✅ DO (Vertical Pattern):**
- Parent ViewModel creates child ViewModels for its subviews
- `CasinoCategorySectionViewModel` creates `CasinoCategoryBarViewModel`
- `CasinoCategorySectionViewModel` creates array of `CasinoGameCardViewModel`
- Parent manages all child ViewModels for the same component
- Children communicate up via callbacks/publishers

**❌ DON'T (Horizontal Pattern):**
- ViewModels creating ViewModels for other ViewControllers
- Direct ViewModel-to-ViewModel communication across components
- Circular references between ViewModels

### Communication Pattern
```swift
// Children communicate UP to parent via callbacks
gameCardViewModels.forEach { gameVM in
    gameVM.onGameSelected = { [weak self] gameId in
        self?.handleGameSelection(gameId)
    }
}

// Parent coordinates between children if needed
private func setupChildCommunication() {
    // Any cross-child communication handled by parent
    // For example, game selection updating category bar state
}
```

## Collection View Architecture

### CasinoGameCardCollectionViewCell
The separate cell component provides:

- **Wrapper Pattern**: Wraps `CasinoGameCardView` in collection view cell
- **Proper Reuse**: Handles cell reuse with state cleanup
- **Callback Forwarding**: Forwards game selection callbacks
- **ViewModel Management**: Manages bindings and cancellables

```swift
class CasinoGameCardCollectionViewCell: UICollectionViewCell {
    private let gameCardView = CasinoGameCardView()
    
    func configure(with viewModel: CasinoGameCardViewModelProtocol?) {
        gameCardView.configure(with: viewModel)
    }
    
    var onGameSelected: ((String) -> Void) {
        get { gameCardView.onGameSelected }
        set { gameCardView.onGameSelected = newValue }
    }
}
```

## Mock ViewModel

The `MockCasinoCategorySectionViewModel` provides factory methods for different scenarios:

```swift
// Predefined sections
let newGames = MockCasinoCategorySectionViewModel.newGamesSection      // 4 games
let popular = MockCasinoCategorySectionViewModel.popularGamesSection   // 3 games
let slots = MockCasinoCategorySectionViewModel.slotGamesSection        // 2 games
let empty = MockCasinoCategorySectionViewModel.emptySection            // 0 games

// Custom section
let custom = MockCasinoCategorySectionViewModel.customSection(
    id: "custom-id",
    categoryTitle: "Custom Category",
    categoryButtonText: "All 15",
    games: customGamesArray
)
```

## Visual Design

The component follows a vertical layout:

### Category Bar (Top)
- Uses existing `CasinoCategoryBarView` component
- Orange background with title and button
- Full width with proper padding

### Collection View (Bottom)
- **Layout**: Horizontal scrolling
- **Cell size**: 164×272pt (CasinoGameCardView dimensions)
- **Spacing**: 12pt between cells
- **Content insets**: 16pt horizontal
- **Height**: Fixed at 272pt

### Overall Layout
- **Vertical spacing**: 12pt between category bar and collection
- **Background**: StyleProvider.Color.backgroundPrimary

## States

### Normal State
- Category bar displays title and button text from ViewModel
- Collection displays game cards from child ViewModels
- All interactive elements are functional
- Publishers provide real-time updates

### Placeholder State
- Shows when no viewModel is provided
- Category bar shows placeholder content
- Collection displays 3 placeholder game cards
- Interactive elements still functional but return empty IDs

### Empty State
- Category bar displays normally
- Collection shows placeholder cards when games array is empty
- Proper handling of edge cases

## MVVM Benefits

### Testability
```swift
// Each ViewModel can be unit tested independently
func testGameSelection() {
    let viewModel = MockCasinoCategorySectionViewModel.newGamesSection
    var selectedGameId: String?
    
    // Test child ViewModel communication
    viewModel.gameSelected("test-game-id")
    // Assert expected behavior
}
```

### Separation of Concerns
- **View**: Only displays and captures input
- **ViewModel**: Contains all business logic and child management
- **Parent ViewModel**: Coordinates between child ViewModels
- **Child ViewModels**: Handle their specific domain logic

### Maintainability
- Clear ownership hierarchy
- Easy to add new child components
- Consistent communication patterns
- Follows established GomaUI patterns

## Integration

### With Main Casino Screen
When used in a main casino screen, the parent screen's ViewModel would create multiple category section ViewModels:

```swift
// ✅ CORRECT: Main screen ViewModel creates section ViewModels
class CasinoMainScreenViewModel {
    let categorySectionViewModels: [CasinoCategorySectionViewModelProtocol]
    
    init(categories: [CasinoCategorySectionData]) {
        self.categorySectionViewModels = categories.map { categoryData in
            MockCasinoCategorySectionViewModel(sectionData: categoryData)
        }
    }
}
```

## Performance Considerations

- **ViewModel Creation**: Efficient batch creation of child ViewModels
- **Collection View**: Proper cell reuse with state cleanup
- **Memory Management**: Weak references prevent retain cycles
- **Reactive Updates**: Combine publishers are properly disposed

## Collection View Integration

For use within UICollectionView layouts, use the provided wrapper cell:

### CasinoCategorySectionCollectionViewCell

```swift


// Register the cell
collectionView.register(CasinoCategorySectionCollectionViewCell.self, forCellWithReuseIdentifier: "CategorySectionCell")

// Configure in cellForItemAt
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategorySectionCell", for: indexPath) as! CasinoCategorySectionCollectionViewCell
    
    // Configure with your view model
    let categorySection = categorySections[indexPath.item]
    cell.configure(with: categorySection)
    
    // Setup callbacks
    cell.onCategoryButtonTapped = { categoryId in
        print("Category button tapped: \(categoryId)")
        // Handle navigation to full category view
    }
    
    cell.onGameSelected = { gameId in
        print("Game selected: \(gameId)")
        // Handle game selection navigation
    }
    
    return cell
}

// Size for collection view layout
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 330) // CasinoCategorySectionView height + spacing
}
```

### Collection View Cell Features

- **Automatic cleanup**: Properly handles reuse and memory management
- **Callback forwarding**: All CasinoCategorySectionView callbacks are available
- **Configuration support**: Works with any CasinoCategorySectionViewModelProtocol
- **Placeholder handling**: Falls back to placeholder state when no viewModel provided

## Demo

See `CasinoCategorySectionViewController` in the GomaUI Demo app for interactive examples showcasing:
- Multiple category sections with different game counts
- Runtime configuration switching
- Game selection and category button handling
- Refresh functionality
- MVVM child ViewModel management demonstration

## MVVM Summary

This component demonstrates proper MVVM architecture with:
- ✅ Parent ViewModel creates child ViewModels for its subviews
- ✅ Clear communication patterns via callbacks/publishers
- ✅ No UIKit imports in ViewModels
- ✅ Proper separation of concerns
- ✅ Testable architecture
- ✅ Memory-safe with weak references
