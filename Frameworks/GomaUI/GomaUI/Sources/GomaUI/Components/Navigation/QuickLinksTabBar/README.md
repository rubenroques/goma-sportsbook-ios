# QuickLinksTabBar

A horizontal tab bar displaying quick access links with icons and titles.

## Overview

QuickLinksTabBarView displays a horizontal row of quick access links (e.g., Aviator, Virtual, Slots, Crash, Promos) with icons and titles. Each item is equally distributed across the available width. The component is used for quick navigation to popular features or categories, typically placed below the main header or navigation bar.

## Component Relationships

### Used By (Parents)
- Home screens
- Main navigation areas

### Uses (Children)
- `QuickLinkTabBarItemView` (internal helper)

## Features

- Horizontal equal-width distribution
- Icon + title per item
- Multiple link type categories (gaming, sports, account)
- Tap callback with link type
- Fixed height (48pt)
- Secondary background color
- Dynamic item rendering from publisher
- Theme update support
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
let quickLinksBar = QuickLinksTabBarView(viewModel: viewModel)

// Handle quick link selection
quickLinksBar.onQuickLinkSelected = { linkType in
    switch linkType {
    case .aviator: navigateToAviator()
    case .virtual: navigateToVirtual()
    case .slots: navigateToSlots()
    default: break
    }
}

// Update theme if needed
quickLinksBar.updateTheme()

// Change links dynamically
viewModel.updateQuickLinks(newLinks)
```

## Data Model

```swift
enum QuickLinkType: String, Hashable {
    // Gaming
    case aviator, virtual, slots, crash, promos, lite
    // Sports
    case sports, live, football, basketball, tennis, golf
    // Account
    case deposit, withdraw, help, settings, favourites
    // Filter
    case mainFilter
}

struct QuickLinkItem: Equatable, Hashable {
    let type: QuickLinkType
    let title: String
    let icon: UIImage?
}

protocol QuickLinksTabBarViewModelProtocol {
    var quickLinksPublisher: AnyPublisher<[QuickLinkItem], Never> { get }
    var onTabSelected: ((String) -> Void) { get set }

    func didTapQuickLink(type: QuickLinkType)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - bar background

Layout constants:
- Fixed height: 48pt
- Stack spacing: 2pt
- Vertical padding: 2pt
- Distribution: fillEqually

Item styling:
- Handled by QuickLinkTabBarItemView
- Icons from bundle or SF Symbols

## Mock ViewModels

Available presets:
- `.gamingMockViewModel` - Aviator, Virtual, Slots, Crash, Promos (with bundle icons)
- `.sportsMockViewModel` - Football, Basketball, Tennis, Golf (SF Symbols)
- `.accountMockViewModel` - Deposit, Withdraw, Help, Settings (SF Symbols)

Icon sources:
- Gaming: Bundle assets (aviator_quick_link_icon, etc.)
- Sports: SF Symbols (soccerball, basketball, tennisball, figure.golf)
- Account: SF Symbols (arrow.down.circle, arrow.up.circle, etc.)
