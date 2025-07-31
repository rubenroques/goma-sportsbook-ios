# MarketGroupTabItemView

A reusable tab item component for displaying individual market group options in a betting interface. Each tab item can display a title and visual state (idle, selected, or disabled) with smooth animations and proper accessibility support.

## Features

- **Visual States**: Supports idle, selected, and disabled states with smooth transitions
- **Interactive**: Handles tap gestures with haptic feedback
- **Accessible**: Full VoiceOver support with appropriate traits and hints
- **Customizable**: Uses StyleProvider for consistent theming
- **Responsive**: Calculates intrinsic content size based on content

## Visual States

### Idle State
- Normal unselected appearance
- Secondary text color
- Regular font weight
- No underline indicator
- Fully interactive

### Selected State
- Primary text color indicating selection
- Medium font weight for emphasis
- Colored underline indicator
- Fully interactive

### Disabled State
- Reduced opacity (60%)
- Muted text color
- No underline indicator
- Non-interactive

## Usage

### Basic Implementation

```swift
import GomaUI

// Create a view model
let viewModel = MockMarketGroupTabItemViewModel.oneXTwoTab

// Create the view
let tabItemView = MarketGroupTabItemView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(tabItemView)
```

### Using Factory Methods

```swift
// Predefined market types
let oneXTwoTab = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.oneXTwoTab)
let doubleChanceTab = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.doubleChanceTab)
let overUnderTab = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.overUnderTab)

// Custom tab
let customTab = MarketGroupTabItemView(
    viewModel: MockMarketGroupTabItemViewModel.customTab(
        id: "custom_market",
        title: "Custom Market",
        selected: false
    )
)
```

### Handling Selection Events

```swift
viewModel.onTapPublisher
    .sink { tabId in
        print("Tab tapped: \(tabId)")
        // Handle tab selection
    }
    .store(in: &cancellables)
```

### Dynamic State Changes

```swift
// Change selection state
viewModel.setSelected(true)

// Disable the tab
viewModel.setEnabled(false)

// Update the title
viewModel.updateTitle("New Market Name")

// Set custom visual state
viewModel.setVisualState(.error("Market unavailable"))
```

## Component Architecture

### Data Model

```swift
public struct MarketGroupTabItemData: Equatable, Hashable {
    public let id: String           // Unique identifier
    public let title: String        // Display text
    public let visualState: MarketGroupTabItemVisualState
}
```

### Visual State Enum

```swift
public enum MarketGroupTabItemVisualState: Equatable {
    case idle           // Normal unselected state
    case selected       // Tab is currently selected
    case disabled       // Tab is disabled and non-interactive
}
```

### Protocol Interface

```swift
public protocol MarketGroupTabItemViewModelProtocol {
    // Content publishers
    var titlePublisher: AnyPublisher<String, Never> { get }
    var idPublisher: AnyPublisher<String, Never> { get }
    
    // Visual state management
    var visualStatePublisher: AnyPublisher<MarketGroupTabItemVisualState, Never> { get }
    var currentVisualState: MarketGroupTabItemVisualState { get }
    
    // User interaction
    var onTapPublisher: AnyPublisher<String, Never> { get }
    func handleTap()
    
    // State management
    func setVisualState(_ state: MarketGroupTabItemVisualState)
    func setSelected(_ selected: Bool)
    func setEnabled(_ enabled: Bool)
    func updateTitle(_ title: String)
}
```

## Styling

The component uses StyleProvider for consistent theming:

```swift
// Selected state styling
titleLabel.textColor = StyleProvider.Color.primaryColor
titleLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
underlineView.backgroundColor = StyleProvider.Color.primaryColor

// Idle state styling
titleLabel.textColor = StyleProvider.Color.secondaryColor
titleLabel.font = StyleProvider.fontWith(type: .regular, size: 14)

// Disabled state styling
titleLabel.textColor = StyleProvider.Color.secondaryColor.withAlphaComponent(0.5)
alpha = 0.6
```

## Layout and Sizing

### Constants

- **Horizontal Padding**: 16pt
- **Vertical Padding**: 12pt
- **Underline Height**: 2pt
- **Corner Radius**: 8pt
- **Animation Duration**: 0.2s

### Intrinsic Content Size

The component automatically calculates its size based on:
- Title label content size
- Horizontal and vertical padding
- Underline indicator height

## Accessibility

### VoiceOver Support

- **Accessibility Element**: Yes
- **Accessibility Traits**: Button (+ selected/notEnabled when applicable)
- **Accessibility Label**: Uses the tab title
- **Accessibility Hints**: State-specific guidance

### Dynamic Type Support

The component respects user's preferred text size through StyleProvider font system.

## Available Mock Data

### Predefined Tabs

```swift
MockMarketGroupTabItemViewModel.oneXTwoTab          // "1x2" (selected)
MockMarketGroupTabItemViewModel.doubleChanceTab     // "Double Chance" (idle)
MockMarketGroupTabItemViewModel.overUnderTab        // "Over/Under" (idle)
MockMarketGroupTabItemViewModel.anotherMarketTab    // "Another market" (idle)
MockMarketGroupTabItemViewModel.disabledTab         // "Disabled" (disabled)
```

### Collections

```swift
MockMarketGroupTabItemViewModel.standardMarketTabs  // [1x2, Double Chance, Over/Under, Another market]
MockMarketGroupTabItemViewModel.mixedStateTabs      // Mixed states including disabled
```

### Custom Factory

```swift
MockMarketGroupTabItemViewModel.customTab(
    id: "unique_id",
    title: "Custom Title",
    selected: false
)
```

## Integration with MarketGroupSelectorTabView

This component is designed to be used within `MarketGroupSelectorTabView` for creating complete tab bar interfaces:

```swift
let tabBar = MarketGroupSelectorTabView(viewModel: tabBarViewModel)
// TabBar automatically creates and manages MarketGroupTabItemView instances
```

## SwiftUI Preview Support

The component includes comprehensive SwiftUI previews for development:

- Individual state previews
- Multiple tab layout preview
- Interactive state demonstrations

```swift
#if DEBUG
MarketGroupTabItemView_Previews.previews
#endif
``` 