# SportTypeSelectorView

A full-screen sport selection component with a 2-column grid layout. Includes collection view implementation, wrapper cell, and presentation view controller for complete sport selection workflows.

## Components Overview

This component consists of three main parts:

1. **SportTypeSelectorView** - Main collection view component
2. **SportTypeSelectorCollectionViewCell** - Wrapper cell for reuse
3. **SportTypeSelectorViewController** - Full presentation controller

## Features

- 2-column UICollectionView with 8px spacing
- Full-screen presentation with navigation
- Sport selection callbacks and delegation
- Reactive data updates via Combine
- Modal presentation support
- Proper cell reuse and memory management

## Usage Example

### Basic Integration

```swift
// Create view model with sports data
let sports = [
    SportTypeData(id: "football", name: "Football", iconName: "football"),
    SportTypeData(id: "basketball", name: "Basketball", iconName: "basketball"),
    SportTypeData(id: "tennis", name: "Tennis", iconName: "tennis")
]
let viewModel = MockSportTypeSelectorViewModel(sports: sports)

// Create and present the view controller
let selectorVC = SportTypeSelectorViewController(viewModel: viewModel)

// Handle sport selection
selectorVC.onSportSelected = { selectedSport in
    print("User selected: \(selectedSport.name)")
    // Update your app state
    selectorVC.dismiss()
}

selectorVC.onCancel = {
    print("User cancelled selection")
    selectorVC.dismiss()
}

// Present modally
selectorVC.presentModally(from: self)
```

### Delegate Pattern

```swift
class MyViewController: UIViewController, SportTypeSelectorViewControllerDelegate {
    
    func presentSportSelector() {
        let selectorVC = SportTypeSelectorViewController.createWithMockData()
        selectorVC.delegate = self
        selectorVC.presentModally(from: self)
    }
    
    // MARK: - SportTypeSelectorViewControllerDelegate
    
    func sportTypeSelectorViewController(_ controller: SportTypeSelectorViewController, didSelectSport sport: SportTypeData) {
        // Handle sport selection
        print("Selected: \(sport.name)")
        controller.dismiss()
    }
    
    func sportTypeSelectorViewControllerDidCancel(_ controller: SportTypeSelectorViewController) {
        // Handle cancellation
        controller.dismiss()
    }
}
```

### Direct View Usage

```swift
// Use just the collection view component
let selectorView = SportTypeSelectorView(viewModel: viewModel)
selectorView.onSportSelected = { sport in
    // Handle selection
}

parentView.addSubview(selectorView)
// Add constraints...
```

## Data Models

### SportTypeSelectorDisplayState
```swift
public struct SportTypeSelectorDisplayState: Equatable {
    public let sports: [SportTypeData]  // Array of available sports
}
```

## View Model Protocol

```swift
public protocol SportTypeSelectorViewModelProtocol {
    var displayStatePublisher: AnyPublisher<SportTypeSelectorDisplayState, Never> { get }
}
```

## Component Architecture

### SportTypeSelectorView
- Main UICollectionView with flow layout
- 2-column grid with dynamic sizing
- Handles sport selection and callbacks
- Uses `SportTypeSelectorCollectionViewCell` for items

### SportTypeSelectorCollectionViewCell
- Wrapper around `SportTypeSelectorItemView`
- Proper cell reuse and cleanup
- Forwards tap events to collection view

### SportTypeSelectorViewController
- Full presentation controller with navigation
- Modal presentation support
- Delegate pattern and closure-based callbacks
- Cancel/dismiss handling

## Layout Configuration

- **Columns**: 2
- **Item Spacing**: 8px horizontal and vertical
- **Section Insets**: 8px all around
- **Item Height**: 56px (fixed)
- **Item Width**: Dynamic based on container width

## Mock Data

The component includes comprehensive mock data:

```swift
// Pre-built mock sets
let defaultMock = MockSportTypeSelectorViewModel.defaultMock        // 4 sports
let manySportsMock = MockSportTypeSelectorViewModel.manySportsMock  // 12 sports
let fewSportsMock = MockSportTypeSelectorViewModel.fewSportsMock    // 2 sports
let emptyMock = MockSportTypeSelectorViewModel.emptySportsMock      // 0 sports

// Custom mock data
let customSports = [/* your sports array */]
let customMock = MockSportTypeSelectorViewModel(sports: customSports)
```

## Styling

Uses StyleProvider for consistent theming:

- **Background**: `StyleProvider.Color.backgroundSecondary`
- **Navigation**: `StyleProvider.Color.textPrimary` for text and tint
- **Individual Items**: Styled via `SportTypeSelectorItemView`

## SwiftUI Previews

```swift
#Preview("Default") {
    PreviewUIView {
        SportTypeSelectorView(viewModel: MockSportTypeSelectorViewModel.defaultMock)
    }
    .frame(height: 400)
}
```

## Integration with Other Components

- Uses `SportTypeSelectorItemView` for individual sport display
- Integrates with any view model implementing `SportTypeSelectorViewModelProtocol`
- Can be embedded in larger flows or used as standalone selection

## Factory Methods

```swift
// Quick creation methods
let controller = SportTypeSelectorViewController.create(with: viewModel)
let mockController = SportTypeSelectorViewController.createWithMockData()
```

## Memory Management

- Proper cleanup in `prepareForReuse()` for collection view cells
- Combine cancellables are managed automatically
- View controllers handle dismissal and memory cleanup

## Best Practices

1. Always handle both selection and cancellation events
2. Dismiss the view controller after processing selection
3. Use delegate pattern for complex flows, closures for simple ones
4. Test with different sport counts to ensure layout works properly
5. Consider loading states for dynamic data sources