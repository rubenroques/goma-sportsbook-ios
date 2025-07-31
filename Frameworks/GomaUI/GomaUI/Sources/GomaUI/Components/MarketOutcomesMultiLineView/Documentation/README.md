# MarketOutcomesMultiLineView

MarketOutcomesMultiLineView is a flexible component designed for displaying multiple betting market outcome lines in a vertical layout. It supports both 2-column and 3-column layouts, independent line suspension, and all the rich interaction capabilities of the single-line component.

## Features

- **Multiple Market Lines**: Display multiple outcome lines in a vertical stack
- **Mixed Layout Support**: Each line can independently be 2-column or 3-column
- **Independent Line States**: Each line can be suspended, disabled, or active independently
- **Interactive Selection**: Tap to select/deselect outcomes with visual feedback per line
- **Regulatory-Compliant Odds Change Animations**: Automatic odds direction calculation with proper animation timing
- **Group Management**: Optional group title and expansion/collapse functionality
- **Loading & Error States**: Built-in loading indicator and error message display
- **Accessibility Support**: Full VoiceOver support with proper traits for all lines
- **Reusable Architecture**: Leverages existing MarketOutcomesLineView for each line

## Use Cases

- Over/Under markets with multiple goal thresholds (0.5, 1.0, 1.5, 2.5, 3.5)
- Asian Handicap markets with multiple handicap lines
- 1X2 markets for different time periods (Full Time, Half Time, etc.)
- Mixed market groups combining different market types
- Any scenario requiring multiple horizontal outcome lines

## Usage Example

### Basic Over/Under Market Group (2-Column Layout)

```swift
// Create a view model (or use a mock for testing)
let viewModel = MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup

// Create the component
let multiLineView = MarketOutcomesMultiLineView(viewModel: viewModel)
multiLineView.translatesAutoresizingMaskIntoConstraints = false

// Add to your view hierarchy
parentView.addSubview(multiLineView)

// Set up constraints
NSLayoutConstraint.activate([
    multiLineView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    multiLineView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16),
    multiLineView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 16),
    multiLineView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
])

// Handle outcome selection across all lines
multiLineView.onOutcomeSelected = { lineId, outcomeType in
    print("Outcome selected: \(outcomeType) in line \(lineId)")
    // Add to bet slip, update UI, etc.
}

multiLineView.onOutcomeDeselected = { lineId, outcomeType in
    print("Outcome deselected: \(outcomeType) in line \(lineId)")
    // Remove from bet slip, update UI, etc.
}

// Handle line-specific events
multiLineView.onLineSuspended = { lineId in
    print("Line suspended: \(lineId)")
    // Update UI to reflect suspension
}

multiLineView.onOddsChanged = { lineId, outcomeType, oldValue, newValue in
    print("Odds changed in line \(lineId): \(oldValue) -> \(newValue)")
    // Handle odds change notifications
}
```

### Home/Draw/Away Market Group (3-Column Layout)

```swift
let viewModel = MockMarketOutcomesMultiLineViewModel.homeDrawAwayMarketGroup
let multiLineView = MarketOutcomesMultiLineView(viewModel: viewModel)

// Each line will automatically display three columns (Home, Draw, Away)
// The component handles the layout differences automatically
```

### Mixed Layout Market Group

```swift
let viewModel = MockMarketOutcomesMultiLineViewModel.mixedLayoutMarketGroup
let multiLineView = MarketOutcomesMultiLineView(viewModel: viewModel)

// This group contains both 3-column lines (Match Result) and 2-column lines (Both Teams to Score)
// Each line uses its optimal layout while maintaining consistent spacing
```

### Market Group with Independent Line Suspension

```swift
let viewModel = MockMarketOutcomesMultiLineViewModel.overUnderWithSuspendedLine
let multiLineView = MarketOutcomesMultiLineView(viewModel: viewModel)

// Some lines are active while others are suspended
// Suspended lines are visually grayed out and non-interactive
```

### Dynamic Line Management

```swift
// Suspend a specific line
multiLineView.suspendLine(lineId: "over_under_2_5", message: "Market Temporarily Unavailable")

// Resume a suspended line
multiLineView.resumeLine(lineId: "over_under_2_5")

// Simulate odds changes
multiLineView.simulateOddsChange(lineId: "over_under_1_5", outcomeType: .left, newValue: "1.95")

// Toggle group expansion (if supported)
multiLineView.toggleExpansion()
```

## Configuration Options

### MarketLineData Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier for the market line |
| `leftOutcome` | MarketOutcomeData? | Left outcome (e.g., "Over 2.5", "Home") |
| `middleOutcome` | MarketOutcomeData? | Middle outcome (e.g., "Draw") - nil for 2-column |
| `rightOutcome` | MarketOutcomeData? | Right outcome (e.g., "Under 2.5", "Away") |
| `displayMode` | MarketDisplayMode | .double, .triple, .suspended(text), .seeAll(text) |
| `lineType` | MarketLineType | .twoColumn or .threeColumn |
| `isLineDisabled` | Bool | Whether the entire line is disabled/grayed out |

### MarketLineType Options

| Type | Description | Use Cases |
|------|-------------|-----------|
| `.twoColumn` | Left + Right outcomes only | Over/Under, Yes/No, Asian Handicap |
| `.threeColumn` | Left + Middle + Right outcomes | 1X2, Double Chance, Draw No Bet |

### MarketGroupData Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier for the market group |
| `groupTitle` | String? | Optional title displayed above all lines |
| `marketLines` | [MarketLineData] | Array of market lines to display |
| `defaultLineType` | MarketLineType | Default layout type for the group |
| `isExpanded` | Bool | Whether the group is expanded (for future use) |
| `maxVisibleLines` | Int? | Maximum lines to show before collapse (for future use) |

## Available Mock Data

### Predefined Market Groups

```swift
// Over/Under market group (matches the provided image)
MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup

// 1X2 market group with group title
MockMarketOutcomesMultiLineViewModel.homeDrawAwayMarketGroup

// Market group with one suspended line
MockMarketOutcomesMultiLineViewModel.overUnderWithSuspendedLine

// Mixed layout group (3-column + 2-column lines)
MockMarketOutcomesMultiLineViewModel.mixedLayoutMarketGroup

// Market group with odds changes and selections
MockMarketOutcomesMultiLineViewModel.marketGroupWithOddsChanges
```

### Custom Market Group Creation

```swift
let customLines = [
    MarketLineData(
        id: "custom_line_1",
        leftOutcome: MarketOutcomeData(id: "left1", title: "Over 4.5", value: "3.20"),
        middleOutcome: nil,
        rightOutcome: MarketOutcomeData(id: "right1", title: "Under 4.5", value: "1.30"),
        displayMode: .double,
        lineType: .twoColumn,
        isLineDisabled: false
    ),
    // Add more lines...
]

let customGroup = MarketGroupData(
    id: "custom_group",
    groupTitle: "Custom Markets",
    marketLines: customLines,
    defaultLineType: .twoColumn,
    isExpanded: true,
    maxVisibleLines: nil
)

let customViewModel = MockMarketOutcomesMultiLineViewModel(marketGroup: customGroup)
let multiLineView = MarketOutcomesMultiLineView(viewModel: customViewModel)
```

## Styling

The MarketOutcomesMultiLineView uses StyleProvider for consistent theming:

```swift
// Customize colors for all lines
StyleProvider.Color.customize(
    primaryColor: UIColor(named: "BrandPrimary"),
    secondaryColor: UIColor(named: "SecondaryGray"),
    backgroundColor: .systemBackground,
    textColor: .label
)

// The component automatically applies:
// - Group title styling using textColor and medium font
// - Line spacing and disabled states using disabledAlpha
// - Loading and error states using appropriate colors
```

## Architecture

### Component Hierarchy

```
MarketOutcomesMultiLineView
├── containerStackView (vertical)
│   ├── groupTitleLabel (optional, hidden if no title)
│   └── linesStackView (vertical)
│       ├── MarketOutcomesLineView (line 1)
│       ├── MarketOutcomesLineView (line 2)
│       └── MarketOutcomesLineView (line N)
├── loadingIndicator (centered, hidden when not loading)
└── errorLabel (centered, hidden when no error)
```

### Line Management

- Each line is a separate `MarketOutcomesLineView` instance
- Lines are dynamically added/removed based on data changes
- Each line maintains its own view model for independent state management
- Consistent 8pt spacing between lines
- Disabled lines use 50% alpha and disabled interaction

### State Management

The component uses reactive programming with two main publishers:

```swift
// Single state publisher for all market group data
viewModel.marketStatePublisher
    .sink { state in
        // Updates all lines, group title, loading/error states
    }

// Separate publisher for odds change animations
viewModel.oddsChangeEventPublisher
    .sink { changeEvent in
        // Triggers animations on specific lines without full re-render
    }
```

## Accessibility

### VoiceOver Support

- **Group Title**: Properly announced when present
- **Individual Lines**: Each line maintains full accessibility from MarketOutcomesLineView
- **Line Identification**: Accessibility identifiers follow pattern "marketLine.{lineId}"
- **State Announcements**: Loading, error, and suspension states are properly announced

### Dynamic Type Support

The component respects user's preferred text size through StyleProvider font system.

## Performance Considerations

- **Efficient Updates**: Only updates lines that actually changed
- **View Reuse**: Reuses existing line views when possible
- **Animation Separation**: Odds change animations don't trigger full data re-renders
- **Memory Management**: Properly cleans up removed lines and their view models

## Integration with Existing Components

The MarketOutcomesMultiLineView seamlessly integrates with:

- **MarketOutcomesLineView**: Reuses the existing single-line component
- **StyleProvider**: Uses the same theming system
- **Combine Framework**: Follows the same reactive patterns
- **Accessibility System**: Maintains the same accessibility standards

## Best Practices

1. **Use Meaningful Line IDs**: Provide descriptive IDs for each line to enable proper updates
2. **Consistent Line Types**: Use the same lineType for similar markets within a group
3. **Handle Suspension Gracefully**: Always provide clear suspension messages
4. **Optimize Updates**: Only update odds when values actually change
5. **Proper Cleanup**: The component automatically handles view cleanup when lines are removed

## Advanced Usage

### Real-time Odds Updates

```swift
// Update odds for a specific line and outcome
viewModel.updateOddsValue(lineId: "over_under_2_5", outcomeType: .left, newValue: "2.10")

// The component will automatically:
// 1. Calculate odds change direction
// 2. Update the line view model
// 3. Trigger appropriate animations
// 4. Notify callbacks
```

### Group-level Operations

```swift
// Suspend entire group
viewModel.suspendEntireGroup(message: "Markets Temporarily Unavailable")

// Resume entire group
viewModel.resumeEntireGroup()

// Update group title
viewModel.setGroupTitle("Updated Market Group")
```

This component provides a powerful and flexible solution for displaying multiple market outcome lines while maintaining the same interaction patterns and visual consistency as the single-line component. 