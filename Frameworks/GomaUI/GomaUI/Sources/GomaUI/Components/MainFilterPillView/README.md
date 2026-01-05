# MainFilterPillView

A main filter pill button for filter bar interactions with selection counter badge.

## Overview

MainFilterPillView displays a pill-shaped button for accessing the main filter modal in filter bars. It includes a filter icon, localized "Filter" label, action arrow, and an optional badge showing the count of active filter selections. The component is designed to work alongside filter bar items.

## Component Relationships

### Used By (Parents)
- `GeneralFilterBarView` - main filter button on the right

### Uses (Children)
- None (leaf component)

## Features

- Pill-shaped white container (fully rounded corners)
- Filter icon on the left (22pt)
- Localized "Filter" label (bold 12pt)
- Action arrow icon on the right (18pt)
- Optional selection counter badge (red, 16pt circle)
- Badge displays active filter count
- 40pt fixed height
- 8pt horizontal padding
- Tap gesture with callback
- Reactive state updates via Combine publisher
- Two states: notSelected (no badge) and selected (shows badge with count)

## Usage

```swift
let mainFilter = MainFilterItem(type: .mainFilter, title: LocalizationProvider.string("filter"))
let viewModel = MockMainFilterPillViewModel(mainFilter: mainFilter, initialState: .notSelected)
let filterPill = MainFilterPillView(viewModel: viewModel)

filterPill.onFilterTapped = { quickLinkType in
    print("Filter tapped: \(quickLinkType)")
}

// Update state to show badge
filterPill.setFilterState(filterState: .selected(selections: "3"))

// Clear badge
filterPill.setFilterState(filterState: .notSelected)
```

## Data Model

```swift
struct MainFilterItem {
    let type: QuickLinkType
    let title: String
    let icon: String?
    let actionIcon: String?
}

enum MainFilterStateType {
    case notSelected
    case selected(selections: String)
}

protocol MainFilterPillViewModelProtocol {
    var mainFilterState: CurrentValueSubject<MainFilterStateType, Never> { get set }
    var mainFilterSubject: CurrentValueSubject<MainFilterItem, Never> { get }

    func didTapMainFilterItem() -> QuickLinkType
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.allWhite` - container background
- `StyleProvider.Color.highlightPrimary` - icon tint colors
- `StyleProvider.Color.textPrimary` - label text color
- `StyleProvider.Color.buttonTextPrimary` - badge text color
- `StyleProvider.fontWith(type: .bold, size: 12)` - label font
- `StyleProvider.fontWith(type: .semibold, size: 10)` - badge font

Layout constants:
- Container height: 40pt
- Container corner radius: fully rounded (height / 2)
- Filter icon size: 22pt
- Arrow icon size: 18pt
- Badge size: 16pt (circular)
- Stack spacing: 4pt
- Horizontal padding: 8pt
- Vertical padding: 8pt
- Badge offset: -4pt from top-right

## Mock ViewModels

No dedicated mock presets - use MockMainFilterPillViewModel directly with MainFilterItem and initial state.
