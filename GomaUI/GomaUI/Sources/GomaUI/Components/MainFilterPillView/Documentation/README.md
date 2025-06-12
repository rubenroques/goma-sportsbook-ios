# MainFilterPillView

A compact, pill-shaped filter button component built with UIKit and Combine that provides a quick access point to main filtering functionality. The component features a customizable appearance with filter icons, text labels, selection counters, and interactive feedback.

## Overview

The `MainFilterPillView` is designed as a prominent filter entry point, typically positioned in toolbars or navigation areas. It displays filter status through visual indicators and a selection counter badge. The component follows MVVM architecture and uses reactive programming with Combine for state management.

## Architecture

### Component Structure
```
MainFilterPillView/
├── MainFilterPillView.swift                # Main component view
├── MainFilterPillViewModelProtocol.swift   # View model protocol
├── MockMainFilterPillViewModel.swift       # Mock implementation
└── Models/
    └── MainFilterPillViewModels.swift      # Data models
```

### MVVM Pattern
- **View**: `MainFilterPillView` - Main UI component with pill-shaped design
- **ViewModel**: `MainFilterPillViewModelProtocol` - Business logic and state management
- **Model**: `MainFilterItem` & `MainFilterStateType` - Data structures

## Key Features

### Visual Design
- **Pill Shape**: Rounded corners with 40pt height for optimal touch targets
- **Filter Icon**: Customizable filter icon (default: horizontal decrease circle)
- **Action Arrow**: Right-pointing chevron indicating interactive element
- **Selection Counter**: Red badge displaying number of active filters
- **Responsive Layout**: Adapts to content with proper spacing

### Interactive Elements
- **Full Tap Area**: Entire pill is tappable for better accessibility
- **Visual Feedback**: Responds to user interaction
- **Counter Badge**: Shows/hides based on filter selection state
- **Quick Access**: Direct navigation to main filter interface

### State Management
- **Filter States**: Not selected vs selected with count
- **Reactive Updates**: Combine-based state synchronization
- **Dynamic Counters**: Real-time updates when filters change
- **Type Safety**: Enum-based filter type system

## Models

### MainFilterItem
```swift
public struct MainFilterItem: Equatable, Hashable {
    public let type: QuickLinkType
    public let title: String
    public let icon: String?
    public let actionIcon: String?
}
```

**Properties:**
- `type`: Filter type from `QuickLinkType` enum (`.mainFilter`)
- `title`: Display text (typically "Filter")
- `icon`: Optional custom filter icon name
- `actionIcon`: Optional custom action icon name

### MainFilterStateType
```swift
public enum MainFilterStateType {
    case notSelected
    case selected(selections: String)
}
```

**States:**
- `notSelected`: No filters applied (hides counter)
- `selected(selections)`: Filters applied with count string

### QuickLinkType Integration
The component integrates with the `QuickLinkType` system:
```swift
public enum QuickLinkType: String, Hashable {
    // ... other types
    case mainFilter  // Used by MainFilterPillView
}
```

## Protocols

### MainFilterPillViewModelProtocol
```swift
public protocol MainFilterPillViewModelProtocol {
    func didTapMainFilterItem() -> QuickLinkType
    var mainFilterState: CurrentValueSubject<MainFilterStateType, Never> { get set }
    var mainFilterSubject: CurrentValueSubject<MainFilterItem, Never> { get }
}
```

**Key Methods:**
- `didTapMainFilterItem()`: Handles tap events and returns filter type
- `mainFilterState`: Current filter selection state
- `mainFilterSubject`: Filter item configuration

## Usage Examples

### Basic Implementation
```swift
let mainFilter = MainFilterItem(
    type: .mainFilter,
    title: "Filter",
    icon: "line.3.horizontal.decrease.circle.fill",
    actionIcon: "chevron.right"
)

let viewModel = MockMainFilterPillViewModel(mainFilter: mainFilter)
let filterPillView = MainFilterPillView(viewModel: viewModel)

// Handle filter taps
filterPillView.onFilterTapped = { filterType in
    print("Filter tapped: \(filterType)")
    // Navigate to filter interface
}
```

### Custom ViewModel Implementation
```swift
class CustomMainFilterPillViewModel: MainFilterPillViewModelProtocol {
    var mainFilterState = CurrentValueSubject<MainFilterStateType, Never>(.notSelected)
    let mainFilterSubject: CurrentValueSubject<MainFilterItem, Never>
    
    init(filterItem: MainFilterItem) {
        self.mainFilterSubject = CurrentValueSubject(filterItem)
    }
    
    func didTapMainFilterItem() -> QuickLinkType {
        // Analytics tracking
        trackFilterButtonTap()
        
        return mainFilterSubject.value.type
    }
    
    private func trackFilterButtonTap() {
        // Custom analytics implementation
    }
}
```

### Integration in Navigation Bar
```swift
class NavigationViewController: UIViewController {
    private var filterPillView: MainFilterPillView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFilterPill()
    }
    
    private func setupFilterPill() {
        let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter")
        let viewModel = MockMainFilterPillViewModel(mainFilter: mainFilter)
        
        filterPillView = MainFilterPillView(viewModel: viewModel)
        filterPillView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(filterPillView)
        
        NSLayoutConstraint.activate([
            filterPillView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterPillView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        
        filterPillView.onFilterTapped = { [weak self] _ in
            self?.presentFilterInterface()
        }
    }
    
    private func presentFilterInterface() {
        // Present main filter view controller
    }
}
```

### State Management Example
```swift
class FilterCoordinator {
    private let filterPillView: MainFilterPillView
    private var activeFiltersCount = 0
    
    init(filterPillView: MainFilterPillView) {
        self.filterPillView = filterPillView
    }
    
    func updateFilterCount(_ count: Int) {
        activeFiltersCount = count
        
        let state: MainFilterStateType = count > 0 
            ? .selected(selections: "\(count)")
            : .notSelected
            
        filterPillView.setFilterState(filterState: state)
    }
    
    func clearAllFilters() {
        updateFilterCount(0)
    }
}
```

## Component Behavior

### Visual States
- **Default State**: Filter icon, "Filter" text, chevron arrow
- **With Selections**: Adds red counter badge with number
- **No Selections**: Hides counter badge
- **Interactive**: Responds to taps on entire pill area

### Counter Badge
- **Position**: Top-right corner with slight overlap
- **Style**: Red circular badge with white text
- **Size**: 16x16pt with 8pt corner radius
- **Typography**: Semibold 10pt font
- **Visibility**: Shown only when filters are applied

### Layout Behavior
- **Fixed Height**: 40pt for consistent touch targets
- **Dynamic Width**: Adapts to content with 8pt padding
- **Rounded Corners**: Pill shape with height/2 corner radius
- **Center Alignment**: Vertical centering of all elements

## Styling Integration

The component integrates with `StyleProvider` for consistent theming:

- **Colors**:
  - `backgroundColor`: Container background
  - `highlightPrimary`: Icon and arrow tint color
  - `textColor`: Label text color
  - `buttonTextPrimary`: Counter text color
- **Typography**:
  - Bold 12pt for filter label
  - Semibold 10pt for counter text
- **Icons**:
  - Default filter icon: `line.3.horizontal.decrease.circle.fill`
  - Default action icon: `chevron.right`

## Layout Structure

### Component Hierarchy
```
MainFilterPillView
└── containerView (pill-shaped background)
    ├── stackView (horizontal layout)
    │   ├── filterIconImageView (22x22pt)
    │   ├── filterLabel ("Filter" text)
    │   └── arrowImageView (18x18pt)
    └── counterView (badge overlay)
        └── counterLabel (count text)
```

### Constraints
- Container: Full bounds with 40pt height
- Stack: 8pt margins with 4pt spacing
- Counter: Top-right with slight offset (-4pt top, -4pt trailing)
- Icons: Fixed sizes for consistent appearance

## Integration Patterns

### With QuickLinksTabBar
```swift
class MainToolbarViewController: UIViewController {
    private var quickLinksTabBar: QuickLinksTabBarView!
    private var filterPillView: MainFilterPillView!
    
    private func setupToolbar() {
        // Setup tab bar
        quickLinksTabBar = QuickLinksTabBarView(viewModel: tabBarViewModel)
        
        // Setup filter pill
        let filterItem = MainFilterItem(type: .mainFilter, title: "Filter")
        let filterViewModel = MockMainFilterPillViewModel(mainFilter: filterItem)
        filterPillView = MainFilterPillView(viewModel: filterViewModel)
        
        // Layout both components
        layoutToolbarComponents()
    }
}
```

### With Filter State Management
```swift
class FilterStateManager: ObservableObject {
    @Published var sportsFilters: [Int] = []
    @Published var leagueFilters: [Int] = []
    @Published var sortFilters: [Int] = []
    
    var totalActiveFilters: Int {
        sportsFilters.count + leagueFilters.count + sortFilters.count
    }
    
    func updateMainFilterPill(_ pillView: MainFilterPillView) {
        let state: MainFilterStateType = totalActiveFilters > 0
            ? .selected(selections: "\(totalActiveFilters)")
            : .notSelected
            
        pillView.setFilterState(filterState: state)
    }
}
```

## Accessibility Features

- **Touch Targets**: 40pt height meets minimum accessibility requirements
- **Clear Labeling**: Descriptive text and icons
- **Visual Feedback**: Color and badge changes for state communication
- **Full Tap Area**: Entire pill is interactive, not just specific elements
- **Dynamic Type**: Font scaling support through StyleProvider

## SwiftUI Preview Support

The component includes SwiftUI preview for design-time visualization:

```swift
@available(iOS 17.0, *)
#Preview("Main Filter View") {
    PreviewUIView {
        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.toolbarBackgroundColor
        
        let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter")
        let viewModel = MockMainFilterPillViewModel(mainFilter: mainFilter)
        let filterView = MainFilterPillView(viewModel: viewModel)
        
        // Preview implementation
    }
}
```

## Technical Implementation

### Memory Management
- Weak references in closures to prevent retain cycles
- Proper Combine cancellable storage with `Set<AnyCancellable>`
- Automatic cleanup of gesture recognizers

### Performance Considerations
- Lightweight UI updates for state changes
- Efficient constraint management
- Minimal layout calculations with fixed sizing
- Optimized for frequent state updates

### Corner Radius Calculation
- Dynamic corner radius based on container height
- Updates in `layoutSubviews()` for proper pill shape
- Maintains rounded appearance across different sizes

## Error Handling

### Defensive Programming
- Safe unwrapping of optional icons
- Graceful fallbacks for missing assets
- Proper state validation
- Safe type casting and enum handling

## Dependencies

- **UIKit**: Core UI framework and gesture handling
- **Combine**: Reactive programming and state management
- **SwiftUI**: Preview support (iOS 17.0+)
- **StyleProvider**: Internal styling and theming system
- **Foundation**: Basic data structures

## Best Practices

1. **State Consistency**: Keep filter count in sync with actual applied filters
2. **Memory Management**: Use weak references in callback closures
3. **Icon Assets**: Provide fallback icons for missing assets
4. **Touch Targets**: Maintain 40pt minimum height for accessibility
5. **Visual Feedback**: Provide clear indication of filter state
6. **Performance**: Avoid unnecessary state updates during rapid changes

## Usage Scenarios

### Sports Betting Interface
```swift
// Toolbar with filter pill for sports betting filters
let sportsFilter = MainFilterItem(
    type: .mainFilter,
    title: "Filters",
    icon: "sportscourt.fill"
)
```

### Gaming Platform
```swift
// Filter pill for game filters
let gameFilter = MainFilterItem(
    type: .mainFilter,
    title: "Game Filters", 
    icon: "gamecontroller.fill"
)
```

### E-commerce App
```swift
// Product filter pill
let productFilter = MainFilterItem(
    type: .mainFilter,
    title: "Filter Products",
    icon: "slider.horizontal.3"
)
```

## Future Enhancements

- Custom color schemes for different themes
- Animation effects for state transitions
- Support for multiple counter types (e.g., different colors)
- Long press gestures for quick filter actions
- Accessibility voice-over improvements
- Custom shapes beyond pill design
- Integration with haptic feedback
- Badge positioning customization
- Support for text-only mode without icons
``` 