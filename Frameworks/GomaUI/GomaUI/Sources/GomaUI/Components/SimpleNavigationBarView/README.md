# SimpleNavigationBarView

A simple navigation bar with back button and optional centered title.

## Overview

SimpleNavigationBarView provides a clean, consistent navigation bar for screens that need basic back navigation with an optional centered title. It features a back button with chevron icon (and optional text label), a centered title that properly truncates for long text, and a bottom separator line. The component supports style customization for special cases like dark overlays.

## Component Relationships

### Used By (Parents)
- Detail screens
- Settings screens
- Modal presentations
- Transaction history screens

### Uses (Children)
- None (leaf component)

## Features

- Back button with chevron icon
- Optional back button text label
- Optional centered title with truncation
- Title respects back button space
- Bottom separator line
- Custom style support (dark overlay, etc.)
- 44pt minimum touch target
- Callback-based navigation
- Immutable after initialization

## Usage

```swift
// Icon only
let navBar = SimpleNavigationBarView(
    viewModel: MockSimpleNavigationBarViewModel.iconOnly
)

// With back text and title
let fullNavBar = SimpleNavigationBarView(
    viewModel: MockSimpleNavigationBarViewModel.withBackTextAndTitle
)

// Custom view model
let viewModel = MockSimpleNavigationBarViewModel(
    backButtonText: "Back",
    title: "Transaction History",
    onBackTapped: { [weak self] in
        self?.coordinator?.popViewController()
    }
)
let customNavBar = SimpleNavigationBarView(viewModel: viewModel)

// Apply dark overlay style
navBar.setCustomization(.darkOverlay())

// Update title dynamically
navBar.updateTitle("New Title")
```

## Data Model

```swift
protocol SimpleNavigationBarViewModelProtocol {
    var backButtonText: String? { get }      // nil = icon only
    var title: String? { get }               // nil = no title
    var showBackButton: Bool { get }         // false = title only
    var onBackTapped: () -> Void { get }     // navigation callback
}

struct SimpleNavigationBarStyle: Equatable {
    let backgroundColor: UIColor
    let textColor: UIColor
    let iconColor: UIColor
    let separatorColor: UIColor

    static func defaultStyle() -> SimpleNavigationBarStyle
    static func darkOverlay() -> SimpleNavigationBarStyle
}
```

## Styling

StyleProvider properties used (default style):
- `StyleProvider.Color.backgroundTertiary` - bar background
- `StyleProvider.Color.textPrimary` - text color
- `StyleProvider.Color.iconPrimary` - back icon tint
- `StyleProvider.Color.separatorLine` - separator color
- `StyleProvider.fontWith(type: .bold, size: 12)` - back label font
- `StyleProvider.fontWith(type: .bold, size: 16)` - title font

Layout constants:
- Bar height: 56pt
- Back button container height: 44pt (iOS HIG minimum)
- Back icon size: 20pt
- Back icon leading: 16pt
- Back label spacing: 6pt
- Title horizontal padding: 16pt
- Separator height: 1pt

Title behavior:
- Centered by default (priority 750)
- Shifts left for long titles
- Never overlaps back button (priority 1000)
- Truncates with trailing ellipsis

Built-in styles:
- `.defaultStyle()` - Standard theme colors
- `.darkOverlay()` - White text on transparent (for image overlays)

## Mock ViewModels

Available presets:
- `.iconOnly` - Chevron icon only
- `.withBackText` - Icon + "Back" text
- `.withTitle` - Icon + centered title
- `.withBackTextAndTitle` - Icon + text + title
- `.titleOnly` - Title only, no back button
- `.longTitle` - Long title for truncation testing

Parameters:
- `backButtonText: String?` - Optional text next to icon
- `title: String?` - Optional centered title
- `showBackButton: Bool` - Whether to show back button
- `onBackTapped: () -> Void` - Navigation callback
