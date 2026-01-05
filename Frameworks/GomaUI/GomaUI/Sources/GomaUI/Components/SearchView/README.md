# SearchView

A lightweight search input with a leading magnifying-glass icon and a trailing clear button.

## Overview

SearchView provides a styled text input field with a magnifying-glass search icon, placeholder text support, and a clear button that appears when text is entered. The component supports both plain and attributed placeholder text, with automatic emphasis styling on the last word (commonly a brand name). It integrates with reactive publishers for text changes, focus state, and enabled state.

## Component Relationships

### Used By (Parents)
- Search screens
- Header navigation areas

### Uses (Children)
- None (leaf component)

## Features

- Search icon (magnifying glass) in left position
- Clear button appears when text is entered
- Plain or attributed placeholder text support
- Last word emphasis styling in placeholder
- Focus state tracking
- Enabled/disabled state support
- Keyboard search button return type
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockSearchViewModel.default
let searchView = SearchView(viewModel: viewModel)

// With custom placeholder
let customVM = MockSearchViewModel.withPlaceholder("Search in Casino")
let customSearchView = SearchView(viewModel: customVM)

// Update placeholder at runtime
viewModel.updatePlaceholder("Search for games...")

// React to text changes
viewModel.textPublisher
    .sink { text in
        performSearch(text)
    }
    .store(in: &cancellables)
```

## Data Model

```swift
protocol SearchViewModelProtocol: AnyObject {
    // Content
    var placeholderTextPublisher: AnyPublisher<String, Never> { get }
    var attributedPlaceholderPublisher: AnyPublisher<NSAttributedString?, Never> { get }
    var textPublisher: AnyPublisher<String, Never> { get }

    // UI State
    var isClearButtonVisiblePublisher: AnyPublisher<Bool, Never> { get }
    var isEnabledPublisher: AnyPublisher<Bool, Never> { get }
    var isFocusedPublisher: AnyPublisher<Bool, Never> { get }

    // Inputs
    func updateText(_ text: String)
    func clearText()
    func setFocused(_ isFocused: Bool)
    func submit()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.inputBackgroundSecondary` - outer container background
- `StyleProvider.Color.inputBackground` - inner container background
- `StyleProvider.Color.textPrimary` - text field text color
- `StyleProvider.Color.inputText` - placeholder text color
- `StyleProvider.Color.highlightPrimary` - icon and clear button tint
- `StyleProvider.fontWith(type: .regular, size: 14)` - text field font
- `StyleProvider.fontWith(type: .bold, size: 14)` - placeholder emphasis font

Layout constants:
- Container height: 40pt
- Horizontal padding: 12pt
- Spacing: 8pt
- Corner radius: 4pt
- Icon size: 18pt
- Clear button size: 18pt

Placeholder styling:
- Regular 14pt for most text
- Bold 14pt for last word (brand emphasis)

Icons:
- Search: Bundle "search_icon" or SF Symbol "magnifyingglass"
- Clear: Bundle "cancel_search_icon" or SF Symbol "xmark"

## Mock ViewModels

Available presets:
- `.default` - Standard "Search in Sportsbook" placeholder
- `.withPlaceholder(_ text:)` - Custom placeholder text

Methods:
- `updateText(_ text:)` - Updates text and clear button visibility
- `clearText()` - Clears text and hides clear button
- `setFocused(_ isFocused:)` - Tracks focus state
- `updatePlaceholder(_ text:)` - Updates placeholder at runtime
