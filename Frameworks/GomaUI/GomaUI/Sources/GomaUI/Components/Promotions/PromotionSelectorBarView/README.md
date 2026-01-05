# PromotionSelectorBarView

A horizontally scrollable bar containing selectable promotion category items.

## Overview

PromotionSelectorBarView displays a horizontal scrolling collection of PromotionItemView components for filtering promotional content by category. It manages selection state, supports both interactive and read-only modes, and preserves scroll position during selection updates. The component is commonly used at the top of promotion list screens.

## Component Relationships

### Used By (Parents)
- Promotion screens
- Bonus listing pages
- Featured content filters

### Uses (Children)
- `PromotionItemView`

## Features

- Horizontal scrolling with UIScrollView
- Dynamic promotion item creation
- Single selection management
- Selection event publishing
- Scroll position preservation during selection updates
- Read-only mode (visual state preserved, no selection changes)
- Visibility and interaction control
- External selection update API
- Reactive updates via Combine publishers

## Usage

```swift
let items = [
    PromotionItemData(id: "welcome", title: "Welcome", isSelected: true),
    PromotionItemData(id: "sports", title: "Sports", isSelected: false),
    PromotionItemData(id: "casino", title: "Casino", isSelected: false)
]
let barData = PromotionSelectorBarData(
    id: "promo_bar",
    promotionItems: items,
    selectedPromotionId: "welcome"
)
let viewModel = MockPromotionSelectorBarViewModel(barData: barData)
let selectorBar = PromotionSelectorBarView(viewModel: viewModel)

// Handle selection
selectorBar.onPromotionSelected = { promotionId in
    filterPromotions(by: promotionId)
}

// Update bar data externally
selectorBar.updateBarData(newBarData)

// Update selection without recreating views
selectorBar.updateSelection("casino")
```

## Data Model

```swift
struct PromotionSelectorBarData: Equatable, Hashable {
    let id: String
    let promotionItems: [PromotionItemData]
    let selectedPromotionId: String?
    let isScrollEnabled: Bool
    let allowsVisualStateChanges: Bool  // false = read-only
}

struct PromotionSelectionEvent: Equatable {
    let selectedId: String
    let previouslySelectedId: String?
    let timestamp: Date
}

struct PromotionSelectorBarDisplayState: Equatable {
    let barData: PromotionSelectorBarData
    let isVisible: Bool
    let isUserInteractionEnabled: Bool
}

protocol PromotionSelectorBarViewModelProtocol {
    var displayStatePublisher: AnyPublisher<PromotionSelectorBarDisplayState, Never> { get }
    var selectionEventPublisher: AnyPublisher<PromotionSelectionEvent, Never> { get }

    func selectPromotion(id: String)
    func updatePromotionItems(_ items: [PromotionItemData])
    func updateSelectedPromotion(_ id: String?)
    func updateVisibility(_ isVisible: Bool)
    func updateUserInteraction(_ isEnabled: Bool)
    func updateBarData(_ barData: PromotionSelectorBarData)
    func getCurrentDisplayState() -> PromotionSelectorBarDisplayState
    func isPromotionSelected(_ id: String) -> Bool
    func getSelectedPromotionId() -> String?
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - selected item background/border
- `StyleProvider.Color.backgroundSecondary` - unselected item background
- `StyleProvider.Color.backgroundBorder` - unselected item border
- `StyleProvider.Color.textPrimary` - unselected text
- White (`.white`) - selected text

Layout constants:
- Horizontal padding: 16pt
- Item spacing: 12pt
- Minimum height: 60pt
- Animation duration: 0.3s

Selection update modes:
- **Full rebuild**: When promotion items change
- **State-only update**: When only selection changes (preserves scroll position)

Title localization:
- Item titles are passed through LocalizationProvider
- Lowercase conversion for key lookup

## Mock ViewModels

Available presets:
- `MockPromotionSelectorBarViewModel(barData:)` - Custom configuration

Example configurations:
```swift
// Basic selector bar
let basicItems = [
    PromotionItemData(id: "1", title: "Welcome", isSelected: true),
    PromotionItemData(id: "2", title: "Sports", isSelected: false),
    PromotionItemData(id: "3", title: "Casino", isSelected: false),
    PromotionItemData(id: "4", title: "Bonuses", isSelected: false)
]

// Extended selector bar (scrollable)
let extendedItems = [
    // ... add more items for horizontal scrolling
]
```
