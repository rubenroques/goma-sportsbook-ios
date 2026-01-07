# MarketOutcomesLineView

MarketOutcomesLineView is a flexible component designed for displaying betting market outcomes in a horizontal layout. It supports two-way and three-way markets with rich interaction capabilities including selection states, odds change indicators, and various display modes.

## Features

- **Multiple Market Types**: Support for 2-way and 3-way markets
- **Interactive Selection**: Tap to select/deselect outcomes with visual feedback
- **Regulatory-Compliant Odds Change Animations**: Automatic odds direction calculation with proper animation timing and interruption handling
- **Multiple Display Modes**: Normal, suspended, and "see all" states
- **Granular State Management**: Individual property updates for optimal performance
- **Accessibility Support**: Full VoiceOver support with proper traits
- **Haptic Feedback**: Success feedback on outcome selection

## Use Cases

- Sports betting outcome selection (1X2, Over/Under, etc.)
- Market outcome displays in live betting
- Suspended market notifications
- "See all markets" navigation triggers
- Any scenario requiring horizontal outcome selection

## Usage Example

### Basic Three-Way Market (1X2)

```swift
// Create a view model (or use a mock for testing)
let viewModel = MockMarketOutcomesLineViewModel.threeWayMarket

// Create the component
let marketOutcomesView = MarketOutcomesLineView(viewModel: viewModel)
marketOutcomesView.translatesAutoresizingMaskIntoConstraints = false

// Add to your view hierarchy
parentView.addSubview(marketOutcomesView)

// Set up constraints
NSLayoutConstraint.activate([
    marketOutcomesView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    marketOutcomesView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16),
    marketOutcomesView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 16),
    marketOutcomesView.heightAnchor.constraint(equalToConstant: 40)
])

// Handle outcome selection
marketOutcomesView.onOutcomeSelected = { outcomeType in
    print("Outcome selected: \(outcomeType)")
    // Add to bet slip, update UI, etc.
}

marketOutcomesView.onOutcomeDeselected = { outcomeType in
    print("Outcome deselected: \(outcomeType)")
    // Remove from bet slip, update UI, etc.
}

marketOutcomesView.onOutcomeLongPress = { outcomeType in
    print("Long press on: \(outcomeType)")
    // Show additional options, quick bet, etc.
}
```

### Two-Way Market (Over/Under)

```swift
let viewModel = MockMarketOutcomesLineViewModel.twoWayMarket
let marketView = MarketOutcomesLineView(viewModel: viewModel)

// The middle outcome will be automatically hidden
// Only left and right outcomes will be displayed
```

### Suspended Market

```swift
let viewModel = MockMarketOutcomesLineViewModel.suspendedMarket
let marketView = MarketOutcomesLineView(viewModel: viewModel)

// Will display "Market Suspended" message
// All outcome interactions are disabled
```

### Custom Market Configuration

```swift
let customViewModel = MockMarketOutcomesLineViewModel.customMarket(
    displayMode: .normal,
    leftOutcome: MarketOutcomeData(
        id: "home",
        title: "Barcelona",
        value: "1.45",
        oddsChangeDirection: .up,
        isSelected: false,
        isDisabled: false
    ),
    middleOutcome: MarketOutcomeData(
        id: "draw",
        title: "Draw",
        value: "4.20",
        oddsChangeDirection: .none,
        isSelected: false,
        isDisabled: false
    ),
    rightOutcome: MarketOutcomeData(
        id: "away",
        title: "Real Madrid",
        value: "6.50",
        oddsChangeDirection: .down,
        isSelected: true,
        isDisabled: false
    ),
    showMiddleOutcome: true
)

let marketView = MarketOutcomesLineView(viewModel: customViewModel)
```

## Configuration Options

### MarketOutcomeData Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier for the outcome |
| `title` | String | Display text (e.g., "Home", "Over 2.5") |
| `value` | String | Odds value (e.g., "1.85", "2.50") |
| `oddsChangeDirection` | OddsChangeDirection | Visual indicator for odds movement |
| `isSelected` | Bool | Whether the outcome is currently selected |
| `isDisabled` | Bool | Whether the outcome can be interacted with |

### Display Modes

| Mode | Description |
|------|-------------|
| `.triple` | Three-way market with left, middle, and right outcomes |
| `.double` | Two-way market with left and right outcomes only |
| `.suspended(text: String)` | Shows custom suspension message, hides outcomes |
| `.seeAll(text: String)` | Shows custom "See All" button for navigation |

### Odds Change Directions

| Direction | Visual Indicator |
|-----------|------------------|
| `.up` | Green up arrow |
| `.down` | Red down arrow |
| `.none` | No indicator |

## Efficient State Management

The component uses a streamlined architecture with two publishers:

```swift
// Single state publisher for all market data
viewModel.marketStatePublisher
    .sink { state in
        // Updates all market data in one efficient operation
        // Only renders when actual data changes
    }

// Separate publisher for odds change animations (performance optimization)
viewModel.oddsChangeEventPublisher
    .sink { changeEvent in
        // Triggers animations without re-rendering market data
    }
```

This approach provides optimal performance by:
- **Single State Update**: All market data updates in one operation
- **Animation Separation**: Odds change animations don't trigger data re-renders
- **Smart Diffing**: Only updates UI elements that actually changed

## Available Mock Data

### Predefined Markets

```swift
MockMarketOutcomesLineViewModel.threeWayMarket      // 1X2 football market
MockMarketOutcomesLineViewModel.twoWayMarket        // Over/Under market
MockMarketOutcomesLineViewModel.selectedOutcome     // Market with selection
MockMarketOutcomesLineViewModel.oddsChanges         // Market with odds movements
MockMarketOutcomesLineViewModel.disabledOutcome     // Market with disabled outcome
MockMarketOutcomesLineViewModel.suspendedMarket     // Suspended state
MockMarketOutcomesLineViewModel.seeAllMarket        // See all state
MockMarketOutcomesLineViewModel.doubleChanceMarket  // Double chance market
MockMarketOutcomesLineViewModel.asianHandicapMarket // Asian handicap market
```

### Custom Factory

```swift
MockMarketOutcomesLineViewModel.customMarket(
    displayMode: .normal,
    leftOutcome: /* your outcome */,
    middleOutcome: /* your outcome */,
    rightOutcome: /* your outcome */,
    showMiddleOutcome: true
)
```

## Styling

The MarketOutcomesLineView uses StyleProvider for consistent theming:

```swift
// Customize colors
StyleProvider.Color.customize(
    primaryColor: UIColor(named: "BrandPrimary"),
    backgroundColor: .systemBackground,
    textColor: .label,
    contrastTextColor: .white,
    secondaryColor: .systemGray,
    successColor: .systemGreen
)

// Customize fonts
StyleProvider.setFontProvider { type, size in
    // Return custom fonts based on type and size
}
```

### Color Usage

- **Primary Color**: Selected outcome background
- **Background Color**: Unselected outcome background
- **Text Color**: Outcome text in unselected state
- **Contrast Text Color**: Outcome text in selected state
- **Secondary Color**: Suspended state styling
- **Success Color**: Up arrow indicator color

## Accessibility

The component includes comprehensive accessibility support:

- Each outcome is exposed as a button element
- Selection state is properly announced
- Disabled outcomes have appropriate traits
- Long press actions are accessible
- Descriptive labels include both title and odds value

## Integration with Collection Views

For use in table/collection views:

```swift
// In cellForRowAt or similar
cell.marketOutcomesView.cleanupForReuse()

let viewModel = createViewModelForIndexPath(indexPath)
cell.marketOutcomesView.configure(with: viewModel)

// Handle selections at cell level
cell.marketOutcomesView.onOutcomeSelected = { [weak self] outcomeType in
    self?.handleOutcomeSelection(at: indexPath, outcomeType: outcomeType)
}
```

## Performance Considerations

1. **Granular Updates**: Only affected UI elements update when state changes
2. **Reuse Support**: `cleanupForReuse()` method for collection view cells
3. **Lazy Loading**: UI elements are created lazily when first accessed
4. **Efficient Constraints**: Constraints are set up once during initialization

## Best Practices

1. **Use Meaningful IDs**: Provide descriptive IDs for outcomes to enable proper tracking
2. **Handle All Callbacks**: Implement selection, deselection, and long press handlers
3. **Consistent Styling**: Use StyleProvider for consistent appearance across the app
4. **Accessibility**: Test with VoiceOver to ensure proper accessibility
5. **State Management**: Use the granular publishers for optimal performance
6. **Error Handling**: Handle cases where outcomes might be nil or disabled

## Advanced Usage

### Dynamic Odds Updates

```swift
// Enhanced method with automatic direction calculation (recommended)
viewModel.updateOddsValue(type: .left, newValue: "1.95")
viewModel.updateOddsValue(type: .right, newValue: "4.10")

// Legacy method for manual direction specification (for testing)
viewModel.updateOddsValue(type: .left, value: "1.95", changeDirection: .up)
viewModel.updateOddsValue(type: .right, value: "4.10", changeDirection: .down)
```

### Regulatory-Compliant Animation Features

The component includes sophisticated animation management for regulatory compliance:

- **Automatic Direction Calculation**: Compares old vs new odds values to determine up/down direction
- **Animation Interruption**: New odds updates immediately cancel and replace existing animations
- **Consistent Timing**: All animations follow the same 3-second display duration
- **Visual Feedback**: Border color changes (green for up, red for down) with arrow indicators
- **Proper Cleanup**: Animations are properly cancelled during view reuse or deallocation

### Market State Transitions

```swift
// Switch to suspended state with custom text
viewModel.setDisplayMode(.suspended(text: "Market temporarily unavailable"))

// Switch to see all state with custom text
viewModel.setDisplayMode(.seeAll(text: "View all 25+ markets"))

// Switch between market types
viewModel.setDisplayMode(.triple)  // Three-way market
viewModel.setDisplayMode(.double)  // Two-way market
```

### Selection Management

```swift
// Programmatically select/deselect outcomes
viewModel.selectOutcome(type: .left)
viewModel.deselectOutcome(type: .middle)
```

This component provides a robust foundation for displaying betting market outcomes with excellent performance characteristics and comprehensive customization options. 