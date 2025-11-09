# MarketInfoLineView

A **Tier 2 interactive component** that displays betting market information in a horizontal layout with market name pill, market count, and info icons.

## Overview

The `MarketInfoLineView` combines three key elements:
- **MarketNamePillLabelView** - Market name in pill format (left side)
- **Market Count Label** - "+1235" format showing available markets (right side)
- **Info Icons** - Visual indicators (EP, Popular, Stats, etc.) (right side)

## Architecture

### Component Structure
```
MarketInfoLineView (Horizontal StackView)
├── MarketNamePillLabelView (market pill)
└── Right Content StackView
    ├── Market Count Label (+1235)
    └── Icons StackView
        ├── Icon 1 (EP)
        ├── Icon 2 (Popular)
        └── Icon 3 (Stats)
```

### MVVM Pattern
- **Protocol**: `MarketInfoLineViewModelProtocol`
- **View**: `MarketInfoLineView`
- **Mock**: `MockMarketInfoLineViewModel`

## Usage

### Basic Implementation

```swift


// Create market info data
let marketInfo = MarketInfoData(
    marketName: "1X2 TR",
    marketCount: 1235,
    icons: [
        MarketInfoIcon(iconName: "erep_short_info", isVisible: true),
        MarketInfoIcon(iconName: "most_popular_info", isVisible: true),
        MarketInfoIcon(iconName: "stats_info", isVisible: true)
    ]
)

// Create view model
let viewModel = MockMarketInfoLineViewModel(marketInfoData: marketInfo)

// Create view
let marketInfoView = MarketInfoLineView(viewModel: viewModel)
```

### Tap Handling

```swift
// Add tap gesture to the view
let tapGesture = UITapGestureRecognizer(target: self, action: #selector(marketInfoTapped))
marketInfoView.addGestureRecognizer(tapGesture)
marketInfoView.isUserInteractionEnabled = true
```

## Data Models

### MarketInfoData
Main data structure for the component:

```swift
public struct MarketInfoData: Equatable, Hashable {
    public let marketName: String     // "1X2 TR"
    public let marketCount: Int       // 1235
    public let icons: [MarketInfoIcon] // Info icons array
}
```

### MarketInfoIcon
Individual icon configuration:

```swift
public struct MarketInfoIcon: Equatable, Hashable {
    public let iconName: String  // Asset name
    public let isVisible: Bool   // Show/hide flag
}
```

### MarketInfoLineDisplayState
Computed display state:

```swift
public struct MarketInfoLineDisplayState: Equatable {
    public let marketName: String           // Pill text
    public let marketCountText: String      // "+1235" format
    public let visibleIcons: [MarketInfoIcon] // Filtered icons
    public let shouldShowMarketCount: Bool  // Hide if count = 0
}
```

## Available Icons

Located in `Resources/Icons.xcassets/info_card_line/`:

### Standard Icons
- **`erep_short_info`** - EP (Express Pick) indicator
- **`most_popular_info`** - Popular markets indicator  
- **`stats_info`** - Statistics available indicator
- **`bet_builder_info`** - Bet Builder available indicator

### Icon Specifications
- **Size**: 20x20 points
- **Format**: PNG with @2x and @3x variants
- **Style**: Consistent with app design system

## Layout & Spacing

### Horizontal Layout
```
[MarketPill] ←8pt→ [CountLabel] ←8pt→ [Icon1] ←4pt→ [Icon2] ←4pt→ [Icon3]
```

### Spacing Configuration
- **Main spacing**: 8pt between pill and right content
- **Icon spacing**: 4pt between individual icons
- **Label spacing**: 8pt between count and icons

### Content Priorities
- **Market Pill**: High compression resistance (always visible)
- **Right Content**: Low compression resistance (can compress)
- **Count Label**: High hugging priority (tight fit)

## Mock Data

### Available Mocks

#### Default Mock
```swift
let viewModel = MockMarketInfoLineViewModel.defaultMock
```
- Market: "1X2 TR"
- Count: 1235 markets
- Icons: EP, Popular, Stats

#### Many Icons Mock
```swift
let viewModel = MockMarketInfoLineViewModel.manyIconsMock
```
- Market: "Both Teams To Score"
- Count: 2340 markets
- Icons: EP, Popular, Stats, Bet Builder

#### No Icons Mock
```swift
let viewModel = MockMarketInfoLineViewModel.noIconsMock
```
- Market: "Over/Under Goals"
- Count: 567 markets
- Icons: None

#### No Count Mock
```swift
let viewModel = MockMarketInfoLineViewModel.noCountMock
```
- Market: "Match Winner"
- Count: 0 (hidden)
- Icons: Popular only

## Integration with MarketNamePillLabelView

### Dynamic Pill Updates
The component creates and manages its own `MarketNamePillLabelView`:

```swift
// View model provides pill configuration
var marketNamePillViewModelPublisher: AnyPublisher<MarketNamePillLabelViewModelProtocol, Never> { get }

// Pill configuration for market info
let pillData = MarketNamePillData(
    id: "market_info_pill",
    text: marketInfoData.marketName,
    style: .highlighted,           // Orange style
    showFadingLine: true,         // Extends to right
    isLoading: false,             // No loading state
    isInteractive: false          // Read-only
)
```

### Pill Styling
- **Style**: Always highlighted (orange)
- **Fading Line**: Always enabled (extends to right side)
- **Interactive**: Disabled (handled by parent tap)

## Responsive Behavior

### Content Compression
When space is limited:
1. **Icons compress first** (may become clipped)
2. **Count label compresses** (text may truncate)
3. **Market pill maintains size** (highest priority)

### Dynamic Visibility
- **Count label hides** when `marketCount = 0`
- **Icons filter** based on `isVisible` property
- **Empty states** handle gracefully

## Testing & Previews

### SwiftUI Previews
Multiple preview configurations:

```swift
#Preview("Default") {
    PreviewUIView {
        MarketInfoLineView(viewModel: MockMarketInfoLineViewModel.defaultMock)
    }
    .frame(height: 40)
}

#Preview("Many Icons") {
    PreviewUIView {
        MarketInfoLineView(viewModel: MockMarketInfoLineViewModel.manyIconsMock)
    }
    .frame(height: 40)
}
```

## Best Practices

### Icon Management
```swift
// Good: Use provided icon names
MarketInfoIcon(iconName: "erep_short_info", isVisible: true)

// Good: Conditional visibility
MarketInfoIcon(iconName: "stats_info", isVisible: hasStats)

// Avoid: Hardcoded icon paths
MarketInfoIcon(iconName: "custom_icon", isVisible: true) // May not exist
```

### Market Count Formatting
```swift
// Automatic formatting in view model
marketCount: 1235 → "+1235"
marketCount: 0    → hidden
marketCount: 99   → "+99"
```

### Performance
- **Lazy icon creation**: Icons created only when visible
- **Efficient updates**: Only visible elements recreated
- **Memory management**: Icons removed when hidden

## Common Use Cases

### In Match Cards
```swift
// Part of PreLiveMatchCardView
let marketInfoView = MarketInfoLineView(viewModel: marketInfoViewModel)
// Positioned between participants and outcomes
```

### In Market Lists
```swift
// Header for market groups
let marketInfoView = MarketInfoLineView(viewModel: marketHeaderViewModel)
// Provides context for following outcome lists
```

### In Betslip
```swift
// Market summary in betslip items
let marketInfoView = MarketInfoLineView(viewModel: betslipMarketViewModel)
// Shows market type and available alternatives
```

## Accessibility

### Voice Over Support
- **Market pill**: Announces market name
- **Count label**: Announces available market count
- **Icons**: Individual accessibility labels for each icon type

### Semantic Configuration
```swift
// Accessibility labels for icons
erep_short_info: "Express Pick available"
most_popular_info: "Popular market"
stats_info: "Statistics available"
bet_builder_info: "Bet Builder available"
```

## Troubleshooting

### Common Issues

#### Icons Not Displaying
**Cause**: Icon name doesn't match asset bundle
**Solution**: Verify icon exists in `Resources/Icons.xcassets/info_card_line/`

#### Layout Compression Issues
**Cause**: Incorrect constraint priorities
**Solution**: Ensure market pill has highest compression resistance

#### Count Not Updating
**Cause**: View model not publishing new display state
**Solution**: Check `publishNewState()` is called after data changes

## Future Enhancements

### Interactive Icons
- Individual icon tap handling
- Icon-specific actions
- Tooltip/popover support

### Animation Support
- Count change animations
- Icon appearance transitions
- Pill style transitions

### Customization
- Icon size configuration
- Spacing customization
- Color theme support
