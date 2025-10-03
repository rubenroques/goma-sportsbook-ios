# PromotionItemView

A pill-shaped button component designed for promotion category selection, following the GomaUI MVVM architecture pattern.

## Overview

`PromotionItemView` is a reusable UI component that displays a single promotion category as a pill-shaped button. It supports selection states, animations, and integrates seamlessly with the GomaUI design system.

## Visual Structure

```
┌─────────────────────────┐
│    [Promotion Title]    │
└─────────────────────────┘
```

- **Container**: Pill-shaped background with rounded corners
- **Title Label**: Centered text with medium font weight
- **Selection State**: Orange background when selected, light grey when unselected

## Protocols

### PromotionItemViewModelProtocol
Defines the interface for managing promotion item state and actions:

```swift
public protocol PromotionItemViewModelProtocol {
    var idPublisher: AnyPublisher<String, Never> { get }
    var titlePublisher: AnyPublisher<String, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    var categoryPublisher: AnyPublisher<String?, Never> { get }
    
    var isReadOnly: Bool { get }
    
    func selectPromotion()
    func updateTitle(_ title: String)
    func updateCategory(_ category: String?)
}
```

## Data Models

### PromotionItemData
```swift
public struct PromotionItemData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let isSelected: Bool
    public let category: String?
}
```

## Usage Examples

### Basic Usage
```swift
let data = PromotionItemData(id: "1", title: "Welcome", isSelected: true)
let viewModel = MockPromotionItemViewModel(promotionItemData: data)
let promotionItemView = PromotionItemView(viewModel: viewModel)

promotionItemView.onPromotionSelected = {
    print("Promotion item tapped!")
}
```

### With Category
```swift
let data = PromotionItemData(
    id: "2", 
    title: "Sports", 
    isSelected: false, 
    category: "Sports Betting"
)
let viewModel = MockPromotionItemViewModel(promotionItemData: data)
let promotionItemView = PromotionItemView(viewModel: viewModel)
```

## Architecture

### MVVM Pattern
- **View**: `PromotionItemView` - Handles UI rendering and user interactions
- **ViewModel**: `PromotionItemViewModelProtocol` - Manages state and business logic
- **Model**: `PromotionItemData` - Contains data structure

### State Management
- Uses Combine publishers for reactive state updates
- Supports read-only mode to prevent selection changes
- Automatic UI updates when state changes

## Layout Specifications

- **Minimum Height**: 40pt
- **Horizontal Padding**: 16pt
- **Vertical Padding**: 10pt
- **Corner Radius**: 20pt (pill shape)
- **Border Width**: 1pt
- **Animation Duration**: 0.2s

## Styling

### Selected State
- Background: `StyleProvider.Color.highlightPrimary` (Orange)
- Text: White
- Border: `StyleProvider.Color.highlightPrimary`

### Unselected State
- Background: `StyleProvider.Color.backgroundSecondary` (Light Grey)
- Text: `StyleProvider.Color.textPrimary` (Dark)
- Border: `StyleProvider.Color.backgroundBorder`

## Accessibility

- Supports accessibility labels that include category information
- Responds to tap gestures
- Proper contrast ratios in both states

## Integration

This component is designed to work with `PromotionSelectorBarView` to create a horizontal scrolling list of promotion categories, similar to the existing `PillSelectorBarView` pattern.
