# OutcomeItemView

OutcomeItemView is a reusable component designed for displaying individual betting market outcomes. It provides a clean, interactive interface for outcome selection with visual feedback, odds change animations, and accessibility support.

## Features

- **Interactive Selection**: Tap to select/deselect outcomes with visual feedback
- **Odds Change Animations**: Regulatory-compliant animations for odds increases/decreases
- **Accessibility Support**: Full VoiceOver and accessibility trait support
- **Haptic Feedback**: Provides tactile feedback for user interactions
- **Customizable Styling**: Uses StyleProvider for consistent theming
- **State Management**: Reactive state updates using Combine publishers
- **Long Press Support**: Additional interaction for extended functionality

## Usage Example

```swift
// Create a view model (or use a mock for testing)
let outcomeData = OutcomeItemData(
    id: "home",
    title: "Home",
    value: "1.85",
    isSelected: false,
    isDisabled: false
)
let viewModel = MockOutcomeItemViewModel(outcomeData: outcomeData)

// Create the component
let outcomeView = OutcomeItemView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(outcomeView)

// Set up constraints
NSLayoutConstraint.activate([
    outcomeView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
    outcomeView.topAnchor.constraint(equalTo: parentView.topAnchor),
    outcomeView.widthAnchor.constraint(equalToConstant: 100),
    outcomeView.heightAnchor.constraint(equalToConstant: 50)
])

// Handle interactions
outcomeView.onTap = {
    print("Outcome tapped")
    // Handle selection logic
}

outcomeView.onLongPress = {
    print("Outcome long pressed")
    // Handle additional actions
}
```

## Configuration Options

### OutcomeItemData Properties

- **id**: Unique identifier for the outcome
- **title**: Display title (e.g., "Home", "Over 2.5")
- **value**: Odds value (e.g., "1.85", "2.50")
- **oddsChangeDirection**: Visual indicator for odds changes (.up, .down, .none)
- **isSelected**: Whether the outcome is currently selected
- **isDisabled**: Whether the outcome is disabled/grayed out
- **previousValue**: Previous odds value for change tracking
- **changeTimestamp**: When the odds change occurred

### View Model Methods

```swift
// Toggle selection state
let isNowSelected = viewModel.toggleSelection()

// Update odds value with automatic direction calculation
viewModel.updateValue("2.10")

// Update odds with specific direction
viewModel.updateValue("2.10", changeDirection: .up)

// Set selection state
viewModel.setSelected(true)

// Set disabled state
viewModel.setDisabled(true)

// Clear odds change indicators
viewModel.clearOddsChangeIndicator()
```

### Public View Methods

```swift
// Simulate odds change for testing
outcomeView.simulateOddsChange(newValue: "2.25")

// Programmatically set selection
outcomeView.setSelected(true)

// Programmatically set disabled state
outcomeView.setDisabled(true)
```

## Visual States

### Selection States
- **Unselected**: Default background with standard text colors
- **Selected**: Primary color background with contrast text colors
- **Disabled**: Reduced opacity (50%) with disabled interaction

### Odds Change Indicators
- **Odds Increase**: Green up arrow with green border animation
- **Odds Decrease**: Red down arrow with red border animation
- **No Change**: No indicators visible

### Animations
- **Odds Change**: 3-second regulatory-compliant animation with auto-hide
- **Selection**: Immediate visual feedback with haptic response
- **Border Animation**: Smooth color transition for odds changes

## Accessibility

The component provides comprehensive accessibility support:

- **VoiceOver**: Announces title and value as a single element
- **Accessibility Traits**: Marked as button with selection state
- **Disabled State**: Properly marked when disabled
- **Accessibility Label**: Combines title and value for clear context

## Mock Data Factory

The component includes several pre-configured mock view models:

```swift
// Basic outcomes
MockOutcomeItemViewModel.homeOutcome      // Selected home outcome
MockOutcomeItemViewModel.drawOutcome      // Unselected draw outcome
MockOutcomeItemViewModel.awayOutcome      // Unselected away outcome

// Odds change examples
MockOutcomeItemViewModel.overOutcomeUp    // Over outcome with odds increase
MockOutcomeItemViewModel.underOutcomeDown // Under outcome with odds decrease

// Special states
MockOutcomeItemViewModel.disabledOutcome  // Disabled outcome

// Custom factory
MockOutcomeItemViewModel.customOutcome(
    id: "custom",
    title: "Custom",
    value: "3.50",
    oddsChangeDirection: .up,
    isSelected: false,
    isDisabled: false
)
```

## Integration with Other Components

OutcomeItemView is designed to be used within larger components like:

- **MarketOutcomesLineView**: For single-line market displays
- **MarketOutcomesMultiLineView**: For multi-line market groups
- **Custom Market Components**: Any component needing outcome display

## Styling Customization

### Font Customization (OutcomeItemConfiguration)

The component supports per-instance font customization via `OutcomeItemConfiguration`:

```swift
// Create custom configuration
let compactConfig = OutcomeItemConfiguration(
    titleFontSize: 10.0,
    titleFontType: .regular,
    valueFontSize: 14.0,
    valueFontType: .bold
)

// Option 1: Pass configuration at initialization
let outcomeView = OutcomeItemView(
    viewModel: viewModel,
    configuration: compactConfig
)

// Option 2: Apply configuration after initialization
outcomeView.setCustomization(compactConfig)

// Option 3: Use predefined configurations
let defaultView = OutcomeItemView(viewModel: viewModel)  // Uses .default
let compactView = OutcomeItemView(viewModel: viewModel, configuration: .compact)

// Reset to default configuration
outcomeView.setCustomization(nil)
```

#### Available Configurations

| Configuration | Title Font | Value Font | Use Case |
|--------------|------------|------------|----------|
| `.default` | 12pt regular | 16pt bold | Standard outcome buttons |
| `.compact` | 10pt regular | 14pt bold | Inline match cards, compact layouts |

#### Custom Configuration Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `titleFontSize` | `CGFloat` | 12.0 | Font size for outcome title |
| `titleFontType` | `StyleProvider.FontType` | `.regular` | Font weight for title |
| `valueFontSize` | `CGFloat` | 16.0 | Font size for odds value |
| `valueFontType` | `StyleProvider.FontType` | `.bold` | Font weight for odds value |

### Global Theme Customization

The component also uses StyleProvider for global theming:

```swift
// Customize colors
StyleProvider.Color.customize(
    primaryColor: .systemBlue,        // Selected background
    backgroundColor: .systemGray6,    // Unselected background
    textColor: .label,               // Text color
    contrastTextColor: .white,       // Selected text color
    successColor: .systemGreen       // Odds increase color
)

// Customize fonts globally
StyleProvider.setFontProvider { type, size in
    switch type {
    case .regular:
        return UIFont.systemFont(ofSize: size, weight: .regular)
    case .bold:
        return UIFont.systemFont(ofSize: size, weight: .bold)
    // ... other cases
    }
}
```

## Performance Considerations

- **Reactive Updates**: Only updates UI elements that actually changed
- **Animation Management**: Cancels previous animations to prevent conflicts
- **Memory Management**: Uses weak references to prevent retain cycles
- **Efficient Rendering**: Minimal view hierarchy for optimal performance

## Testing

The component is designed for easy testing:

```swift
// Create test view model
let testData = OutcomeItemData(
    id: "test",
    title: "Test",
    value: "2.00",
    isSelected: false,
    isDisabled: false
)
let testViewModel = MockOutcomeItemViewModel(outcomeData: testData)

// Test selection
let wasSelected = testViewModel.toggleSelection()
XCTAssertTrue(wasSelected)

// Test odds change
testViewModel.updateValue("2.50")
// Verify odds change event was emitted

// Test disabled state
testViewModel.setDisabled(true)
// Verify UI reflects disabled state
```

## Requirements

- iOS 16.0+
- Swift 5.7+
- Combine framework
- UIKit framework 