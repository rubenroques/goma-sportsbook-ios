# MarketGroupSelectorTabView

A horizontal scrollable tab bar for market group selection with multiple layout modes.

## Overview

MarketGroupSelectorTabView provides a horizontal scrollable collection of market group tabs for sports betting interfaces. It supports automatic (content-sized) and stretch (fill width) layout modes, customizable background colors for the bar and individual items, and efficient tab management with animated selection transitions.

## Component Relationships

### Used By (Parents)
- None (standalone tab bar component)

### Uses (Children)
- `MarketGroupTabItemView` - individual tab items

## Features

- Horizontal scrolling tab collection
- Two layout modes: automatic (fill based on content) and stretch (fill equally)
- Animated selection transitions with haptic feedback
- Auto-scroll to selected tab
- Customizable bar background color
- Customizable item idle/selected background colors
- Pluggable image resolver for tab icons
- Efficient tab state management (only updates changed items)
- Loading and empty state support
- Selection event publisher for analytics
- Configure method for cell reuse
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockMarketGroupSelectorTabViewModel.standardSportsMarkets
let tabsView = MarketGroupSelectorTabView(
    viewModel: viewModel,
    layoutMode: .automatic,
    barBackgroundColor: StyleProvider.Color.backgroundPrimary,
    itemIdleBackgroundColor: StyleProvider.Color.backgroundPrimary,
    itemSelectedBackgroundColor: StyleProvider.Color.backgroundPrimary
)

// Select a market group programmatically
viewModel.selectMarketGroup(id: "over_under")

// Update market groups dynamically
viewModel.updateMarketGroups(newMarketGroups)

// Scroll to specific tab
tabsView.scrollToTab(id: "double_chance", animated: true)

// Get scroll progress (0.0 - 1.0)
let progress = tabsView.scrollProgress
```

## Data Model

```swift
enum MarketGroupSelectorTabLayoutMode {
    case automatic  // Tabs sized by content
    case stretch    // Tabs fill available width equally
}

struct MarketGroupSelectorTabData: Equatable, Hashable {
    let id: String
    let marketGroups: [MarketGroupTabItemData]
    let selectedMarketGroupId: String?
}

struct MarketGroupSelectionEvent: Equatable {
    let selectedId: String
    let previouslySelectedId: String?
}

protocol MarketGroupSelectorTabViewModelProtocol {
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> { get }
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> { get }
    var selectionEventPublisher: AnyPublisher<MarketGroupSelectionEvent, Never> { get }
    var currentSelectedMarketGroupId: String? { get }
    var currentMarketGroups: [MarketGroupTabItemData] { get }

    func selectMarketGroup(id: String)
    func updateMarketGroups(_ marketGroups: [MarketGroupTabItemData])
    func addMarketGroup(_ marketGroup: MarketGroupTabItemData)
    func removeMarketGroup(id: String)
    func updateMarketGroup(_ marketGroup: MarketGroupTabItemData)
    func clearSelection()
    func selectFirstAvailableMarketGroup()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - default bar and item background
- `StyleProvider.Color.highlightPrimary` - loading indicator color
- `StyleProvider.Color.textSecondary` - empty state text color
- `StyleProvider.fontWith(type: .regular, size: 14)` - empty state font

Layout constants:
- Horizontal padding: 16pt
- Vertical padding: 8pt
- Tab item spacing: 1pt
- Corner radius: 8pt
- Minimum height: 42pt
- Animation duration: 0.3s

## Mock ViewModels

Available presets:
- `.standardSportsMarkets` - 1x2, Double Chance, Over/Under, Another market (1x2 selected)
- `.limitedMarkets` - 1x2 and Over/Under only
- `.mixedStateMarkets` - includes unavailable market
- `.emptyMarkets` - no market groups
- `.loadingMarkets` - loading state
- `.disabledMarkets` - no selection
- `.marketCategoryTabs` - All, BetBuilder, Popular, Sets with icons and badges
- `.customMarkets(id:marketGroups:selectedMarketGroupId:)` - fully customizable
