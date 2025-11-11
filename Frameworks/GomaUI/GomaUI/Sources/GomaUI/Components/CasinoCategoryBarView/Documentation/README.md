# CasinoCategoryBarView

A simple horizontal bar component for displaying casino game categories with a title and action button.

## Overview

The `CasinoCategoryBarView` provides a clean, consistent way to display category information with an interactive button. It features a title label on the left side and an action button on the right side containing count text and a chevron icon.

## Features

- **Flexible Content**: Configurable title and button text
- **Optional ViewModel**: Can be initialized with or without a viewModel
- **Runtime Configuration**: Supports changing viewModel after initialization
- **Reactive Updates**: Uses Combine publishers for real-time UI updates
- **Interactive Button**: Tap handling with callback support
- **Consistent Styling**: Follows GomaUI design system

## Architecture

### MVVM Pattern
The component follows the MVVM (Model-View-ViewModel) architectural pattern:

- **Model**: `CasinoCategoryBarData` - Contains category information
- **View**: `CasinoCategoryBarView` - The UI component
- **ViewModel**: `CasinoCategoryBarViewModelProtocol` - Business logic and data binding

### Components Structure
```
CasinoCategoryBarView/
├── CasinoCategoryBarViewModelProtocol.swift  # Protocol and data models
├── CasinoCategoryBarView.swift               # Main UI component
├── MockCasinoCategoryBarViewModel.swift      # Mock implementation
└── Documentation/
    └── README.md                             # This file
```

## Usage

### Basic Usage
```swift


// With viewModel
let viewModel = MockCasinoCategoryBarViewModel.newGames
let categoryBar = CasinoCategoryBarView(viewModel: viewModel)

// Without viewModel (shows placeholder)
let categoryBar = CasinoCategoryBarView()
```

### Runtime Configuration
```swift
let categoryBar = CasinoCategoryBarView()

// Configure with viewModel
categoryBar.configure(with: viewModel)

// Clear viewModel (shows placeholder)
categoryBar.configure(with: nil)
```

### Button Action Handling
```swift
categoryBar.onButtonTapped = { categoryId in
    print("Button tapped for category: \(categoryId)")
    // Handle navigation or filtering
}
```

## Data Models

### CasinoCategoryBarData
```swift
public struct CasinoCategoryBarData: Equatable, Hashable, Identifiable {
    public let id: String           // category identifier
    public let title: String        // category title (e.g., "New Games")
    public let buttonText: String   // button text (e.g., "All 41")
}
```

## ViewModel Protocol

### CasinoCategoryBarViewModelProtocol
```swift
public protocol CasinoCategoryBarViewModelProtocol: AnyObject {
    // Publishers for reactive updates
    var titlePublisher: AnyPublisher<String, Never> { get }
    var buttonTextPublisher: AnyPublisher<String, Never> { get }
    
    // Read-only properties
    var categoryId: String { get }
    
    // Actions
    func buttonTapped()
}
```

## Mock ViewModel

The `MockCasinoCategoryBarViewModel` provides several factory methods for common casino categories:

```swift
// Predefined categories
let newGames = MockCasinoCategoryBarViewModel.newGames
let popularGames = MockCasinoCategoryBarViewModel.popularGames
let slotGames = MockCasinoCategoryBarViewModel.slotGames
let liveGames = MockCasinoCategoryBarViewModel.liveGames
let jackpotGames = MockCasinoCategoryBarViewModel.jackpotGames

// Custom category
let custom = MockCasinoCategoryBarViewModel.customCategory(
    id: "custom-id",
    title: "Custom Category",
    buttonText: "All 15"
)
```

## Visual Design

The component follows the Figma design specifications:

- **Background**: `backgroundSecondary` color
- **Title**: Bold 16px, `textPrimary` color
- **Button**: `highlightPrimary` background, white text, 14px semibold
- **Icon**: Right chevron in button
- **Layout**: Horizontal with space-between alignment
- **Padding**: 16px horizontal, 12px vertical
- **Button**: 10px horizontal, 4px vertical padding

## States

### Normal State
- Displays title and button text from viewModel
- Button is interactive
- Publishers provide real-time updates

### Placeholder State
- Shows when no viewModel is provided
- Displays "Category Title" and "All 0" as placeholders
- Button is still interactive but returns empty categoryId

## Accessibility

The component supports:
- VoiceOver navigation
- Dynamic type scaling
- High contrast support
- Touch target sizing (minimum 44pt)

## Demo

See `CasinoCategoryBarViewController` in the GomaUI Demo app for interactive examples showcasing:
- Multiple category bars with different data
- Runtime configuration switching
- Button tap handling
- Placeholder state demonstration
