# ActionRowView

A generic tappable row component for menu items, buttons, and action navigation.

## Overview

ActionRowView provides a flexible row layout commonly used in profile menus, settings screens, and action lists. It supports leading icons, titles, subtitles, trailing icons, and customizable background colors with tap feedback animation.

## Component Relationships

### Used By (Parents)
- `ProfileMenuListView` - displays rows in profile/settings menus

### Uses (Children)
- None (leaf component)

## Features

- Leading icon with system/bundle image support
- Title and optional subtitle labels
- Configurable trailing icon (chevron for navigation, custom icons)
- Two row types: navigation (with chevron) and action (no chevron)
- Custom background color support with automatic text contrast adjustment
- Tap feedback animation with scale effect
- Tappable/non-tappable states
- Fixed 48pt height for consistent layout

## Usage

```swift
let item = ActionRowItem(
    icon: "bell",
    title: "Notifications",
    type: .navigation,
    action: .notifications
)

let rowView = ActionRowView()
rowView.configure(with: item) { tappedItem in
    print("Tapped: \(tappedItem.title)")
}
```

## Data Model

```swift
struct ActionRowItem: Identifiable, Equatable, Codable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String?
    let type: ActionRowItemType  // .navigation or .action
    let action: ActionRowAction
    let trailingIcon: String?
    let isTappable: Bool
}

enum ActionRowItemType: String, Codable {
    case navigation  // Shows chevron by default
    case action      // No default trailing icon
}

enum ActionRowAction: String, Codable {
    case notifications, transactionHistory, changeLanguage
    case responsibleGaming, helpCenter, changePassword
    case logout, promotions, bonus, custom
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - default container background
- `StyleProvider.Color.textPrimary` - title and subtitle text color
- `StyleProvider.Color.highlightPrimary` - icon tint colors
- `StyleProvider.Color.buttonTextPrimary` - text color on custom backgrounds
- `StyleProvider.fontWith(type: .bold, size: 12)` - title font
- `StyleProvider.fontWith(type: .regular, size: 12)` - subtitle font

## Mock ViewModels

This component uses `ActionRowItem` structs directly without a dedicated mock view model. Create items inline for previews and testing.
