# RecentSearchView

A reusable UIKit component for displaying recent search terms with tap and delete functionality.

## Overview

The `RecentSearchView` component displays a search term in a styled container with a delete button. It supports tap gestures for selecting the search term and a delete button for removing it from recent searches.

## Features

- **Search Icon**: Magnifying glass icon on the left
- **Tap Handling**: Tap anywhere on the view to trigger the `onTap` callback
- **Delete Functionality**: X button triggers the `onDelete` callback
- **Separator Line**: Bottom border line for visual separation
- **Theming**: Uses `StyleProvider` for consistent styling
- **ViewModel Pattern**: Follows GomaUI MVVM architecture
- **SwiftUI Preview**: Includes preview for rapid development

## Usage

```swift
// Create view model with callbacks
let viewModel = MockRecentSearchViewModel(
    searchText: "Liverpool",
    onTap: {
        // Handle tap - perform search with this term
        print("Searching for: Liverpool")
    },
    onDelete: {
        // Handle delete - remove from recent searches
        print("Deleting recent search")
    }
)

// Create and configure the view
let recentSearchView = RecentSearchView(viewModel: viewModel)
recentSearchView.configure()
```

## Architecture

### ViewModel Protocol
- `searchText: String` - The search term to display
- `onTap: (() -> Void)?` - Callback triggered when view is tapped
- `onDelete: (() -> Void)?` - Callback triggered when delete button is pressed

### Component Structure
- **Container View**: Rounded background container
- **Stack View**: Horizontal layout for icon, text and button
- **Search Icon**: Magnifying glass icon (16x16pt)
- **Search Text Label**: Displays the search term
- **Delete Button**: X button for deletion (20x20pt)
- **Separator Line**: Bottom border line (1pt height)

## Theming

The component uses `StyleProvider` for consistent theming:

- **Text Color**: `StyleProvider.Color.textPrimary`
- **Search Icon Color**: `StyleProvider.Color.textSecondary`
- **Delete Button Color**: `StyleProvider.Color.highlightPrimary`
- **Background**: `StyleProvider.Color.backgroundTertiary`
- **Separator Line**: `StyleProvider.Color.borderPrimary`
- **Font**: `StyleProvider.fontWith(type: .regular, size: 16)`

## Layout

- **Corner Radius**: 8pt rounded corners
- **Padding**: 12pt horizontal, 8pt vertical
- **Spacing**: 12pt between icon, text and delete button
- **Search Icon Size**: 16x16pt magnifying glass
- **Button Size**: 20x20pt square delete button
- **Separator Height**: 1pt bottom border line

## Callbacks

### onTap
Triggered when the user taps anywhere on the view. Use this to:
- Perform a new search with the displayed term
- Navigate to search results
- Update the search input field

### onDelete
Triggered when the user taps the X button. Use this to:
- Remove the search term from recent searches
- Update the recent searches list
- Persist changes to storage

## SwiftUI Preview

The component includes a SwiftUI preview showing multiple recent search examples for rapid development and testing.
