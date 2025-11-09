# MarketGroupSelectorTabView

A reusable horizontal scrollable tab bar component for displaying and managing multiple market group options in a betting interface. This container component automatically creates and manages `MarketGroupTabItemView` instances with coordinated selection handling.

## Features

- **Horizontal Scrolling**: Automatically scrolls when content exceeds view width
- **Dynamic Content**: Supports adding, removing, and updating market groups
- **Selection Coordination**: Ensures only one tab is selected at a time
- **Visual States**: Loading, empty, disabled, and idle states with smooth transitions
- **Accessibility**: Full VoiceOver support with proper navigation
- **Selection Events**: Publishes selection changes with detailed event information
- **Auto-scrolling**: Automatically scrolls to newly selected tabs

## Visual States

### Idle State
- Normal interactive state with tabs visible
- Horizontal scrolling enabled
- Full user interaction

### Loading State
- Shows activity indicator
- Hides tab content
- Non-interactive during loading

### Empty State
- Shows "No market groups available" message
- Hides scrolling content
- Non-interactive

### Disabled State
- Shows tabs with reduced opacity (60%)
- Disables all user interaction
- Maintains visual layout

## Usage

### Basic Implementation

```swift


// Create a view model
let viewModel = MockMarketGroupSelectorTabViewModel.standardSportsMarkets

// Create the tab view
let tabSelectorView = MarketGroupSelectorTabView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(tabSelectorView)
```

### Handling Selection Events

```swift
viewModel.selectionEventPublisher
    .sink { selectionEvent in
        print("Selected: \(selectionEvent.selectedId)")
        print("Previously selected: \(selectionEvent.previouslySelectedId ?? "None")")
        // Handle market group change
        loadContentForMarketGroup(selectionEvent.selectedId)
    }
    .store(in: &cancellables)
```

### Dynamic Market Group Management

```swift
// Add a new market group
let newMarketGroup = MarketGroupTabItemData(
    id: "new_market",
    title: "New Market",
    visualState: .idle
)
viewModel.addMarketGroup(newMarketGroup)

// Remove a market group
viewModel.removeMarketGroup(id: "unwanted_market")

// Update an existing market group
let updatedMarketGroup = MarketGroupTabItemData(
    id: "existing_id",
    title: "Updated Title",
    visualState: .disabled
)
viewModel.updateMarketGroup(updatedMarketGroup)

// Replace all market groups
let newMarketGroups = [/* new market group array */]
viewModel.updateMarketGroups(newMarketGroups)
```

### Programmatic Selection

```swift
// Select a specific market group
viewModel.selectMarketGroup(id: "over_under")

// Clear selection
viewModel.clearSelection()

// Select first available market group
viewModel.selectFirstAvailableMarketGroup()
```

### State Management

```swift
// Set loading state
viewModel.setLoading(true)

// Enable/disable the entire component
viewModel.setEnabled(false)

// Set custom visual state
viewModel.setVisualState(.empty)
```

### Scrolling Control

```swift
// Scroll to a specific tab
tabSelectorView.scrollToTab(id: "target_tab", animated: true)

// Get current scroll progress (0.0 - 1.0)
let progress = tabSelectorView.scrollProgress
```

## Component Architecture

### Container Data Model

```swift
public struct MarketGroupSelectorTabData: Equatable, Hashable {
    public let id: String                                    // Unique identifier
    public let marketGroups: [MarketGroupTabItemData]        // Array of tab items
    public let selectedMarketGroupId: String?                // Currently selected tab
    public let visualState: MarketGroupSelectorTabVisualState
}
```

### Visual State Enum

```swift
public enum MarketGroupSelectorTabVisualState: Equatable {
    case idle               // Normal state with tabs available
    case loading            // Loading state while fetching market groups
    case empty              // No market groups available
    case disabled           // All tabs disabled/non-interactive
}
```

### Selection Event Model

```swift
public struct MarketGroupSelectionEvent: Equatable {
    public let selectedId: String              // Newly selected tab ID
    public let previouslySelectedId: String?   // Previously selected tab ID
    public let timestamp: Date                 // When the selection occurred
}
```

### Protocol Interface

```swift
public protocol MarketGroupSelectorTabViewModelProtocol {
    // Content publishers
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> { get }
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> { get }
    
    // State management
    var visualStatePublisher: AnyPublisher<MarketGroupSelectorTabVisualState, Never> { get }
    var currentVisualState: MarketGroupSelectorTabVisualState { get }
    
    // Selection events
    var selectionEventPublisher: AnyPublisher<MarketGroupSelectionEvent, Never> { get }
    
    // Actions
    func selectMarketGroup(id: String)
    func updateMarketGroups(_ marketGroups: [MarketGroupTabItemData])
    func addMarketGroup(_ marketGroup: MarketGroupTabItemData)
    func removeMarketGroup(id: String)
    func updateMarketGroup(_ marketGroup: MarketGroupTabItemData)
    
    // Convenience methods
    func clearSelection()
    func selectFirstAvailableMarketGroup()
    func setEnabled(_ enabled: Bool)
    func setLoading(_ loading: Bool)
}
```

## Layout and Styling

### Constants

- **Horizontal Padding**: 16pt
- **Vertical Padding**: 8pt
- **Tab Item Spacing**: 8pt
- **Corner Radius**: 8pt
- **Animation Duration**: 0.3s
- **Minimum Height**: 50pt

### Scrolling Behavior

- **Horizontal Only**: Vertical scrolling disabled
- **Auto-scroll**: Automatically scrolls to selected tabs
- **No Scroll Indicators**: Clean appearance without scroll bars
- **Content Inset**: Managed automatically

## Accessibility

### VoiceOver Support

- **Container**: Not an accessibility element itself
- **Navigation**: Properly ordered tab item accessibility elements
- **States**: Each tab item announces its current state
- **Selection**: Clear feedback when selection changes

### Dynamic Type Support

All text elements respect user's preferred text size through StyleProvider integration.

## Available Mock Configurations

### Predefined Configurations

```swift
MockMarketGroupSelectorTabViewModel.standardSportsMarkets    // Standard 4-tab layout
MockMarketGroupSelectorTabViewModel.limitedMarkets           // Minimal 2-tab layout  
MockMarketGroupSelectorTabViewModel.mixedStateMarkets        // Includes disabled tabs
MockMarketGroupSelectorTabViewModel.emptyMarkets             // Empty state
MockMarketGroupSelectorTabViewModel.loadingMarkets           // Loading state
MockMarketGroupSelectorTabViewModel.disabledMarkets          // All tabs disabled
```

### Custom Factory

```swift
MockMarketGroupSelectorTabViewModel.customMarkets(
    id: "unique_id",
    marketGroups: [/* your market groups */],
    selectedMarketGroupId: "selected_tab_id"
)
```

### Collections for Testing

```swift
MockMarketGroupSelectorTabViewModel.allDemoConfigurations   // All predefined configs
```

## Integration with Individual Tab Items

This component automatically creates and manages `MarketGroupTabItemView` instances:

- **Automatic Creation**: Creates tab item views from data models
- **Selection Coordination**: Ensures mutual exclusivity of selection
- **Event Forwarding**: Routes individual tap events to container selection logic
- **State Synchronization**: Keeps individual item states in sync with container state

## Performance Considerations

### Memory Management

- **Automatic Cleanup**: Removes and deallocates tab views when updating content
- **Reference Management**: Properly manages view model references to prevent retain cycles
- **Combine Subscriptions**: Automatically manages cancellables for memory safety

### Rendering Optimization

- **Lazy Loading**: Tab items created only when needed
- **Smooth Animations**: Uses optimized animation blocks for state transitions
- **Scroll Performance**: Efficient horizontal scrolling with proper content sizing

## Error Handling

### Selection Validation

- **Disabled Tabs**: Prevents selection of disabled market groups
- **Missing Tabs**: Gracefully handles attempts to select non-existent tabs
- **State Consistency**: Maintains consistent selection state even with dynamic content

### Edge Cases

- **Empty Arrays**: Handles empty market group arrays gracefully
- **Duplicate IDs**: Automatically handles duplicate market group IDs
- **Rapid Updates**: Manages rapid state changes without visual glitches

## SwiftUI Preview Support

The component includes comprehensive SwiftUI previews for development:

```swift
#if DEBUG
MarketGroupSelectorTabView_Previews.previews
#endif
```

Includes previews for:
- Standard market configurations
- Mixed state demonstrations
- Loading and empty states
- Different market group combinations

## Best Practices

### Selection Management

```swift
// Good: Use selection events for coordination
viewModel.selectionEventPublisher
    .sink { event in
        updateContentForMarketGroup(event.selectedId)
    }
    .store(in: &cancellables)

// Avoid: Directly accessing current selection repeatedly
// let currentSelection = viewModel.currentSelectedMarketGroupId
```

### Dynamic Updates

```swift
// Good: Use atomic updates for multiple changes
let newMarketGroups = buildNewMarketGroupArray()
viewModel.updateMarketGroups(newMarketGroups)

// Avoid: Multiple individual updates
// viewModel.addMarketGroup(group1)
// viewModel.addMarketGroup(group2)  // Creates multiple animations
```

### State Transitions

```swift
// Good: Use convenience methods for common patterns
viewModel.setLoading(true)
loadMarketGroups { groups in
    viewModel.updateMarketGroups(groups)
    viewModel.setLoading(false)
    viewModel.selectFirstAvailableMarketGroup()
}
``` 
