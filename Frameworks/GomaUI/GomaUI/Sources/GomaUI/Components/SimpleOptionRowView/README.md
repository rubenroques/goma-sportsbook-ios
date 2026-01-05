# SimpleOptionRowView

A single-selection option row with title and radio button indicator.

## Overview

SimpleOptionRowView displays a horizontally-arranged row with a title label on the left and a radio button indicator on the right. The radio button shows a filled dot when selected. This component is used as a child view within SelectOptionsView for building single-selection option lists in settings, preferences, and filter interfaces.

## Component Relationships

### Used By (Parents)
- `SelectOptionsView`

### Uses (Children)
- None (leaf component)

## Features

- Title label on left side
- Radio button indicator on right side
- Selected/unselected visual states
- Filled dot indicator when selected
- Tap gesture on entire row
- Option selection callback
- Configurable via SortOption data

## Usage

```swift
let option = SortOption(
    id: "notifications",
    icon: nil,
    title: "Enable notifications",
    count: -1,
    iconTintChange: false
)
let viewModel = MockSimpleOptionRowViewModel(option: option)
let rowView = SimpleOptionRowView(viewModel: viewModel)
rowView.isSelected = true
rowView.configure()

// Handle selection
rowView.didTapOption = { selectedOption in
    handleSelection(selectedOption.id)
}
```

## Data Model

```swift
protocol SimpleOptionRowViewModelProtocol {
    var option: SortOption { get }
}

// SortOption is defined in SharedModels
struct SortOption {
    let id: String
    let icon: String?
    let title: String
    let count: Int
    let iconTintChange: Bool
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - row background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.highlightPrimary` - selected radio button fill/border
- `StyleProvider.Color.iconSecondary` - unselected radio button border
- `StyleProvider.Color.allWhite` - radio button background, selected dot
- `StyleProvider.fontWith(type: .regular, size: 12)` - title font

Layout constants:
- Title leading: 0pt (no padding)
- Radio button trailing: 0pt (no padding)
- Vertical padding: 8pt
- Radio button size: 20pt
- Selected dot size: 12pt
- Radio button border width: 2pt
- Radio button corner radius: 10pt (circular)

Radio button states:
- Unselected: white background, gray border
- Selected: orange fill, orange border, white dot center

## Mock ViewModels

Available presets:
- `.sampleSelected` - "Enable notifications" option
- `.sampleUnselected` - "Receive personalized offers" option

Parameters:
- `option: SortOption` - The option data to display
