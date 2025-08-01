# SeeMoreButtonView

A reusable button component for "Load More" functionality with loading states, designed for pagination in collection views and table views.

## Features

- **Loading States**: Shows spinner and disables interaction during loading
- **Flexible Text**: Supports both static text and dynamic remaining count display
- **StyleProvider Integration**: Uses centralized theming for consistent appearance
- **Collection View Ready**: Includes dedicated collection view cell wrapper
- **Accessibility**: Full accessibility support with appropriate labels and hints
- **Reactive**: Uses Combine publishers for state management

## Usage Example

### Basic Usage

```swift
// Create a view model (or use a mock for testing)
let buttonData = SeeMoreButtonData(
    id: "load-more-games",
    title: "Load More Games",
    remainingCount: 25
)

let viewModel = MockSeeMoreButtonViewModel(buttonData: buttonData)

// Create the component
let seeMoreButtonView = SeeMoreButtonView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(seeMoreButtonView)

// Set up constraints
NSLayoutConstraint.activate([
    seeMoreButtonView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    seeMoreButtonView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16),
    seeMoreButtonView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
    seeMoreButtonView.heightAnchor.constraint(equalToConstant: 44)
])

// Handle button tap
seeMoreButtonView.onButtonTapped = {
    print("Load more button tapped!")
    // Perform pagination logic
}
```

### Collection View Usage

```swift
// Register the collection view cell
collectionView.register(SeeMoreButtonCollectionViewCell.self, forCellWithReuseIdentifier: "SeeMoreButtonCell")

// In cellForItemAt
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeeMoreButtonCell", for: indexPath) as! SeeMoreButtonCollectionViewCell
    
    // Configure with button data
    let buttonData = SeeMoreButtonData(
        id: "load-more-category",
        title: "Load More Games",
        remainingCount: remainingGamesCount
    )
    
    cell.configure(
        with: buttonData,
        isLoading: isLoadingMore,
        isEnabled: !isLoadingMore
    )
    
    // Handle tap
    cell.onSeeMoreTapped = { [weak self] in
        self?.loadMoreGames()
    }
    
    return cell
}
```

### State Management

```swift
// Using Mock ViewModel for testing
let viewModel = MockSeeMoreButtonViewModel.defaultMock

// Control loading state
viewModel.setLoading(true)  // Shows spinner, disables button
viewModel.setLoading(false) // Hides spinner, enables button

// Update remaining count
viewModel.updateRemainingCount(15) // Shows "Load 15 more games"
viewModel.updateRemainingCount(nil) // Shows default title

// Enable/disable button
viewModel.setEnabled(false) // Grays out button, disables interaction
viewModel.setEnabled(true)  // Normal appearance, enables interaction
```

## Configuration Options

### SeeMoreButtonData

- **id**: Unique identifier for the button
- **title**: Default button text (e.g., "Load More Games")
- **remainingCount**: Optional count to display (e.g., "Load 15 more games")

### SeeMoreButtonDisplayState

- **isLoading**: Whether to show loading spinner
- **isEnabled**: Whether button is enabled for interaction
- **buttonData**: The button configuration

## Design Specifications

- **Height**: 44pt (iOS standard button height)
- **Corner Radius**: 8pt
- **Font**: StyleProvider.fontWith(type: .medium, size: 13)
- **Background**: StyleProvider.Color.highlightPrimary
- **Text Color**: StyleProvider.Color.buttonTextPrimary
- **Loading Indicator**: Medium size, same color as text

## Mock Implementations

The component includes several pre-configured mock implementations:

- `MockSeeMoreButtonViewModel.defaultMock` - Basic "Load More" button
- `MockSeeMoreButtonViewModel.loadingMock` - Button in loading state
- `MockSeeMoreButtonViewModel.withCountMock` - Button with remaining count
- `MockSeeMoreButtonViewModel.disabledMock` - Disabled button state
- `MockSeeMoreButtonViewModel.interactiveMock` - Interactive demo version

## Integration with Pagination

The component is designed to work seamlessly with pagination systems:

1. **Initial State**: Show button with total remaining count
2. **Loading State**: Show spinner, disable interaction
3. **Success State**: Update remaining count, hide if no more items
4. **Error State**: Show retry button, enable interaction

## Accessibility

The component provides comprehensive accessibility support:

- **Dynamic Labels**: Updates based on loading/enabled state
- **Appropriate Hints**: Provides context for screen readers
- **State Changes**: Announces state changes to assistive technologies
- **Touch Targets**: Meets minimum 44pt touch target requirements

This component follows GomaUI patterns and integrates seamlessly with existing iOS applications using UICollectionView or UITableView pagination.