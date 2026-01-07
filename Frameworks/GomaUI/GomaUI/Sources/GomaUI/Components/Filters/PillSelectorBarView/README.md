# PillSelectorBarView

A horizontally scrollable bar containing selectable pill items for filtering and category selection.

## Overview

PillSelectorBarView displays a horizontal scrolling collection of PillItemView components. It manages selection state, scroll position, and supports both interactive and read-only modes. The bar includes fade overlays at the edges for visual polish and automatically scrolls to selected pills. It's commonly used for sports categories, market filters, and time period selection.

## Component Relationships

### Used By (Parents)
- Filter screens
- Category navigation headers
- Market selection interfaces

### Uses (Children)
- `PillItemView`

## Features

- Horizontal scrolling with UIScrollView
- Dynamic pill creation from data
- Single selection management
- Selection event publishing for analytics
- Scroll to selected pill on selection change
- Read-only mode (visual state preserved, no selection changes)
- Edge fade overlays with gradient masks
- Visibility and interaction control
- Custom pill styling via PillItemCustomization
- Custom background color support
- Haptic feedback on selection
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockPillSelectorBarViewModel.sportsCategories
let selectorBar = PillSelectorBarView(viewModel: viewModel)

// Handle pill selection
selectorBar.onPillSelected = { pillId in
    switch pillId {
    case "football": loadFootballMatches()
    case "basketball": loadBasketballMatches()
    default: loadAllMatches()
    }
}

// Programmatic scrolling
selectorBar.scrollToPillWithId("basketball", animated: true)

// Custom styling
let darkCustomization = PillItemCustomization(
    selectedStyle: PillItemStyle(
        textColor: .white,
        backgroundColor: .systemBlue,
        borderColor: .systemBlue,
        borderWidth: 2.0
    ),
    unselectedStyle: PillItemStyle(
        textColor: .lightGray,
        backgroundColor: .darkGray,
        borderColor: .clear,
        borderWidth: 0.0
    )
)
selectorBar.setPillCustomization(darkCustomization)
selectorBar.setCustomBackgroundColor(.black)

// Read scroll progress (0.0 - 1.0)
let progress = selectorBar.scrollProgress
```

## Data Model

```swift
struct PillSelectorBarData: Equatable, Hashable {
    let id: String
    let pills: [PillData]
    let selectedPillId: String?
    let isScrollEnabled: Bool
    let allowsVisualStateChanges: Bool  // false = read-only
}

struct PillSelectionEvent: Equatable {
    let selectedId: String
    let previouslySelectedId: String?
    let timestamp: Date
}

struct PillSelectorBarDisplayState: Equatable {
    let barData: PillSelectorBarData
    let isVisible: Bool
    let isUserInteractionEnabled: Bool
}

protocol PillSelectorBarViewModelProtocol {
    var displayStatePublisher: AnyPublisher<PillSelectorBarDisplayState, Never> { get }
    var selectionEventPublisher: AnyPublisher<PillSelectionEvent, Never> { get }
    var currentSelectedPillId: String? { get }
    var currentPills: [PillData] { get }

    func selectPill(id: String)
    func updatePills(_ pills: [PillData])
    func addPill(_ pill: PillData)
    func removePill(id: String)
    func updatePill(_ pill: PillData)
    func clearSelection()
    func selectFirstAvailablePill()
    func setVisible(_ visible: Bool)
    func setUserInteractionEnabled(_ enabled: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.navPills` - default bar background
- Custom background via `setCustomBackgroundColor(_:)`
- Pill styling via `setPillCustomization(_:)`

Layout constants:
- Horizontal padding: 16pt (content insets)
- Pill spacing: 12pt
- Minimum height: 60pt
- Animation duration: 0.3s
- Fade overlay width: 16pt

Fade overlays:
- Leading: opaque → transparent (left to right)
- Trailing: transparent → opaque (left to right)
- Uses CAGradientLayer masks for smooth fade effect

Intrinsic content size:
- Width: UIView.noIntrinsicMetric
- Height: max(stack height, 60pt minimum)

## Mock ViewModels

Available presets:
- `.sportsCategories` - All, Football, Basketball, Baseball, Soccer, Tennis with icons
- `.marketFilters` - Popular, Moneyline, Spread, Totals, Player Props, Live
- `.timePeriods` - Today, Tomorrow, This Week, This Month
- `.limitedPills` - Live, Upcoming (scroll disabled)
- `.emptyPills` - Empty state (hidden)
- `.textOnlyPills` - All Sports, My Favorites, Trending, Ending Soon
- `.readOnlyMarketFilters` - Read-only mode with multiple selected states
- `.footballPopularLeagues` - Football, Popular, All, All Popular Leagues
