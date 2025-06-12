# SportSelectorCell

A specialized collection view cell built with UIKit that displays a sport selection option with an orange-bordered, pill-shaped design. The component is specifically designed for sport filtering interfaces and features an icon, title, and selector arrows to indicate its interactive nature.

## Overview

The `SportSelectorCell` is a custom `UICollectionViewCell` designed to be the first item in filter selection interfaces, specifically for sport filtering. It provides a distinctive orange-bordered appearance that stands out from other filter options and clearly indicates its role as a primary selector. The component follows a simple view-model pattern for data binding.

## Architecture

### Component Structure
```
SportSelectorCell/
├── SportSelectorCell.swift           # Main collection view cell
└── SportSelectorCellViewModel.swift  # View model for data binding
```

### Design Pattern
- **View**: `SportSelectorCell` - Custom collection view cell with distinctive styling
- **ViewModel**: `SportSelectorCellViewModel` - Simple data container for filter option
- **Model**: `FilterOptionItem` - Shared data structure for filter options

## Key Features

### Visual Design
- **Orange Border**: Distinctive 2pt orange border using `StyleProvider.Color.highlightPrimary`
- **Pill Shape**: Rounded corners (21pt radius) for modern appearance
- **White Background**: Clean white background for contrast
- **Compact Layout**: Optimized for horizontal collection view usage
- **Icon Support**: System icon display with tint color matching theme

### Interactive Elements
- **Sport Icon**: Displays sport-specific system icon
- **Title Label**: Bold sport name display
- **Selector Arrows**: Visual indicator showing interactive/expandable nature
- **Touch Feedback**: Standard collection view cell selection behavior

### Layout Structure
- **Horizontal Stack**: Icon, title, and arrows arranged horizontally
- **Center Alignment**: All elements vertically centered
- **Consistent Spacing**: 8pt spacing between stack elements
- **Flexible Width**: Adapts to content with proper padding

## Models

### FilterOptionItem Integration
The component uses the shared `FilterOptionItem` model:
```swift
public struct FilterOptionItem {
    public let type: FilterOptionType
    public let title: String
    public let icon: String
}
```

**Properties:**
- `type`: Filter type (`.sport` for SportSelectorCell)
- `title`: Sport name (e.g., "Football", "Basketball")
- `icon`: System icon name for the sport

### FilterOptionType
```swift
public enum FilterOptionType {
    case sport
    case sortBy
    case league
}
```

The `SportSelectorCell` specifically handles `.sport` type options.

## View Model

### SportSelectorCellViewModel
```swift
public class SportSelectorCellViewModel {
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

## Usage Examples

### Basic Collection View Implementation
```swift
class FilterCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var filterOptions: [FilterOptionItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupFilterData()
    }
    
    private func setupCollectionView() {
        collectionView.register(
            SportSelectorCell.self,
            forCellWithReuseIdentifier: "SportSelectorCell"
        )
        
        // Setup layout for horizontal scrolling
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
        }
    }
    
    private func setupFilterData() {
        filterOptions = [
            FilterOptionItem(type: .sport, title: "Football", icon: "soccerball"),
            FilterOptionItem(type: .sport, title: "Basketball", icon: "basketball"),
            FilterOptionItem(type: .sport, title: "Tennis", icon: "tennis.racket")
        ]
    }
}

extension FilterCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SportSelectorCell",
            for: indexPath
        ) as! SportSelectorCell
        
        let filterOption = filterOptions[indexPath.item]
        let viewModel = SportSelectorCellViewModel(filterOptionItem: filterOption)
        cell.configure(with: viewModel)
        
        return cell
    }
}
```

### Integration with GeneralFilterViewController
```swift
class GeneralFilterViewController: UIViewController {
    private var sportSelectorCell: SportSelectorCell!
    
    func setupSportSelector() {
        let sportOption = FilterOptionItem(
            type: .sport,
            title: "All Sports",
            icon: "sportscourt"
        )
        
        let viewModel = SportSelectorCellViewModel(filterOptionItem: sportOption)
        
        // Configure as first item in collection view
        sportSelectorCell.configure(with: viewModel)
    }
    
    func handleSportSelectorTap() {
        // Present sport selection interface
        presentSportSelectionModal()
    }
}
```

### Custom Sport Options
```swift
class SportFilterManager {
    static func createSportOptions() -> [FilterOptionItem] {
        return [
            FilterOptionItem(type: .sport, title: "Football", icon: "soccerball"),
            FilterOptionItem(type: .sport, title: "Basketball", icon: "basketball"),
            FilterOptionItem(type: .sport, title: "Baseball", icon: "baseball"),
            FilterOptionItem(type: .sport, title: "Tennis", icon: "tennis.racket"),
            FilterOptionItem(type: .sport, title: "Hockey", icon: "hockey.puck"),
            FilterOptionItem(type: .sport, title: "Golf", icon: "golf.fill"),
            FilterOptionItem(type: .sport, title: "American Football", icon: "football"),
            FilterOptionItem(type: .sport, title: "Swimming", icon: "figure.pool.swim")
        ]
    }
    
    static func createDefaultSportSelector() -> FilterOptionItem {
        return FilterOptionItem(
            type: .sport,
            title: "Select Sport",
            icon: "sportscourt.fill"
        )
    }
}
```

### Dynamic Content Updates
```swift
class DynamicSportSelector {
    private let cell: SportSelectorCell
    private var currentSport: String = "All Sports"
    
    init(cell: SportSelectorCell) {
        self.cell = cell
    }
    
    func updateSelectedSport(_ sportName: String, icon: String) {
        currentSport = sportName
        
        let updatedOption = FilterOptionItem(
            type: .sport,
            title: sportName,
            icon: icon
        )
        
        let viewModel = SportSelectorCellViewModel(filterOptionItem: updatedOption)
        cell.configure(with: viewModel)
    }
    
    func resetToDefault() {
        updateSelectedSport("All Sports", icon: "sportscourt")
    }
}
```

## Component Behavior

### Visual Characteristics
- **Border Styling**: 2pt orange border using `highlightPrimary` color
- **Corner Radius**: 21pt rounded corners for pill shape
- **Background**: Clean white background for contrast
- **Tint Colors**: Orange tint for icons matching theme
- **Typography**: Bold 12pt font for sport titles

### Layout Behavior
- **Fixed Heights**: Container with 10pt top/bottom padding
- **Flexible Width**: Adapts to content with 8pt side padding
- **Icon Sizing**: Fixed 22x22pt sport icons
- **Arrow Sizing**: Fixed 12x16pt selector arrows
- **Stack Spacing**: 8pt between elements

### Content Configuration
- **Icon Display**: System icons with template rendering mode
- **Title Display**: Bold text with primary text color
- **Selector Arrows**: Custom "selector_icon" image
- **Dynamic Updates**: Support for runtime content changes

## Styling Integration

The component integrates with `StyleProvider` for consistent theming:

- **Colors**:
  - `highlightPrimary`: Orange border and icon tint color
  - `textPrimary`: Title text color
  - White background (hardcoded for contrast)
- **Typography**:
  - Bold 12pt font for sport titles
- **Border**:
  - 2pt border width
  - 21pt corner radius for pill shape

## Collection View Integration

### Cell Registration
```swift
collectionView.register(
    SportSelectorCell.self,
    forCellWithReuseIdentifier: "SportSelectorCell"
)
```

### Recommended Layout
```swift
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // Dynamic width based on content
    let title = filterOptions[indexPath.item].title
    let titleWidth = title.size(withAttributes: [
        .font: StyleProvider.fontWith(type: .bold, size: 12)
    ]).width
    
    // Icon (22) + spacing (8) + title + spacing (8) + arrow (12) + padding (16)
    let cellWidth = 22 + 8 + titleWidth + 8 + 12 + 16
    
    return CGSize(width: cellWidth, height: 42)
}
```

## Accessibility Features

- **Content Labels**: Clear sport names for screen readers
- **Icon Descriptions**: System icons provide semantic meaning
- **Touch Targets**: Adequate cell size for easy interaction
- **Visual Hierarchy**: Bold typography for clear text hierarchy
- **Color Contrast**: Orange border on white background for visibility

## Use Cases

### Primary Sport Filter
```swift
// First item in filter collection showing currently selected sport
let primarySportFilter = FilterOptionItem(
    type: .sport,
    title: "Football",
    icon: "soccerball"
)
```

### Multi-Sport Interface
```swift
// Multiple sport options in horizontal collection
let sportOptions = [
    FilterOptionItem(type: .sport, title: "All Sports", icon: "sportscourt"),
    FilterOptionItem(type: .sport, title: "Football", icon: "soccerball"),
    FilterOptionItem(type: .sport, title: "Basketball", icon: "basketball")
]
```

### Sport Category Selector
```swift
// General sport category selection
let categorySelector = FilterOptionItem(
    type: .sport,
    title: "Team Sports",
    icon: "person.3"
)
```

## Technical Implementation

### Memory Management
- Lightweight cell design with minimal retain cycles
- Efficient view model pattern with simple data container
- Proper cleanup in cell reuse scenarios

### Performance Considerations
- Minimal constraint setup for fast scrolling
- Efficient image loading with system icons
- Optimized for horizontal collection view usage
- Small memory footprint per cell

### Layout Optimization
- Stack view for efficient element arrangement
- Fixed icon sizes to prevent layout shifts
- Flexible title width with compression resistance
- Consistent padding across different content lengths

## Error Handling

### Defensive Programming
- Safe unwrapping of optional view model data
- Graceful fallbacks for missing icons
- Proper handling of empty or nil titles
- Safe system icon loading with fallbacks

### Data Validation
- FilterOptionItem type checking for `.sport` type
- Non-empty title validation
- Valid system icon name verification
- Proper view model initialization

## Dependencies

- **UIKit**: Core UI framework for collection view cell
- **StyleProvider**: Internal styling and theming system
- **Foundation**: Basic data structures and utilities

## Best Practices

1. **Content Consistency**: Use appropriate system icons for each sport
2. **Title Length**: Keep sport names concise for better layout
3. **Icon Selection**: Choose recognizable sport-specific icons
4. **Collection Layout**: Position as first item in filter collections
5. **State Management**: Update content when sport selection changes
6. **Accessibility**: Provide clear labels for screen reader support
7. **Performance**: Use efficient cell reuse patterns in collections

## Integration Patterns

### With Sport Filter Interface
```swift
class SportFilterCoordinator {
    private let sportSelectorCell: SportSelectorCell
    private var availableSports: [FilterOptionItem]
    
    func presentSportSelection() {
        // Show sport selection modal/popover
        let sportSelectionVC = SportSelectionViewController(sports: availableSports)
        sportSelectionVC.onSportSelected = { [weak self] selectedSport in
            self?.updateSportSelector(with: selectedSport)
        }
        
        present(sportSelectionVC, animated: true)
    }
    
    private func updateSportSelector(with sport: FilterOptionItem) {
        let viewModel = SportSelectorCellViewModel(filterOptionItem: sport)
        sportSelectorCell.configure(with: viewModel)
    }
}
```

### With Filter State Management
```swift
class FilterStateManager {
    private var selectedSport: FilterOptionItem?
    private let sportSelectorCell: SportSelectorCell
    
    func updateSportFilter(_ sport: FilterOptionItem) {
        selectedSport = sport
        
        let viewModel = SportSelectorCellViewModel(filterOptionItem: sport)
        sportSelectorCell.configure(with: viewModel)
        
        // Notify other components of sport change
        NotificationCenter.default.post(
            name: .sportFilterChanged,
            object: sport
        )
    }
}

extension Notification.Name {
    static let sportFilterChanged = Notification.Name("sportFilterChanged")
}
```

## Future Enhancements

- Support for custom sport icons beyond system images
- Badge overlay for indicating active sport filters
- Animation effects for sport selection changes
- Custom color themes for different sports
- Multi-sport selection support
- Integration with haptic feedback
- Support for sport category grouping
- Dynamic sizing based on content
- Custom selector arrow designs
- Accessibility improvements for VoiceOver 