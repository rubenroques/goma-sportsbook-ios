# AdaptiveTabBarView

A dynamic tab bar supporting multiple tab bar configurations with animated transitions between them.

## Overview

AdaptiveTabBarView enables switching between different tab bar layouts (e.g., Sports vs Casino) with rich animated transitions. It maintains navigation history for proper back navigation and supports multiple background modes including blur effects.

## Component Relationships

### Used By (Parents)
- None (standalone component, typically used as main app tab bar)

### Uses (Children)
- None (internally uses AdaptiveTabBarItemView for tab items)

## Features

- Multiple tab bar configurations (home, casino)
- Navigation history tracking for back navigation direction
- Five animation types for tab bar switching
- Three background modes: solid, blur, transparent
- Reactive state updates via Combine publishers
- Tab selection callbacks for parent integration
- Fixed 52pt height

## Usage

```swift
let viewModel = MockAdaptiveTabBarViewModel.defaultMock
let tabBarView = AdaptiveTabBarView(viewModel: viewModel)

// Configure animation type
tabBarView.animationType = .slideLeftToRight

// Configure background mode
tabBarView.backgroundMode = .blur

// Handle tab selection
tabBarView.onTabSelected = { tabItem in
    print("Selected: \(tabItem.title)")
}
```

## Data Model

```swift
protocol AdaptiveTabBarViewModelProtocol {
    var displayStatePublisher: AnyPublisher<AdaptiveTabBarDisplayState, Never> { get }
    func selectTab(itemID: TabItemIdentifier, inTabBarID: TabBarIdentifier)
}

struct AdaptiveTabBarDisplayState {
    let tabBars: [TabBarDisplayData]
    let activeTabBarID: TabBarIdentifier
}

enum TabBarIdentifier: String {
    case home, casino
}

enum TabBarAnimationType {
    case horizontalFlip      // 3D horizontal flip
    case verticalCube        // 3D cube rotation
    case slideLeftToRight    // Direction-aware slide
    case modernMorphSlide    // Blur + scale + slide
    case none                // Instant switch
}

enum TabBarBackgroundMode {
    case solid       // StyleProvider.Color.backgroundPrimary
    case blur        // UIBlurEffect with .systemUltraThinMaterial
    case transparent // Clear background
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - solid background color
- `StyleProvider.Color.highlightPrimary` - active tab item color
- `StyleProvider.Color.iconSecondary` - inactive tab item color
- `StyleProvider.fontWith(type: .semibold, size: 12)` - tab item title font

## Mock ViewModels

Available presets:
- `.defaultMock` - home and casino tab bars with Sports, Live, My Bets, Search, Casino tabs
