# SportSelectorCell

A collection view cell displaying a sport icon, title, and dropdown indicator for sport selection.

## Overview

SportSelectorCell is a UICollectionViewCell that displays a sport filter option with an icon, title, and dropdown arrows. Features a pill-shaped container with highlight border styling. Used within filter bars and sport selection components to allow users to select different sport categories.

## Component Relationships

### Used By (Parents)
- `GeneralFilterBarView` - main filter bar component

### Uses (Children)
- None (leaf component)

## Features

- Sport icon with template rendering
- Title label display
- Dropdown arrow indicator
- Pill-shaped container with border
- Highlight primary border color
- Icon tinting to match theme
- Cell reuse support

## Usage

```swift
// Register cell
collectionView.register(
    SportSelectorCell.self,
    forCellWithReuseIdentifier: "SportSelectorCell"
)

// Configure in cellForItemAt
let cell = collectionView.dequeueReusableCell(
    withReuseIdentifier: "SportSelectorCell",
    for: indexPath
) as! SportSelectorCell

let viewModel = SportSelectorCellViewModel(
    filterOptionItem: FilterOptionItem(
        id: "football",
        title: "Football",
        icon: "football_icon"
    )
)
cell.configure(with: viewModel)
```

## Data Model

```swift
class SportSelectorCellViewModel {
    let filterOptionItem: FilterOptionItem

    init(filterOptionItem: FilterOptionItem)
}

// FilterOptionItem is a shared model used by filter components
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - border color, icon tint, arrows tint
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.fontWith(type: .bold, size: 12)` - title font

Layout constants:
- Container corner radius: 21pt
- Container border width: 2pt
- Stack horizontal spacing: 8pt
- Stack vertical padding: 10pt
- Stack horizontal padding: 8pt
- Icon size: 22pt x 22pt
- Arrows size: 12pt x 16pt

Container:
- White background
- Pill-shaped (corner radius matches height)
- Highlight border

Icons:
- Sport icon: from bundle, template rendering
- Arrows: "selector_icon" from bundle
