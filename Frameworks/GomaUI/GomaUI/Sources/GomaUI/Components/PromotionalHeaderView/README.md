# PromotionalHeaderView

A simple header row with icon, title, and optional subtitle for promotional sections.

## Overview

PromotionalHeaderView displays a horizontal row with a leading icon and text content (title and optional subtitle). It's used as a section header for promotional content areas, typically appearing above bonus cards or promotion lists to provide context about the section.

## Component Relationships

### Used By (Parents)
- Promotion section screens
- Home screen bonus sections

### Uses (Children)
- None (leaf component)

## Features

- Leading icon (SF Symbols or custom images)
- Title label (bold)
- Optional subtitle label (regular)
- Horizontal layout with icon-text spacing
- Custom background color support
- Vertical text stacking
- Reactive configuration

## Usage

```swift
let headerData = PromotionalHeaderData(
    id: "promo_header",
    icon: "gift.fill",
    title: "Promotions & Bonuses",
    subtitle: "Check out our latest offers"
)
let viewModel = MockPromotionalHeaderViewModel(headerData: headerData)
let headerView = PromotionalHeaderView(viewModel: viewModel)

// Set custom background
headerView.setCustomBackgroundColor(StyleProvider.Color.backgroundPrimary)

// Update header data
viewModel.updateHeaderData(newHeaderData)
```

## Data Model

```swift
struct PromotionalHeaderData: Equatable, Hashable {
    let id: String
    let icon: String           // SF Symbol name or custom image name
    let title: String
    let subtitle: String?
}

protocol PromotionalHeaderViewModelProtocol {
    func getHeaderData() -> PromotionalHeaderData
    func updateHeaderData(_ newData: PromotionalHeaderData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - icon tint
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.textSecondary` - subtitle text color
- `StyleProvider.fontWith(type: .bold, size: 14)` - title font
- `StyleProvider.fontWith(type: .regular, size: 12)` - subtitle font

Layout constants:
- Icon size: 24pt x 24pt
- Main stack spacing: 8pt
- Text stack spacing: 4pt
- Container padding: 8pt all sides

Icon resolution:
1. First tries SF Symbol (UIImage(systemName:))
2. Falls back to custom image (UIImage(named:))

Text layout:
- Title: Required, multi-line
- Subtitle: Optional, hidden if nil or empty, multi-line

## Mock ViewModels

Available presets:
- `.defaultMock` - "Promotions & Bonuses" with gift.fill icon, no subtitle
- `.noSubtitleMock` - "Welcome Bonus Available!" with gift.fill icon, no subtitle
