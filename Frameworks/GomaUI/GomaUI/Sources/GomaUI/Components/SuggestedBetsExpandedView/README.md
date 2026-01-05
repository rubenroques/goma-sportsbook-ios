# SuggestedBetsExpandedView

A collapsible carousel of suggested match betting cards with gradient styling.

## Overview

SuggestedBetsExpandedView displays an expandable/collapsible section containing horizontally pageable match betting cards using TallOddsMatchCardView. It features a gradient header with an icon, title, and expand/collapse chevron. The content area shows one match card at a time with a page control indicator. The component syncs outcome selections with the betslip for visual consistency.

## Component Relationships

### Used By (Parents)
- Betslip screens
- Match detail screens

### Uses (Children)
- `TallOddsMatchCardView` (via internal SuggestedBetsMatchCardCell)
- `GradientView` (for container and header backgrounds)

## Features

- Collapsible gradient header with icon and title
- Horizontally paging UICollectionView (one card at a time)
- Page control indicator with tap-to-select
- Animated expand/collapse with chevron rotation
- Selected outcome synchronization from betslip
- Custom clear background for match cards
- Visibility state control
- Lazy content loading on first expand
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockSuggestedBetsExpandedViewModel.demo
let suggestedBetsView = SuggestedBetsExpandedView(viewModel: viewModel)

// Toggle expanded state
viewModel.toggleExpanded()

// Navigate to page
viewModel.didScrollToPage(2)

// Sync selected outcomes from betslip
viewModel.updateSelectedOutcomeIds(["outcome1", "outcome2"])

// Update match cards dynamically
viewModel.updateMatches(newMatchCardViewModels)

// Reconfigure for reuse
suggestedBetsView.configure(with: newViewModel)
```

## Data Model

```swift
struct SuggestedBetsSectionState: Equatable {
    let title: String
    let isExpanded: Bool
    let currentPageIndex: Int
    let totalPages: Int
    let isVisible: Bool
}

protocol SuggestedBetsExpandedViewModelProtocol: AnyObject {
    // State
    var displayStatePublisher: AnyPublisher<SuggestedBetsSectionState, Never> { get }

    // Child match cards
    var matchCardViewModelsPublisher: AnyPublisher<[TallOddsMatchCardViewModelProtocol], Never> { get }
    var matchCardViewModels: [TallOddsMatchCardViewModelProtocol] { get }

    // Selection sync
    var selectedOutcomeIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    var selectedOutcomeIds: Set<String> { get }

    // Actions
    func toggleExpanded()
    func didScrollToPage(_ index: Int)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundGradient1`, `backgroundGradient2` - container gradient
- `StyleProvider.Color.allWhite` - header gradient start
- `StyleProvider.Color.highlightPrimary` - icon and title color
- `StyleProvider.Color.navBannerActive` - page control active dot
- `StyleProvider.Color.navBanner` - page control inactive dots
- `StyleProvider.fontWith(type: .bold, size: 14)` - title font

Layout constants:
- Header height: 34pt
- Icon size: 16pt
- Chevron size: 18pt
- Collection view height: 152pt
- Page control top spacing: 8pt
- Horizontal padding: 16pt for cards

Icons:
- Bundle "popular_icon" or SF Symbol "flame.fill"
- Bundle "chevron_up_icon"/"chevron_down_icon" or SF Symbols

Gradient:
- Container: horizontal gradient
- Header: horizontal gradient with white start

## Mock ViewModels

Available presets:
- `.demo` - 4 match cards (Premier League, Live, Compact, Bundesliga variants)

Parameters:
- `title: String` - Section title
- `isExpanded: Bool` - Initial expand state
- `isVisible: Bool` - Initial visibility
- `initialPage: Int` - Starting page index
- `matchCardViewModels: [TallOddsMatchCardViewModelProtocol]` - Match cards

Methods:
- `toggleExpanded()` - Toggle expand/collapse
- `didScrollToPage(_ index:)` - Update current page
- `updateMatches(_ matchCardViewModels:)` - Replace match cards
- `updateSelectedOutcomeIds(_ ids:)` - Sync betslip selections
