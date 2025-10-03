# PromotionSelectorBarView

A horizontal scrolling container for `PromotionItemView` components, following the GomaUI MVVM architecture pattern.

## Overview

`PromotionSelectorBarView` provides a horizontal scrolling interface for promotion category selection. It manages multiple `PromotionItemView` instances and handles selection state coordination across all items.

## Visual Structure

```
┌─────────────────────────────────────────────────┐
│ [Welcome] [Sports] [Casino] [Bonuses] → → →    │
└─────────────────────────────────────────────────┘
```

- **Scroll View**: Horizontal scrolling container
- **Stack View**: Manages horizontal arrangement of promotion items
- **Promotion Items**: Individual `PromotionItemView` components

## Protocols

### PromotionSelectorBarViewModelProtocol
Defines the interface for managing the selector bar state and actions:

```swift
public protocol PromotionSelectorBarViewModelProtocol {
    var displayStatePublisher: AnyPublisher<PromotionSelectorBarDisplayState, Never> { get }
    var selectionEventPublisher: AnyPublisher<PromotionSelectionEvent, Never> { get }
    
    func selectPromotion(id: String)
    func updatePromotionItems(_ items: [PromotionItemData])
    func updateSelectedPromotion(_ id: String?)
    func updateVisibility(_ isVisible: Bool)
    func updateUserInteraction(_ isEnabled: Bool)
    
    func getCurrentDisplayState() -> PromotionSelectorBarDisplayState
    func isPromotionSelected(_ id: String) -> Bool
    func getSelectedPromotionId() -> String?
}
```

## Data Models

### PromotionSelectorBarData
```swift
public struct PromotionSelectorBarData: Equatable, Hashable {
    public let id: String
    public let promotionItems: [PromotionItemData]
    public let selectedPromotionId: String?
    public let isScrollEnabled: Bool
    public let allowsVisualStateChanges: Bool
}
```

### PromotionSelectionEvent
```swift
public struct PromotionSelectionEvent: Equatable {
    public let selectedId: String
    public let previouslySelectedId: String?
    public let timestamp: Date
}
```

## Usage Examples

### Basic Usage
```swift
let items = [
    PromotionItemData(id: "1", title: "Welcome", isSelected: true),
    PromotionItemData(id: "2", title: "Sports", isSelected: false),
    PromotionItemData(id: "3", title: "Casino", isSelected: false)
]

let barData = PromotionSelectorBarData(
    id: "main", 
    promotionItems: items, 
    selectedPromotionId: "1"
)

let viewModel = MockPromotionSelectorBarViewModel(barData: barData)
let selectorBar = PromotionSelectorBarView(viewModel: viewModel)

selectorBar.onPromotionSelected = { selectedId in
    print("Selected promotion: \(selectedId)")
}
```

### Read-Only Mode
```swift
let barData = PromotionSelectorBarData(
    id: "readonly",
    promotionItems: items,
    selectedPromotionId: "1",
    allowsVisualStateChanges: false
)
```

### Disabled Scrolling
```swift
let barData = PromotionSelectorBarData(
    id: "fixed",
    promotionItems: items,
    selectedPromotionId: "1",
    isScrollEnabled: false
)
```

## Architecture

### MVVM Pattern
- **View**: `PromotionSelectorBarView` - Manages UI layout and user interactions
- **ViewModel**: `PromotionSelectorBarViewModelProtocol` - Coordinates state across all promotion items
- **Model**: `PromotionSelectorBarData` - Contains configuration and item data

### State Management
- Centralized selection state management
- Reactive updates via Combine publishers
- Event-driven architecture for selection handling

### Component Integration
- Automatically creates and manages `PromotionItemView` instances
- Coordinates selection state across all items
- Handles individual item tap events

## Layout Specifications

- **Minimum Height**: 60pt
- **Horizontal Padding**: 16pt
- **Item Spacing**: 12pt
- **Animation Duration**: 0.3s

## Features

### Horizontal Scrolling
- Smooth horizontal scrolling for many items
- Scroll indicator can be disabled

### Selection Management
- Single selection mode (only one item can be selected)
- Automatic state coordination across items
- Selection event publishing

### Visual States
- Supports visibility toggling
- User interaction can be disabled
- Read-only mode prevents state changes

## Styling

- Uses `StyleProvider` for consistent theming
- Clean, simple design without visual effects
- Automatic item state management

## Accessibility

- Proper accessibility support through individual `PromotionItemView` components
- Clear selection state indication
- Touch target optimization

## Integration

This component is designed to work with the existing GomaUI architecture and follows the same patterns as `PillSelectorBarView`. It can be easily integrated into promotion screens that need category filtering or navigation.
