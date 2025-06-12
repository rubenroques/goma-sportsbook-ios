# SportGamesFilterView

A customizable sports filter component for iOS that allows users to select from different sports using an interactive grid layout with collapsible functionality.

![SportGamesFilterView Preview](./preview.png)

## Overview

SportGamesFilterView is a UIKit-based component that provides an intuitive grid interface for sports selection. It displays sport options as interactive cards in a 2-column grid layout, supports expand/collapse functionality, and provides visual feedback for the currently selected sport.

## Features

- ✅ **Grid Layout**: 2-column responsive grid for sport cards
- ✅ **Interactive Cards**: Tap-to-select sport cards with visual feedback
- ✅ **Collapsible Interface**: Expand/collapse functionality with smooth animations
- ✅ **Visual Selection**: Selected sport highlighted with accent color
- ✅ **Reactive Design**: Uses Combine framework for reactive state management
- ✅ **Custom Styling**: Integrates with StyleProvider for consistent theming
- ✅ **Icon Support**: System icons for each sport type
- ✅ **Preview Support**: Includes SwiftUI preview for development

## Architecture

The component follows MVVM architecture pattern with a nested card component:

```
SportGamesFilterView (UIView)
    ↓
SportGamesFilterViewModelProtocol
    ↓
MockSportGamesFilterViewModel (Concrete Implementation)
    ↓
SportFilter (Data Model)
    ↓
SportCardView (Sub-component)
    ↓
SportCardViewModelProtocol
    ↓
MockSportCardViewModel
```

## Files Structure

```
SportGamesFilterView/
├── SportGamesFilterView.swift                    # Main UI component
├── SportGamesFilterViewModelProtocol.swift       # View model protocol
├── MockSportGamesFilterViewModel.swift           # Mock implementation
├── Models/
│   └── SportGamesFilterModels.swift             # Data models
├── SportCard/
│   ├── SportCardView.swift                      # Individual sport card UI
│   ├── SportCardViewModelProtocol.swift         # Sport card view model protocol
│   └── MockSportCardViewModel.swift             # Sport card mock implementation
└── README.md                                    # This file
```

## Usage

### Basic Implementation

```swift
import GomaUI

// 1. Create sport filter options
let sportFilters = [
    SportFilter(id: 1, title: "Football", icon: "sportscourt.fill"),
    SportFilter(id: 2, title: "Basketball", icon: "basketball.fill"),
    SportFilter(id: 3, title: "Tennis", icon: "tennis.racket"),
    SportFilter(id: 4, title: "Cricket", icon: "figure.cricket")
]

// 2. Create view model
let viewModel = MockSportGamesFilterViewModel(
    title: "Sports",
    sportFilters: sportFilters,
    selectedId: 1
)

// 3. Create and configure the view
let sportGamesFilterView = SportGamesFilterView(viewModel: viewModel)
sportGamesFilterView.translatesAutoresizingMaskIntoConstraints = false

// 4. Handle sport selection
sportGamesFilterView.onSportSelected = { selectedSportId in
    print("Selected sport ID: \(selectedSportId)")
    // Handle sport selection logic
}

// 5. Add to your view hierarchy
view.addSubview(sportGamesFilterView)
NSLayoutConstraint.activate([
    sportGamesFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    sportGamesFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    sportGamesFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
])
```

### Reactive Implementation with Combine

```swift
import Combine

class FilterViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let sportGamesFilterView: SportGamesFilterView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subscribe to selection changes
        sportGamesFilterView.viewModel.selectedId
            .sink { [weak self] selectedId in
                self?.handleSportSelection(selectedId)
            }
            .store(in: &cancellables)
        
        // Subscribe to collapse/expand state
        sportGamesFilterView.viewModel.sportFilterState
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleSportSelection(_ sportId: Int) {
        // Handle sport selection
    }
    
    private func handleStateChange(_ state: SportGamesFilterStateType) {
        switch state {
        case .expanded:
            print("Filter expanded")
        case .collapsed:
            print("Filter collapsed")
        }
    }
}
```

### Programmatic State Control

```swift
// Programmatically select a sport
viewModel.selectOption(withId: 2)

// Programmatically toggle collapse state
viewModel.didTapCollapseButton()

// Check current state
let isExpanded = viewModel.sportFilterState.value == .expanded
```

## API Reference

### SportGamesFilterView

The main UI component that displays the sports filter interface.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `onSportSelected` | `((Int) -> Void)?` | Callback triggered when a sport is selected |

#### Methods

| Method | Description |
|--------|-------------|
| `init(viewModel: SportGamesFilterViewModelProtocol)` | Initializes the view with a view model |

### SportGamesFilterViewModelProtocol

Protocol defining the interface for sport games filter view models.

#### Required Properties

| Property | Type | Description |
|----------|------|-------------|
| `title` | `String` | The title displayed at the top of the component |
| `sportFilters` | `[SportFilter]` | Array of available sport options |
| `selectedId` | `CurrentValueSubject<Int, Never>` | Reactive property for selected sport ID |
| `sportFilterState` | `CurrentValueSubject<SportGamesFilterStateType, Never>` | Reactive property for collapse/expand state |

#### Required Methods

| Method | Description |
|--------|-------------|
| `selectOption(withId id: Int)` | Selects a sport by ID |
| `didTapCollapseButton()` | Toggles the collapse/expand state |

### MockSportGamesFilterViewModel

Concrete implementation of `SportGamesFilterViewModelProtocol` for testing and development.

#### Initializer

```swift
public init(
    title: String, 
    sportFilters: [SportFilter], 
    selectedId: Int = 1
)
```

### SportFilter

Data model representing a sport option in the filter.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `Int` | Unique identifier for the sport |
| `title` | `String` | Display name for the sport |
| `icon` | `String?` | System icon name for the sport |

#### Initializer

```swift
public init(id: Int, title: String, icon: String?)
```

### SportGamesFilterStateType

Enum representing the expand/collapse state of the filter.

#### Cases

| Case | Description |
|------|-------------|
| `.expanded` | Filter is expanded showing all sport cards |
| `.collapsed` | Filter is collapsed hiding sport cards |

### SportCardView

Individual sport card component used within the grid.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `isSelected` | `Bool` | Whether the card is currently selected |
| `onTap` | `((Int) -> Void)?` | Callback triggered when card is tapped |

#### Methods

| Method | Description |
|--------|-------------|
| `configure()` | Configures the card with view model data |

## Customization

### Styling

The component uses `StyleProvider` for consistent theming. You can customize:

- **Colors**: Background, accent, text colors
- **Fonts**: Title and label fonts
- **Spacing**: Margins, padding, and grid spacing
- **Corner Radius**: Card and container corner radius

### Custom Sport Options

Create custom sport configurations based on your needs:

```swift
// Traditional sports
let traditionalSports = [
    SportFilter(id: 1, title: "Football", icon: "sportscourt.fill"),
    SportFilter(id: 2, title: "Basketball", icon: "basketball.fill"),
    SportFilter(id: 3, title: "Baseball", icon: "baseball.fill"),
    SportFilter(id: 4, title: "Hockey", icon: "hockey.puck.fill")
]

// eSports
let eSports = [
    SportFilter(id: 1, title: "League of Legends", icon: "gamecontroller.fill"),
    SportFilter(id: 2, title: "CS:GO", icon: "target"),
    SportFilter(id: 3, title: "Dota 2", icon: "shield.fill"),
    SportFilter(id: 4, title: "Valorant", icon: "scope")
]

// Olympics
let olympicSports = [
    SportFilter(id: 1, title: "Swimming", icon: "figure.pool.swim"),
    SportFilter(id: 2, title: "Athletics", icon: "figure.run"),
    SportFilter(id: 3, title: "Gymnastics", icon: "figure.gymnastics"),
    SportFilter(id: 4, title: "Cycling", icon: "bicycle")
]
```

### Custom View Model

Implement your own view model for advanced functionality:

```swift
class NetworkSportGamesFilterViewModel: SportGamesFilterViewModelProtocol {
    let title: String = "Available Sports"
    let sportFilters: [SportFilter]
    let selectedId: CurrentValueSubject<Int, Never>
    let sportFilterState: CurrentValueSubject<SportGamesFilterStateType, Never>
    
    init(sports: [SportFilter]) {
        self.sportFilters = sports
        self.selectedId = .init(sports.first?.id ?? 1)
        self.sportFilterState = .init(.expanded)
    }
    
    func selectOption(withId id: Int) {
        selectedId.send(id)
        
        // Trigger network request or analytics
        trackSportSelection(id)
        fetchDataForSport(id)
    }
    
    func didTapCollapseButton() {
        let newState: SportGamesFilterStateType = sportFilterState.value == .expanded ? .collapsed : .expanded
        sportFilterState.send(newState)
        
        // Track collapse/expand analytics
        trackFilterStateChange(newState)
    }
    
    private func trackSportSelection(_ sportId: Int) {
        // Analytics implementation
    }
    
    private func trackFilterStateChange(_ state: SportGamesFilterStateType) {
        // Analytics implementation
    }
    
    private func fetchDataForSport(_ sportId: Int) {
        // Network request implementation
    }
}
```

### Custom Card Appearance

Customize individual sport cards:

```swift
class CustomSportCardViewModel: SportCardViewModelProtocol {
    let sportFilter: SportFilter
    let customBackgroundColor: UIColor
    let customTextColor: UIColor
    
    init(sportFilter: SportFilter, backgroundColor: UIColor = .systemBlue, textColor: UIColor = .white) {
        self.sportFilter = sportFilter
        self.customBackgroundColor = backgroundColor
        self.customTextColor = textColor
    }
}
```

## Integration Examples

### Filter Screen Integration

```swift
class FiltersViewController: UIViewController {
    private let sportGamesFilterView: SportGamesFilterView
    private let stackView: UIStackView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSportFilter()
    }
    
    private func setupSportFilter() {
        // Add to stack view
        stackView.addArrangedSubview(sportGamesFilterView)
        
        // Configure height constraint for collapsed state
        let heightConstraint = sportGamesFilterView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        heightConstraint.isActive = true
    }
}
```

### Tab-based Sports Navigation

```swift
class SportsTabViewController: UIViewController {
    private let sportGamesFilterView: SportGamesFilterView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sportGamesFilterView.onSportSelected = { [weak self] sportId in
            self?.navigateToSport(sportId)
        }
    }
    
    private func navigateToSport(_ sportId: Int) {
        let sportDetailVC = SportDetailViewController(sportId: sportId)
        navigationController?.pushViewController(sportDetailVC, animated: true)
    }
}
```

### Dynamic Sports Loading

```swift
class DynamicSportsViewController: UIViewController {
    private var viewModel: MockSportGamesFilterViewModel
    
    func loadSportsFromAPI() {
        APIManager.fetchAvailableSports { [weak self] sports in
            DispatchQueue.main.async {
                self?.updateSports(sports)
            }
        }
    }
    
    private func updateSports(_ sports: [SportFilter]) {
        // Update view model with new sports
        viewModel.sportFilters = sports
        
        // Refresh the view
        sportGamesFilterView.configureData()
    }
}
```

## Animation and Interaction

### Collapse/Expand Animation

The component includes smooth animations for state transitions:

- **Duration**: 0.3 seconds
- **Curve**: UIView default animation curve
- **Elements**: Grid opacity, height constraints, chevron rotation

### Selection Feedback

Visual feedback for sport selection:

- **Background Color**: Changes to accent color when selected
- **Icon Tint**: White when selected, black when unselected
- **Text Color**: White when selected, black when unselected

## Best Practices

1. **Limit Sports**: Keep sport options to 6-8 items for optimal UX
2. **Clear Icons**: Use recognizable system icons for each sport
3. **Logical Grouping**: Group related sports together
4. **Default Selection**: Set a sensible default sport selection
5. **State Persistence**: Remember user's collapse/expand preference
6. **Loading States**: Show loading indicators during data fetching

## Accessibility

The component includes accessibility features:

- **VoiceOver Support**: Proper accessibility labels and hints
- **Touch Targets**: Minimum 44pt touch targets for cards
- **Color Contrast**: High contrast colors through StyleProvider
- **Semantic Content**: Proper content hierarchy and navigation

## Performance Considerations

- **Grid Layout**: Efficient UIStackView-based grid implementation
- **Memory Management**: Weak references to prevent retain cycles
- **View Reuse**: Minimal view allocation and efficient updates
- **Animation Performance**: Hardware-accelerated animations

## Requirements

- iOS 13.0+
- Swift 5.0+
- UIKit
- Combine framework

## Dependencies

- `StyleProvider`: For consistent theming and colors
- `Combine`: For reactive programming

## Notes

- The grid automatically handles odd numbers of sports with empty spacer views
- Sport cards maintain 1:1 aspect ratio for consistent appearance
- Component automatically adapts to different screen sizes
- Collapse state affects only the grid visibility, not the header

## Troubleshooting

### Common Issues

1. **Cards not displaying**: Ensure `SportFilter` objects have valid `icon` values
2. **Selection not working**: Verify `onSportSelected` callback is set
3. **Layout issues**: Check Auto Layout constraints in parent view
4. **Animation glitches**: Ensure view is added to hierarchy before configuring

### Debug Tips

```swift
// Debug sport filter data
print("Available sports: \(viewModel.sportFilters)")
print("Selected sport: \(viewModel.selectedId.value)")
print("Current state: \(viewModel.sportFilterState.value)")

// Monitor state changes
viewModel.selectedId
    .sink { id in print("Sport selected: \(id)") }
    .store(in: &cancellables)
```

## Contributing

When contributing to this component:

1. Maintain the existing MVVM architecture
2. Add unit tests for new functionality
3. Update this README with any API changes
4. Follow the established naming conventions
5. Ensure backward compatibility
6. Test on different device sizes

## License

This component is part of the GomaUI library. See the main library license for details. 