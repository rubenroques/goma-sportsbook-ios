# PromotionItemView

A selectable promotion category pill for filtering promotional content.

## Overview

PromotionItemView displays a rounded pill button used for selecting promotion categories (e.g., "Welcome", "Sports", "Casino", "Bonuses"). It supports selected/unselected visual states with animated transitions and is typically used within a PromotionSelectorBarView for category-based filtering.

## Component Relationships

### Used By (Parents)
- `PromotionSelectorBarView`

### Uses (Children)
- None (leaf component)

## Features

- Title label centered in pill
- Selected/unselected visual states
- Animated state transitions (0.2s)
- Read-only mode support
- Category metadata for accessibility
- Tap gesture for selection
- Pill-shaped container (fully rounded)
- Reactive updates via Combine publishers

## Usage

```swift
let itemData = PromotionItemData(
    id: "sports",
    title: "Sports",
    isSelected: true,
    category: "sportsbook"
)
let viewModel = MockPromotionItemViewModel(promotionItemData: itemData)
let itemView = PromotionItemView(viewModel: viewModel)

// Handle selection
itemView.onPromotionSelected = {
    filterPromotions(by: "sports")
}

// Update title
viewModel.updateTitle("All Sports")

// Update category
viewModel.updateCategory("featured")
```

## Data Model

```swift
struct PromotionItemData: Equatable, Hashable {
    let id: String
    let title: String
    let isSelected: Bool
    let category: String?
}

struct PromotionItemDisplayState: Equatable {
    let promotionItemData: PromotionItemData
}

protocol PromotionItemViewModelProtocol {
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

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - unselected background
- `StyleProvider.Color.highlightPrimary` - selected background
- `StyleProvider.Color.textPrimary` - unselected text color
- White (`.white`) - selected text color
- `StyleProvider.fontWith(type: .medium, size: 14)` - title font

Layout constants:
- Minimum height: 40pt
- Horizontal padding: 16pt
- Vertical padding: 10pt
- Corner radius: 20pt (fully rounded)

Visual states:
- **Selected**: Highlight primary background, white text
- **Unselected**: Secondary background, primary text
- **Transition**: 0.2s animation duration

Accessibility:
- Category is combined with title for accessibility label
- Format: "Title, Category"

## Mock ViewModels

Available presets:
- `MockPromotionItemViewModel(promotionItemData:, isReadOnly:)` - Custom configuration
- Selected example: `PromotionItemData(id: "1", title: "Welcome", isSelected: true)`
- Unselected example: `PromotionItemData(id: "2", title: "Sports", isSelected: false)`
