# PillSelectorBarView

A horizontal scrollable bar that displays multiple selectable pill-shaped items. Perfect for category filters, market selection, time period selection, and other filtering scenarios in sports betting applications.

## Features

- **Horizontal scrolling** with multiple pill items
- **Selection state management** with visual feedback
- **Optional left icons** and expand indicators on pills
- **Reactive updates** via Combine publishers
- **StyleProvider integration** for consistent theming
- **Haptic feedback** on selection
- **Auto-scrolling** to selected pills
- **Configurable spacing** and layout
- **Dynamic height** support for collection view integration

## Usage Example

### Basic Implementation

```swift
// Create a view model (or use a mock for testing)
let viewModel = MockPillSelectorBarViewModel.sportsCategories

// Create the component
let pillSelectorBar = PillSelectorBarView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(pillSelectorBar)

// Set up constraints
NSLayoutConstraint.activate([
    pillSelectorBar.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
    pillSelectorBar.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
    pillSelectorBar.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
    pillSelectorBar.heightAnchor.constraint(equalToConstant: 60)
])

// Handle pill selection
pillSelectorBar.onPillSelected = { pillId in
    print("Pill selected: \(pillId)")
    // Perform filtering, navigation, or other actions
}
```

### Read-Only Display Mode

```swift
// Create pills with their individual states (some selected, some not)
let pills = [
    PillData(id: "live", title: "Live", isSelected: true),
    PillData(id: "popular", title: "Popular", isSelected: false),
    PillData(id: "trending", title: "Trending", isSelected: true)
]

let barData = PillSelectorBarData(
    id: "filter_status",
    pills: pills,
    selectedPillId: nil,  // No single selection
    allowsVisualStateChanges: false  // States don't change on tap
)

let viewModel = YourCustomViewModel(barData: barData)
let pillSelectorBar = PillSelectorBarView(viewModel: viewModel)

// Taps trigger callbacks but don't change visual states
pillSelectorBar.onPillSelected = { pillId in
    print("Filter \(pillId) tapped - navigate to filter details")
    // Handle navigation or show filter details
}
```

### Integration in Collection View Cell

```swift
final class PillSelectorBarCollectionViewCell: UICollectionViewCell {
    static let identifier = "PillSelectorBarCollectionViewCell"
    
    private var pillSelectorBar: PillSelectorBarView?
    
    func configure(
        with viewModel: PillSelectorBarViewModelProtocol,
        onPillSelected: @escaping (String) -> Void = { _ in }
    ) {
        // Remove existing view
        pillSelectorBar?.removeFromSuperview()
        
        // Create new pill selector bar
        let selectorBar = PillSelectorBarView(viewModel: viewModel)
        selectorBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Handle events
        selectorBar.onPillSelected = onPillSelected
        
        // Add to content view
        contentView.addSubview(selectorBar)
        pillSelectorBar = selectorBar
        
        // Setup constraints for dynamic height
        NSLayoutConstraint.activate([
            selectorBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectorBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectorBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectorBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
```

### Custom View Model Implementation

```swift
class CustomPillSelectorBarViewModel: PillSelectorBarViewModelProtocol {
    private let displayStateSubject: CurrentValueSubject<PillSelectorBarDisplayState, Never>
    private let selectionEventSubject = PassthroughSubject<PillSelectionEvent, Never>()
    
    // ... implement protocol requirements
    
    func selectPill(id: String) {
        // Update your data source
        // Notify UI of changes
        // Trigger selection events
    }
}
```

## Configuration Options

### PillSelectorBarData Properties

- **`id`**: Unique identifier for the bar
- **`pills`**: Array of `PillData` items to display
- **`selectedPillId`**: Currently selected pill ID (optional)
- **`isScrollEnabled`**: Whether horizontal scrolling is enabled
- **`allowsVisualStateChanges`**: Whether pills visually change state when tapped (default: true)

### PillData Properties (from existing PillItemView)

- **`id`**: Unique identifier for the pill
- **`title`**: Display text
- **`leftIconName`**: Optional SF Symbol name for left icon
- **`showExpandIcon`**: Whether to show chevron down icon
- **`isSelected`**: Selection state

### Display State Options

- **`isVisible`**: Controls visibility of the entire bar
- **`isUserInteractionEnabled`**: Controls touch interaction

## Mock View Models

Several pre-configured mock view models are available for testing and previews:

### Sports Categories
```swift
MockPillSelectorBarViewModel.sportsCategories
// Contains: All, Football, Basketball, Baseball, Soccer, Tennis
// With appropriate sports icons and some expandable options
```

### Market Filters
```swift
MockPillSelectorBarViewModel.marketFilters
// Contains: Popular, Moneyline, Spread, Totals, Player Props, Live
// Mix of text-only and icon pills for betting markets
```

### Time Periods
```swift
MockPillSelectorBarViewModel.timePeriods
// Contains: Today, Tomorrow, This Week, This Month
// Simple time-based filtering options
```

### Limited Pills
```swift
MockPillSelectorBarViewModel.limitedPills
// Contains: Live, Upcoming
// For cases where scrolling isn't needed
```

### Read-Only States
```swift
MockPillSelectorBarViewModel.readOnlyMarketFilters
// Contains: Mixed selected/unselected states
// Pills don't change visual state when tapped - useful for displaying existing filter states
```

## Styling

The component uses StyleProvider for consistent theming:

- **Background**: `StyleProvider.Color.backgroundPrimary`
- **Pill styling**: Handled by individual `PillItemView` components
- **Spacing**: 12pt between pills, 16pt horizontal margins
- **Height**: Minimum 60pt, adjusts to content

## Selection Behavior

### Interactive Mode (allowsVisualStateChanges: true)
- **Single selection**: Only one pill can be selected at a time
- **Visual feedback**: Selected pills show border and updated styling
- **Haptic feedback**: Selection changes trigger haptic feedback
- **Auto-scroll**: Bar automatically scrolls to show selected pill
- **Events**: Selection changes trigger both view model updates and callback closures

### Read-Only Mode (allowsVisualStateChanges: false)
- **Fixed states**: Pills display their individual states without changing on tap
- **Multiple selected**: Multiple pills can show as selected simultaneously
- **Tap events**: Pills still trigger tap callbacks for external handling
- **No visual changes**: Pill states remain as defined in the data model
- **Use cases**: Displaying existing filter states, showing applied filters, status indicators

## Performance Considerations

- **Efficient updates**: Only rebuilds pill views when the pill set changes
- **Memory management**: Proper cleanup of pill view references
- **Smooth scrolling**: Optimized for horizontal scrolling performance
- **Lazy loading**: Pills are created only when needed

## Accessibility

- **VoiceOver support**: Each pill is accessible with descriptive labels
- **Traits**: Selected pills are marked with `.selected` trait
- **Navigation**: Supports focus-based navigation
- **Actions**: Pills respond to accessibility tap actions

## Best Practices

1. **Keep pill titles short** (1-2 words) for better layout
2. **Use icons consistently** - either all pills have icons or none do
3. **Limit pill count** - consider pagination for many options
4. **Provide selection feedback** in your view model
5. **Test on different screen sizes** to ensure proper scrolling
6. **Use expand icons** sparingly for pills that lead to sub-menus

## Integration with Existing Components

This component is designed to work seamlessly with:

- **TopBannerSliderView**: Use together for rich filtering interfaces
- **TallOddsMatchCardView**: Pills can filter match cards
- **Collection View Cells**: Perfect for dynamic height cells
- **Existing StyleProvider**: Consistent with app theming

The PillSelectorBarView provides a comprehensive solution for horizontal pill-based selection interfaces, following GomaUI's architectural patterns and design principles.
