# FilterOptionCell

A collection view cell displaying a filter option with icon and title.

## Overview

FilterOptionCell is a UICollectionViewCell that displays a filter option item with an icon on the left and title text. It's used within filter bar collection views to show available filter options like sports, leagues, or sort options.

## Component Relationships

### Used By (Parents)
- `GeneralFilterBarView` - filter options in horizontal collection

### Uses (Children)
- None (leaf cell component)

## Features

- Horizontal layout with icon and title
- 22pt icon size
- White background with 21pt corner radius
- 8pt spacing between icon and title
- Bold 12pt title font
- Primary text color
- 10pt vertical padding, 8pt horizontal padding

## Usage

```swift
// Register cell
collectionView.register(FilterOptionCell.self, forCellWithReuseIdentifier: "FilterOptionCell")

// Configure in cellForItemAt
let cell = collectionView.dequeueReusableCell(
    withReuseIdentifier: "FilterOptionCell",
    for: indexPath
) as! FilterOptionCell

let viewModel = FilterOptionCellViewModel(filterOptionItem: item)
cell.configure(with: viewModel)
```

## Data Model

```swift
class FilterOptionCellViewModel {
    let filterOptionItem: FilterOptionItem

    init(filterOptionItem: FilterOptionItem)
}

struct FilterOptionItem {
    let type: FilterOptionType
    let title: String
    let icon: String
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - icon tint
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.fontWith(type: .bold, size: 12)` - title font

Layout constants:
- Container corner radius: 21pt
- Container background: white
- Icon size: 22pt
- Stack spacing: 8pt
- Vertical padding: 10pt
- Horizontal padding: 8pt

## Mock ViewModels

No dedicated mock presets - use FilterOptionCellViewModel directly with FilterOptionItem data.
