# SelectOptionsView

A vertical list of selectable options with an optional title header.

## Overview

SelectOptionsView displays a vertical stack of radio-button-style options allowing single selection. Each option is rendered using SimpleOptionRowView with selection state tracking. The component supports an optional title above the options list and provides selection callbacks. It is commonly used for settings, preferences, and filter selections.

## Component Relationships

### Used By (Parents)
- Settings screens
- Preference forms
- Filter panels

### Uses (Children)
- `SimpleOptionRowView` (for each option)

## Features

- Vertical option list layout
- Single selection with visual feedback
- Optional title header
- Dynamic option rendering
- Selection callback
- Reactive selection updates via Combine
- Background color theming

## Usage

```swift
// Create options
let options = [
    MockSimpleOptionRowViewModel.sampleSelected,
    MockSimpleOptionRowViewModel.sampleUnselected
]
let viewModel = MockSelectOptionsViewModel(
    title: "Notification Preferences",
    options: options,
    selectedOption: "all"
)
let selectView = SelectOptionsView(viewModel: viewModel)

// Handle selection
selectView.onOptionSelected = { optionId in
    savePreference(optionId)
}

// Without title
let noTitleVM = MockSelectOptionsViewModel.withoutTitle
let noTitleView = SelectOptionsView(viewModel: noTitleVM)
```

## Data Model

```swift
protocol SelectOptionsViewModelProtocol {
    var title: String? { get }
    var options: [SimpleOptionRowViewModelProtocol] { get }
    var selectedOptionId: CurrentValueSubject<String?, Never> { get }
    func selectOption(withId id: String)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - stack view background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.fontWith(type: .semibold, size: 12)` - title font

Layout constants:
- Stack spacing: 12pt
- Title hidden if nil or empty

Option styling:
- Handled by SimpleOptionRowView component
- Selection state passed to each option

## Mock ViewModels

Available presets:
- `.withTitle` - "Notification Preferences" with All/Promotions/None options
- `.withoutTitle` - Options list without header title

Parameters:
- `title: String?` - Optional header title
- `options: [SimpleOptionRowViewModelProtocol]` - List of option view models
- `selectedOption: String?` - Initially selected option ID

Methods:
- `selectOption(withId:)` - Selects an option and triggers callback
