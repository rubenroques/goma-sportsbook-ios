# SortFilterView

A collapsible sort filter component built with UIKit and Combine that provides users with sortable options in a clean, interactive interface. The component features an expandable/collapsible list of sort options with visual indicators and customizable styling.

## Overview

The `SortFilterView` is designed to display sorting options in a vertical list format with a collapsible header. Each option includes an icon, title, count indicator, and selection state. The component follows MVVM architecture and uses reactive programming with Combine for state management.

## Architecture

### Component Structure
```
SortFilterView/
├── SortFilterView.swift                    # Main component view
├── SortFilterViewModelProtocol.swift       # View model protocol
├── MockSortFilterViewModel.swift          # Mock implementation
├── SortOptionRowView/
│   ├── SortOptionRowView.swift            # Individual row component
│   ├── SortOptionRowViewModelProtocol.swift # Row view model protocol
│   └── MockSortOptionRowViewModel.swift   # Row mock implementation
└── Models/
    └── SortFilterModels.swift             # Data models
```

### MVVM Pattern
- **View**: `SortFilterView` - Main UI component
- **ViewModel**: `SortFilterViewModelProtocol` - Business logic and state management
- **Model**: `SortOption` - Data structure for sort options

## Key Features

### Interactive Elements
- **Collapsible Header**: Tap to expand/collapse the options list
- **Option Selection**: Single selection with visual feedback
- **Visual States**: Selected state with color changes and indicators
- **Count Display**: Shows number of items for each option

### Visual Design
- **Left Indicator**: Orange accent line for selected options
- **Radio Button**: Traditional radio button selection interface
- **Icon Support**: Optional icons with tint color changes
- **Typography**: Bold styling for selected items
- **Smooth Animations**: Collapse/expand transitions with rotation effects

### State Management
- **Reactive Updates**: Combine-based state synchronization
- **Selection Tracking**: Currently selected option management
- **Collapse State**: Expandable/collapsible interface
- **Dynamic Updates**: Support for refreshing sort options

## Models

### SortOption
```swift
public struct SortOption: Equatable {
    public var id: Int
    public var icon: String?
    public var title: String
    public var count: Int
    public var iconTintChange: Bool
}
```

**Properties:**
- `id`: Unique identifier for the sort option
- `icon`: Optional system or custom icon name
- `title`: Display text for the option
- `count`: Number of items associated with this option
- `iconTintChange`: Whether icon should change color when selected

## Protocols

### SortFilterViewModelProtocol
```swift
public protocol SortFilterViewModelProtocol {
    var title: String { get }
    var sortOptions: [SortOption] { get }
    var selectedOptionId: CurrentValueSubject<Int, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    var shouldRefreshData: PassthroughSubject<Void, Never> { get }

    func selectOption(withId id: Int)
    func toggleCollapse()
    func updateSortOptions(_ newSortOptions: [SortOption])
}
```

### SortOptionRowViewModelProtocol
```swift
public protocol SortOptionRowViewModelProtocol {
    var sortOption: SortOption { get }
}
```

## Usage Examples

### Basic Implementation
```swift
let sortOptions: [SortOption] = [
    SortOption(id: 1, icon: "flame.fill", title: "Popular", count: 25),
    SortOption(id: 2, icon: "clock.fill", title: "Upcoming", count: 15),
    SortOption(id: 3, icon: "heart.fill", title: "Favourites", count: 0)
]

let viewModel = MockSortFilterViewModel(
    title: "Sort By", 
    sortOptions: sortOptions,
    selectedId: 1
)

let sortFilterView = SortFilterView(viewModel: viewModel)

// Handle selection changes
sortFilterView.onSortFilterSelected = { selectedId in
    print("Selected option: \(selectedId)")
}
```

### Custom ViewModel Implementation
```swift
class CustomSortFilterViewModel: SortFilterViewModelProtocol {
    let title: String = "Custom Sort"
    var sortOptions: [SortOption] = []
    var selectedOptionId = CurrentValueSubject<Int, Never>(1)
    var isCollapsed = CurrentValueSubject<Bool, Never>(false)
    var shouldRefreshData = PassthroughSubject<Void, Never>()
    
    func selectOption(withId id: Int) {
        selectedOptionId.send(id)
        // Custom selection logic
    }
    
    func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }
    
    func updateSortOptions(_ newSortOptions: [SortOption]) {
        self.sortOptions = newSortOptions
        shouldRefreshData.send()
    }
}
```

### Integration in Container View
```swift
class FilterViewController: UIViewController {
    private var sortFilterView: SortFilterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSortFilter()
    }
    
    private func setupSortFilter() {
        let viewModel = MockSortFilterViewModel(
            title: "Sort By",
            sortOptions: getSortOptions()
        )
        
        sortFilterView = SortFilterView(viewModel: viewModel)
        sortFilterView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(sortFilterView)
        
        NSLayoutConstraint.activate([
            sortFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sortFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sortFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        sortFilterView.onSortFilterSelected = { [weak self] selectedId in
            self?.handleSortSelection(selectedId)
        }
    }
}
```

## Component Behavior

### Selection Logic
- Single selection mode (radio button behavior)
- Visual feedback with color changes and typography
- Left indicator appears for selected items
- Radio button fills with accent color when selected

### Collapse/Expand Animation
- Smooth 0.3 second animation duration
- Chevron icon rotation (180° when collapsed)
- Height constraint management for smooth transitions
- Alpha and visibility changes for content

### Data Updates
- Reactive updates through `shouldRefreshData` publisher
- Automatic UI refresh when sort options change
- Preserves selection state during updates
- Maintains collapse state across data refreshes

## Styling Integration

The component integrates with `StyleProvider` for consistent theming:

- **Colors**: Primary text, highlight colors, separator lines
- **Typography**: Regular and bold font variants
- **Spacing**: Consistent padding and margins
- **Corner Radius**: Rounded elements following design system

## Accessibility Features

- **Tap Targets**: Appropriately sized interactive elements
- **Visual Hierarchy**: Clear typography and color distinctions
- **State Communication**: Visual indicators for selection states
- **Touch Accessibility**: Full row tap handling for better UX

## SwiftUI Preview Support

The component includes SwiftUI preview support for design-time visualization:

```swift
@available(iOS 17.0, *)
struct SortByView_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIView {
            // Preview implementation
        }
    }
}
```

## Technical Implementation

### Memory Management
- Weak references to prevent retain cycles
- Proper Combine cancellable storage
- Automatic cleanup of observers and subscriptions

### Performance Considerations
- Efficient constraint management during animations
- Minimal layout passes during state changes
- Optimized for frequent selection updates

### Error Handling
- Graceful fallbacks for missing icons
- Safe array access patterns
- Defensive programming for state transitions

## Dependencies

- **UIKit**: Core UI framework
- **Combine**: Reactive programming and state management
- **StyleProvider**: Internal styling system
- **Foundation**: Basic data structures and utilities

## Best Practices

1. **View Model Lifecycle**: Always properly store view model references
2. **Combine Subscriptions**: Use `store(in: &cancellables)` for memory management
3. **Animation States**: Avoid interrupting ongoing animations
4. **Data Consistency**: Ensure sort options have unique IDs
5. **Accessibility**: Test with VoiceOver and Dynamic Type
6. **Performance**: Minimize frequent data updates during animations

## Future Enhancements

- Multi-selection support
- Custom animation durations
- Drag-to-reorder functionality
- Search/filter within options
- Custom row layouts and styling
- Keyboard navigation support 