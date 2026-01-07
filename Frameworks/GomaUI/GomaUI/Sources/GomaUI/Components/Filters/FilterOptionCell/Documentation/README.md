# FilterOptionCell

A versatile collection view cell built with UIKit that displays filter options with a clean, pill-shaped design. The component serves as a general-purpose filter display cell for various filter types including sports, sorting options, and leagues, featuring an icon and title in a horizontal layout.

## Overview

The `FilterOptionCell` is a custom `UICollectionViewCell` designed for displaying filter options in horizontal collection views. Unlike the specialized `SportSelectorCell`, this component provides a clean, borderless design suitable for general filter options. It follows a simple view-model pattern and integrates seamlessly with the shared `FilterOptionItem` model.

## Architecture

### Component Structure
```
FilterOptionCell/
├── FilterOptionCell.swift           # Main collection view cell
├── FilterOptionCellViewModel.swift  # View model for data binding
└── Models/
    └── FilterOptionModels.swift     # Shared data models
```

### Design Pattern
- **View**: `FilterOptionCell` - Custom collection view cell with clean styling
- **ViewModel**: `FilterOptionCellViewModel` - Simple data container for filter options
- **Model**: `FilterOptionItem` & `FilterOptionType` - Shared data structures

## Key Features

### Visual Design
- **Clean Pill Shape**: Rounded corners (21pt radius) with white background
- **No Border**: Minimalist design without borders for subtle appearance
- **Icon Integration**: System icon display with orange tint color
- **Compact Layout**: Optimized for horizontal collection view usage
- **Consistent Typography**: Bold 12pt font for filter titles

### Interactive Elements
- **Filter Icon**: Displays context-appropriate system icon
- **Title Label**: Bold filter option name display
- **Touch Feedback**: Standard collection view cell selection behavior
- **Flexible Content**: Adapts to different filter types and content

### Layout Structure
- **Horizontal Stack**: Icon and title arranged horizontally
- **Center Alignment**: All elements vertically centered
- **Consistent Spacing**: 8pt spacing between icon and title
- **Adaptive Width**: Dynamically sizes based on content

## Models

### FilterOptionItem
```swift
public struct FilterOptionItem {
    public let type: FilterOptionType
    public let title: String
    public let icon: String
}
```

**Properties:**
- `type`: Filter category (`.sport`, `.sortBy`, `.league`)
- `title`: Display text for the filter option
- `icon`: System icon name for visual representation

### FilterOptionType
```swift
public enum FilterOptionType {
    case sport
    case sortBy
    case league
}
```

**Filter Types:**
- `sport`: Sports-related filter options
- `sortBy`: Sorting and ordering options
- `league`: League and competition filters

## View Model

### FilterOptionCellViewModel
```swift
public class FilterOptionCellViewModel {
    let filterOptionItem: FilterOptionItem
    
    public init(filterOptionItem: FilterOptionItem) {
        self.filterOptionItem = filterOptionItem
    }
}
```

**Purpose:**
- Simple data container for filter option information
- Provides clean separation between data and view
- Enables easy testing and mocking
- Maintains consistency with other filter components

## Usage Examples

### Basic Collection View Implementation
```swift
class FilterViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var filterOptions: [FilterOptionItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupFilterData()
    }
    
    private func setupCollectionView() {
        collectionView.register(
            FilterOptionCell.self,
            forCellWithReuseIdentifier: "FilterOptionCell"
        )
        
        // Configure horizontal layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    private func setupFilterData() {
        filterOptions = [
            FilterOptionItem(type: .sortBy, title: "Popular", icon: "flame.fill"),
            FilterOptionItem(type: .sortBy, title: "Recent", icon: "clock.fill"),
            FilterOptionItem(type: .league, title: "Premier League", icon: "trophy.fill"),
            FilterOptionItem(type: .sport, title: "Basketball", icon: "basketball")
        ]
    }
}

extension FilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FilterOptionCell",
            for: indexPath
        ) as! FilterOptionCell
        
        let filterOption = filterOptions[indexPath.item]
        let viewModel = FilterOptionCellViewModel(filterOptionItem: filterOption)
        cell.configure(with: viewModel)
        
        return cell
    }
}
```

### Integration with GeneralFilterViewController
```swift
class GeneralFilterViewController: UIViewController {
    private var selectedFilters: [FilterOptionItem] = []
    
    func updateFilterDisplay() {
        let filterCells = createFilterCells(from: selectedFilters)
        updateCollectionView(with: filterCells)
    }
    
    private func createFilterCells(from filters: [FilterOptionItem]) -> [FilterOptionCell] {
        return filters.compactMap { filterOption in
            let cell = FilterOptionCell()
            let viewModel = FilterOptionCellViewModel(filterOptionItem: filterOption)
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func addFilter(_ filterOption: FilterOptionItem) {
        selectedFilters.append(filterOption)
        updateFilterDisplay()
    }
    
    func removeFilter(at index: Int) {
        guard index < selectedFilters.count else { return }
        selectedFilters.remove(at: index)
        updateFilterDisplay()
    }
}
```

### Filter Category Examples
```swift
class FilterDataManager {
    static func createSortOptions() -> [FilterOptionItem] {
        return [
            FilterOptionItem(type: .sortBy, title: "Popular", icon: "flame.fill"),
            FilterOptionItem(type: .sortBy, title: "Upcoming", icon: "clock.fill"),
            FilterOptionItem(type: .sortBy, title: "Favorites", icon: "heart.fill"),
            FilterOptionItem(type: .sortBy, title: "Alphabetical", icon: "textformat.abc")
        ]
    }
    
    static func createLeagueOptions() -> [FilterOptionItem] {
        return [
            FilterOptionItem(type: .league, title: "Premier League", icon: "trophy.fill"),
            FilterOptionItem(type: .league, title: "Champions League", icon: "star.fill"),
            FilterOptionItem(type: .league, title: "La Liga", icon: "soccerball"),
            FilterOptionItem(type: .league, title: "Serie A", icon: "football")
        ]
    }
    
    static func createSportOptions() -> [FilterOptionItem] {
        return [
            FilterOptionItem(type: .sport, title: "Football", icon: "soccerball"),
            FilterOptionItem(type: .sport, title: "Basketball", icon: "basketball"),
            FilterOptionItem(type: .sport, title: "Tennis", icon: "tennis.racket"),
            FilterOptionItem(type: .sport, title: "Baseball", icon: "baseball")
        ]
    }
}
```

### Dynamic Filter Management
```swift
class DynamicFilterManager {
    private var activeFilters: [FilterOptionItem] = []
    private weak var collectionView: UICollectionView?
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func addFilter(_ filter: FilterOptionItem) {
        // Prevent duplicates
        guard !activeFilters.contains(where: { $0.title == filter.title }) else { return }
        
        activeFilters.append(filter)
        refreshCollectionView()
    }
    
    func removeFilter(withTitle title: String) {
        activeFilters.removeAll { $0.title == title }
        refreshCollectionView()
    }
    
    func clearAllFilters() {
        activeFilters.removeAll()
        refreshCollectionView()
    }
    
    func getFiltersByType(_ type: FilterOptionType) -> [FilterOptionItem] {
        return activeFilters.filter { $0.type == type }
    }
    
    private func refreshCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
}
```

### Custom Filter Creation
```swift
extension FilterOptionItem {
    static func createCustomSort(title: String, systemIcon: String) -> FilterOptionItem {
        return FilterOptionItem(type: .sortBy, title: title, icon: systemIcon)
    }
    
    static func createCustomLeague(title: String, systemIcon: String) -> FilterOptionItem {
        return FilterOptionItem(type: .league, title: title, icon: systemIcon)
    }
    
    static func createCustomSport(title: String, systemIcon: String) -> FilterOptionItem {
        return FilterOptionItem(type: .sport, title: title, icon: systemIcon)
    }
}

// Usage examples
let customFilters = [
    FilterOptionItem.createCustomSort(title: "Trending", systemIcon: "arrow.up.right"),
    FilterOptionItem.createCustomLeague(title: "World Cup", systemIcon: "globe"),
    FilterOptionItem.createCustomSport(title: "Swimming", systemIcon: "figure.pool.swim")
]
```

## Component Behavior

### Visual Characteristics
- **Background**: Clean white background without borders
- **Corner Radius**: 21pt rounded corners for pill shape
- **Icon Styling**: Orange tint color using `highlightPrimary`
- **Typography**: Bold 12pt font for clear readability
- **Minimal Design**: Clean appearance without visual clutter

### Layout Behavior
- **Container Padding**: 10pt top/bottom, 8pt left/right padding
- **Icon Sizing**: Fixed 22x22pt system icons
- **Stack Spacing**: 8pt between icon and title
- **Adaptive Width**: Automatically adjusts to content length
- **Center Alignment**: Vertical centering of all elements

### Content Configuration
- **System Icons**: Uses SF Symbols with template rendering
- **Title Display**: Bold text with primary text color
- **Dynamic Updates**: Supports runtime content changes
- **Type Flexibility**: Handles multiple filter types seamlessly

## Styling Integration

The component integrates with `StyleProvider` for consistent theming:

- **Colors**:
  - `highlightPrimary`: Orange tint for icons
  - `textPrimary`: Title text color
  - White background (hardcoded for clean appearance)
- **Typography**:
  - Bold 12pt font for filter titles
- **Layout**:
  - 21pt corner radius for pill shape
  - Consistent padding and spacing

## Collection View Integration

### Cell Registration
```swift
collectionView.register(
    FilterOptionCell.self,
    forCellWithReuseIdentifier: "FilterOptionCell"
)
```

### Dynamic Sizing
```swift
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let filterOption = filterOptions[indexPath.item]
    let title = filterOption.title
    
    // Calculate text width
    let titleWidth = title.size(withAttributes: [
        .font: StyleProvider.fontWith(type: .bold, size: 12)
    ]).width
    
    // Icon (22) + spacing (8) + title + padding (16)
    let cellWidth = 22 + 8 + titleWidth + 16
    
    return CGSize(width: cellWidth, height: 42)
}
```

### Section Handling
```swift
extension FilterViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return FilterOptionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let filterType = FilterOptionType.allCases[section]
        return filterOptions.filter { $0.type == filterType }.count
    }
}
```

## Accessibility Features

- **Content Labels**: Clear filter option names for screen readers
- **Icon Semantics**: System icons provide meaningful context
- **Touch Targets**: Adequate cell size for easy interaction
- **Visual Hierarchy**: Bold typography for clear text distinction
- **Color Independence**: Information conveyed through text and icons

## Use Cases

### Active Filter Display
```swift
// Show currently applied filters
let activeFilters = [
    FilterOptionItem(type: .sortBy, title: "Popular", icon: "flame.fill"),
    FilterOptionItem(type: .league, title: "Premier League", icon: "trophy.fill")
]
```

### Filter Category Browsing
```swift
// Display available filter options by category
let sortingOptions = FilterDataManager.createSortOptions()
let leagueOptions = FilterDataManager.createLeagueOptions()
```

### Search Result Filters
```swift
// Show filters applied to search results
let searchFilters = [
    FilterOptionItem(type: .sport, title: "Football", icon: "soccerball"),
    FilterOptionItem(type: .sortBy, title: "Recent", icon: "clock.fill")
]
```

## Technical Implementation

### Memory Management
- Lightweight cell design optimized for collection view reuse
- Simple view model pattern with minimal overhead
- Proper cleanup during cell reuse cycles
- Efficient constraint setup for performance

### Performance Considerations
- Minimal view hierarchy for fast scrolling
- Efficient system icon loading and caching
- Optimized for large numbers of filter options
- Small memory footprint per cell instance

### Layout Optimization
- Stack view for efficient element arrangement
- Fixed icon constraints to prevent layout shifts
- Flexible title width with proper compression
- Consistent spacing across varying content lengths

## Error Handling

### Defensive Programming
- Safe handling of optional view model data
- Graceful fallbacks for missing system icons
- Proper validation of filter option types
- Safe string handling for empty or nil titles

### Data Validation
- FilterOptionType enum ensures type safety
- Non-empty title validation in initializers
- Valid system icon name verification
- Proper view model initialization checks

## Dependencies

- **UIKit**: Core UI framework for collection view cells
- **StyleProvider**: Internal styling and theming system
- **Foundation**: Basic data structures and utilities

## Best Practices

1. **Icon Selection**: Choose appropriate SF Symbols for each filter type
2. **Title Length**: Keep filter names concise for better layout
3. **Type Consistency**: Use appropriate FilterOptionType for each filter
4. **Collection Layout**: Ensure proper spacing and sizing in collections
5. **State Management**: Track filter selections externally to the cell
6. **Accessibility**: Provide meaningful labels for screen reader users
7. **Performance**: Use efficient cell reuse patterns for large datasets

## Integration Patterns

### With Filter State Management
```swift
class FilterStateCoordinator {
    private var activeFilters: Set<FilterOptionItem> = []
    private weak var collectionView: UICollectionView?
    
    func toggleFilter(_ filter: FilterOptionItem) {
        if activeFilters.contains(filter) {
            activeFilters.remove(filter)
        } else {
            activeFilters.insert(filter)
        }
        
        updateCollectionView()
    }
    
    func isFilterActive(_ filter: FilterOptionItem) -> Bool {
        return activeFilters.contains(filter)
    }
    
    private func updateCollectionView() {
        collectionView?.reloadData()
    }
}
```

### With Search Integration
```swift
class SearchableFilterManager {
    private let allFilters: [FilterOptionItem]
    private var filteredOptions: [FilterOptionItem] = []
    
    func searchFilters(with text: String) {
        if text.isEmpty {
            filteredOptions = allFilters
        } else {
            filteredOptions = allFilters.filter { filter in
                filter.title.localizedCaseInsensitiveContains(text)
            }
        }
        
        notifyFiltersChanged()
    }
    
    private func notifyFiltersChanged() {
        NotificationCenter.default.post(
            name: .filtersDidChange,
            object: filteredOptions
        )
    }
}
```

## Comparison with SportSelectorCell

| Feature | FilterOptionCell | SportSelectorCell |
|---------|------------------|-------------------|
| Border | None | Orange 2pt border |
| Purpose | General filters | Sport selection |
| Arrows | None | Selector arrows |
| Design | Minimal | Prominent |
| Usage | Active filters | Primary selector |

## Future Enhancements

- Support for custom filter icons beyond system images
- Badge overlay for indicating filter counts
- Animation effects for filter selection/deselection
- Custom color schemes for different filter types
- Multi-state support (active, inactive, disabled)
- Integration with haptic feedback
- Support for filter expiration/timing
- Custom corner radius and styling options
- Advanced accessibility features
- Filter grouping and categorization 