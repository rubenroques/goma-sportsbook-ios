# SearchHeaderInfoView

A reusable UI component that displays search status information with three distinct states: loading, results, and no results.

## Overview

The `SearchHeaderInfoView` provides a consistent way to show users the current state of their search operation, including animated loading indicators and appropriate messaging for different scenarios.

## Features

- **Three States**: Loading, Results, and No Results
- **Animated Loading**: Ellipsis animation during search operations
- **Dynamic Content**: Search term and category are dynamically inserted
- **Attributed Text**: Search term and count are displayed in bold, rest in regular font
- **Warning Icon**: Displays warning icon for no results state
- **Theme Support**: Uses StyleProvider for consistent theming

## Usage

### Basic Implementation

```swift
let searchHeaderView = SearchHeaderInfoView()

// Loading state
searchHeaderView.configure(
    searchTerm: "Liverpool", 
    category: "Sports", 
    state: .loading
)

// Results state
searchHeaderView.configure(
    searchTerm: "Liverpool", 
    category: "Sports", 
    state: .results, 
    count: 3
)

// No results state
searchHeaderView.configure(
    searchTerm: "Liverpool", 
    category: "Sports", 
    state: .noResults
)
```

### With ViewModel Pattern

```swift
class SearchViewModel: SearchHeaderInfoViewModelProtocol {
    @Published var searchTerm: String = ""
    @Published var category: String = "Sports"
    @Published var state: SearchState = .loading
    @Published var count: Int? = nil
    
    func updateSearch(term: String, category: String, state: SearchState, count: Int?) {
        self.searchTerm = term
        self.category = category
        self.state = state
        self.count = count
    }
}

// In your view controller
let viewModel = SearchViewModel()
let searchHeaderView = SearchHeaderInfoView()

// Bind to view model
viewModel.$state
    .sink { [weak self] state in
        self?.searchHeaderView.configure(
            searchTerm: viewModel.searchTerm,
            category: viewModel.category,
            state: state,
            count: viewModel.count
        )
    }
    .store(in: &cancellables)
```

## States

### Loading State
- **Text**: "Searching for \"[term]\" in [category]..."
- **Background**: Tertiary background color
- **Animation**: Animated ellipsis
- **Icon**: Hidden

### Results State
- **Text**: "Showing Results for \"[term]\" in [category] ([count])"
- **Background**: Tertiary background color
- **Formatting**: Search term and count (including parentheses) in bold, rest in regular font
- **Icon**: Hidden
- **Animation**: None

### No Results State
- **Text**: "No Results for \"[term]\" in [category]"
- **Background**: Secondary background color (different from other states)
- **Formatting**: Search term in bold, rest in regular font
- **Icon**: Orange warning triangle
- **Animation**: None

## Customization

### Theming
The component uses StyleProvider for consistent theming:

```swift
// Colors
StyleProvider.Color.backgroundTertiary  // Container background (loading/results states)
StyleProvider.Color.backgroundSecondary // Container background (no results state)
StyleProvider.Color.textPrimary        // Text color
StyleProvider.Color.highlightPrimary   // Warning icon color

// Fonts
StyleProvider.fontWith(type: .regular, size: 16)  // Regular text
StyleProvider.fontWith(type: .semibold, size: 16) // Bold text (search term and count)
```

### Layout
- **Height**: Auto-sizing based on content
- **Padding**: 16pt horizontal, 12pt vertical
- **Spacing**: 8pt between icon and text
- **Corner Radius**: Small corner radius applied

## Animation Details

The loading state includes a subtle ellipsis animation that cycles through "", ".", "..", "..." to indicate ongoing search operations. The animation:
- Duration: 1.5 seconds per cycle
- Repeats: Indefinitely
- Stops: Automatically when state changes

## Integration Notes

- **UIKit Only**: This is a UIKit component with SwiftUI preview support
- **Auto Layout**: Uses NSLayoutConstraint for responsive layout
- **Memory Efficient**: Lazy initialization of UI components
- **Protocol Driven**: Supports both direct configuration and ViewModel pattern

## Testing

Use the provided mock implementation for testing:

```swift
let mockViewModel = MockSearchHeaderInfoViewModel(
    searchTerm: "Test",
    category: "Sports", 
    state: .results,
    count: 5
)
```

## Preview

The component includes SwiftUI previews showing all three states. Use Xcode's preview canvas to see the component in action during development.
