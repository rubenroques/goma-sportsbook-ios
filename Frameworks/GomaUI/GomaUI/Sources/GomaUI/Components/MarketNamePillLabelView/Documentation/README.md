# MarketNamePillLabelView

A pill-shaped label component designed specifically for displaying betting market names in sports betting applications. Provides a clean, modern appearance with customizable styling, optional fading line extension, and interactive capabilities.

## Features

- **Multiple Visual Styles**: Standard, highlighted, disabled, and fully customizable styling options
- **Interactive Support**: Tap-to-select functionality with visual feedback and animations
- **Loading States**: Built-in loading indicator with smooth transitions
- **Fading Line Extension**: Optional gradient line extending from the pill for visual hierarchy
- **Accessibility**: Full accessibility support with proper labels and traits
- **StyleProvider Integration**: Consistent theming using centralized color and font management
- **Reactive Updates**: Real-time UI updates via Combine publishers

## Usage Example

### Basic Implementation

```swift


// Create market data
let marketData = MarketNamePillData(
    text: "1X2",
    style: .standard,
    lineConfiguration: .default,
    isInteractive: false
)

// Create display state
let displayState = MarketNamePillDisplayState(
    pillData: marketData,
    isSelected: false,
    isLoading: false
)

// Create view model (use your actual implementation)
let viewModel = YourMarketPillViewModel(displayState: displayState)

// Create and configure the view
let pillView = MarketNamePillLabelView(viewModel: viewModel)
parentView.addSubview(pillView)

// Setup constraints
NSLayoutConstraint.activate([
    pillView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    pillView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 20)
])
```

### Interactive Market Selection

```swift
let interactiveMarket = MarketNamePillData(
    text: "Over/Under 2.5",
    style: .highlighted,
    lineConfiguration: .default,
    isInteractive: true
)

let displayState = MarketNamePillDisplayState(
    pillData: interactiveMarket,
    isSelected: false,
    isLoading: false
)

let viewModel = MockMarketNamePillLabelViewModel(displayState: displayState)
let pillView = MarketNamePillLabelView(viewModel: viewModel)

// Handle market selection
pillView.onInteraction = {
    print("Market selected: Over/Under 2.5")
    // Navigate to market details or update selection state
}
```

### Custom Styling

```swift
let customMarket = MarketNamePillData(
    text: "Asian Handicap",
    style: .custom(
        borderColor: .systemPurple,
        textColor: .systemPurple,
        backgroundColor: UIColor.systemPurple.withAlphaComponent(0.1)
    ),
    lineConfiguration: FadingLineConfiguration(
        isVisible: true,
        width: 25,
        color: .systemPurple
    ),
    isInteractive: true
)

let viewModel = MockMarketNamePillLabelViewModel(displayState: 
    MarketNamePillDisplayState(pillData: customMarket)
)
```

### Using Mock Data for Testing

```swift
// Use predefined mock examples
let pillView1 = MarketNamePillLabelView(viewModel: MockMarketNamePillLabelViewModel.standardPill)
let pillView2 = MarketNamePillLabelView(viewModel: MockMarketNamePillLabelViewModel.highlightedPill)
let pillView3 = MarketNamePillLabelView(viewModel: MockMarketNamePillLabelViewModel.interactivePill)

// Simulate loading
MockMarketNamePillLabelViewModel.loadingPill.simulateLoading {
    print("Loading completed")
}
```

## Component Architecture

### Data Models

#### `MarketNamePillData`
Contains all information needed to display a market pill:
- `text`: The market name text to display
- `style`: Visual styling (.standard, .highlighted, .disabled, .custom)
- `lineConfiguration`: Settings for the fading line extension
- `isInteractive`: Whether the pill can be tapped

#### `MarketNamePillStyle`
Defines the visual appearance:
- `.standard`: Default styling with secondary colors
- `.highlighted`: Emphasized styling with primary colors
- `.disabled`: Muted styling for inactive markets
- `.custom`: Fully customizable border, text, and background colors

#### `FadingLineConfiguration`
Controls the line extending from the pill:
- `isVisible`: Whether to show the line
- `width`: Line width in points
- `color`: Line color (uses separator color if nil)
- `fadeStartLocation`/`fadeEndLocation`: Gradient fade positions

#### `MarketNamePillDisplayState`
Represents the complete visual state:
- `pillData`: The market data and styling
- `isSelected`: Selection state for interactive pills
- `isLoading`: Loading state with spinner

### Layout and Sizing

The component automatically sizes itself based on text content:
- **Minimum Height**: 20 points
- **Horizontal Padding**: 6 points on each side
- **Vertical Padding**: 2 points top and bottom
- **Rounded Corners**: Calculated as height / 2 for perfect pill shape

## Visual States

### Standard State
```swift
// Basic market pill with default styling
let standardPill = MockMarketNamePillLabelViewModel.standardPill
```

### Highlighted State
```swift
// Emphasized market with highlight colors
let highlightedPill = MockMarketNamePillLabelViewModel.highlightedPill
```

### Selected State
```swift
// Interactive pill in selected state with scale animation
viewModel.setSelected(true)
```

### Loading State
```swift
// Shows spinner while hiding text
viewModel.setLoading(true)
```

### Disabled State
```swift
// Muted appearance for inactive markets
let disabledPill = MockMarketNamePillLabelViewModel.disabledPill
```

## Customization Options

### Line Configuration
```swift
// Custom line settings
let lineConfig = FadingLineConfiguration(
    isVisible: true,
    width: 30,
    color: .systemBlue,
    fadeStartLocation: 0.2,
    fadeEndLocation: 0.8
)

// Hide line completely
let hiddenLineConfig = FadingLineConfiguration.hidden
```

### Interactive Behavior
```swift
// Enable interaction
viewModel.updatePillData(MarketNamePillData(
    text: "Both Teams to Score",
    style: .standard,
    lineConfiguration: .default,
    isInteractive: true
))

// Handle interactions
pillView.onInteraction = {
    // Custom interaction handling
}
```

### Dynamic Updates
```swift
// Update text dynamically
viewModel.updateText("New Market Name")

// Cycle through styles
viewModel.cycleStyles()

// Simulate loading
viewModel.simulateLoading {
    print("Loading finished")
}
```

## Mock View Models

The component includes comprehensive mock implementations for testing:

### Basic Examples
- `MockMarketNamePillLabelViewModel.standardPill`: Default appearance
- `MockMarketNamePillLabelViewModel.highlightedPill`: Emphasized styling
- `MockMarketNamePillLabelViewModel.disabledPill`: Inactive state
- `MockMarketNamePillLabelViewModel.interactivePill`: Tappable pill
- `MockMarketNamePillLabelViewModel.loadingPill`: Loading state

### Real-World Markets
- `MockMarketNamePillLabelViewModel.winDrawWinMarket`: "1X2" market
- `MockMarketNamePillLabelViewModel.overUnderMarket`: "Over/Under 2.5" market
- `MockMarketNamePillLabelViewModel.handicapMarket`: "Asian Handicap" market
- `MockMarketNamePillLabelViewModel.bothTeamsToScoreMarket`: "BTTS" market

### Edge Cases
- `MockMarketNamePillLabelViewModel.longTextPill`: Test with long market names
- `MockMarketNamePillLabelViewModel.shortTextPill`: Test with minimal text
- `MockMarketNamePillLabelViewModel.pillWithoutLine`: No fading line
- `MockMarketNamePillLabelViewModel.customStyledPill`: Custom colors

## Accessibility

The component provides full accessibility support:
- Proper accessibility labels for market names
- Voice-over descriptions for interactive states
- Support for accessibility font scaling
- Appropriate accessibility traits for different states

## Performance Considerations

- **Efficient Updates**: Only renders changed elements when state updates
- **Memory Management**: Proper cleanup of Combine subscriptions
- **Layout Optimization**: Auto Layout constraints for smooth animations
- **Preview Performance**: Lightweight mock data for SwiftUI previews

## Integration with Existing Systems

### Migration from Legacy PillLabelView
This component replaces the legacy `PillLabelView` with:
- Improved data model design with clear separation of concerns
- Better styling system integration with StyleProvider
- Reactive programming patterns for state management
- Enhanced testability with comprehensive mock implementations
- More flexible customization options

### Best Practices
- Use `.standard` style for regular markets
- Use `.highlighted` style for featured or popular markets
- Use `.disabled` style for unavailable markets
- Enable `isInteractive` for selectable markets
- Provide meaningful market names for accessibility

## Testing

The component includes extensive testing support:
- Multiple mock scenarios for different market types
- Edge cases (long names, empty states)
- State transition testing (loading, selection, styling)
- Interactive behavior validation

Use the TestCase app to interactively test all component features and states.
