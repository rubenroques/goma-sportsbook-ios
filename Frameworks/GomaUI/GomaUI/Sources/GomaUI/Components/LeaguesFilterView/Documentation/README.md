# LeaguesFilterView

A collapsible league filter component built with UIKit and Combine that allows users to select from available sports leagues. The component features an expandable/collapsible list of league options with visual selection indicators and event count displays.

## Overview

The `LeaguesFilterView` is designed to display league filtering options in a vertical list format with a collapsible header. Each league option includes an icon (typically trophy), title, event count, and selection state. The component follows MVVM architecture and uses reactive programming with Combine for state management.

## Architecture

### Component Structure
```
LeaguesFilterView/
├── LeaguesFilterView.swift                 # Main component view
├── LeaguesFilterViewModelProtocol.swift    # View model protocol
├── MockLeaguesFilterViewModel.swift        # Mock implementation
├── LeagueOptionRowView.swift              # Individual row component
└── Models/
    └── LeaguesFilterViewModels.swift      # Data models
```

### MVVM Pattern
- **View**: `LeaguesFilterView` - Main UI component
- **ViewModel**: `LeaguesFilterViewModelProtocol` - Business logic and state management
- **Model**: `LeagueOption` - Data structure for league options
- **Sub-View**: `LeagueOptionRowView` - Individual league row component

## Key Features

### Interactive Elements
- **Collapsible Header**: Tap chevron to expand/collapse the leagues list
- **League Selection**: Single selection mode with visual feedback
- **Visual States**: Selected state with color changes and left indicator
- **Event Count Display**: Shows number of events for each league
- **Full Row Tap**: Entire row is tappable for better user experience

### Visual Design
- **Left Indicator**: Orange accent line for selected leagues
- **Icon Support**: League icons (typically trophy symbols)
- **Typography**: Bold styling for selected league names
- **Count Information**: Event count with "No Events" fallback
- **Smooth Animations**: Collapse/expand transitions with chevron rotation

### State Management
- **Reactive Updates**: Combine-based state synchronization
- **Selection Tracking**: Currently selected league management
- **Collapse State**: Expandable/collapsible interface
- **Event Callbacks**: Selection change notifications

## Models

### LeagueOption
```swift
public struct LeagueOption: Equatable {
    public let id: Int
    public let icon: String?
    public let title: String
    public let count: Int
}
```

**Properties:**
- `id`: Unique identifier for the league
- `icon`: Optional icon name (typically "trophy.fill")
- `title`: Display name of the league (e.g., "Premier League")
- `count`: Number of events/matches available in this league

## Protocols

### LeaguesFilterViewModelProtocol
```swift
public protocol LeaguesFilterViewModelProtocol {
    var leagueOptions: [LeagueOption] { get }
    var selectedOptionId: CurrentValueSubject<Int, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    
    func selectOption(withId id: Int)
    func toggleCollapse()
}
```

**Key Methods:**
- `selectOption(withId:)`: Updates the selected league
- `toggleCollapse()`: Expands/collapses the league list

## Usage Examples

### Basic Implementation
```swift
let leagueOptions = [
    LeagueOption(id: 1, icon: "trophy.fill", title: "Premier League", count: 32),
    LeagueOption(id: 2, icon: "trophy.fill", title: "La Liga", count: 28),
    LeagueOption(id: 3, icon: "trophy.fill", title: "Bundesliga", count: 25),
    LeagueOption(id: 4, icon: "trophy.fill", title: "Serie A", count: 27),
    LeagueOption(id: 5, icon: "trophy.fill", title: "Ligue 1", count: 0)
]

let viewModel = MockLeaguesFilterViewModel(
    leagueOptions: leagueOptions,
    selectedId: 1
)

let leaguesFilterView = LeaguesFilterView(viewModel: viewModel)

// Handle selection changes
leaguesFilterView.onLeagueFilterSelected = { selectedId in
    print("Selected league ID: \(selectedId)")
}
```

### Custom ViewModel Implementation
```swift
class CustomLeaguesFilterViewModel: LeaguesFilterViewModelProtocol {
    var leagueOptions: [LeagueOption] = []
    var selectedOptionId = CurrentValueSubject<Int, Never>(1)
    var isCollapsed = CurrentValueSubject<Bool, Never>(false)
    
    init(leagues: [LeagueOption]) {
        self.leagueOptions = leagues
    }
    
    func selectOption(withId id: Int) {
        selectedOptionId.send(id)
        // Custom selection logic (e.g., API calls, analytics)
        updateLeagueData(for: id)
    }
    
    func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
        // Custom collapse logic
    }
    
    private func updateLeagueData(for leagueId: Int) {
        // Update related data when league is selected
    }
}
```

### Integration in Filter Interface
```swift
class FiltersViewController: UIViewController {
    private var leaguesFilterView: LeaguesFilterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeaguesFilter()
    }
    
    private func setupLeaguesFilter() {
        let viewModel = MockLeaguesFilterViewModel(
            leagueOptions: fetchAvailableLeagues()
        )
        
        leaguesFilterView = LeaguesFilterView(viewModel: viewModel)
        leaguesFilterView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(leaguesFilterView)
        
        NSLayoutConstraint.activate([
            leaguesFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            leaguesFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leaguesFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        leaguesFilterView.onLeagueFilterSelected = { [weak self] selectedId in
            self?.applyLeagueFilter(selectedId)
        }
    }
    
    private func applyLeagueFilter(_ leagueId: Int) {
        // Apply the selected league filter to your data source
    }
}
```

## Component Behavior

### Selection Logic
- Single selection mode (only one league can be selected at a time)
- Visual feedback with background color, typography, and left indicator
- Icon tint color changes to highlight color when selected
- Event count styling updates for selected state

### Collapse/Expand Animation
- Smooth 0.3 second animation duration
- Chevron icon rotation (180° when collapsed)
- Height constraint management for smooth transitions
- Alpha and visibility changes for smooth user experience

### Row Interaction
- Full row tap gesture for better accessibility
- Visual feedback on selection
- Callback execution for selection changes
- Maintains selection state during view updates

## LeagueOptionRowView Details

The individual row component (`LeagueOptionRowView`) handles:

### Visual Elements
- **Left Indicator**: 4pt wide orange accent line
- **Icon**: 16x16pt league icon with tint color support
- **Title Label**: League name with dynamic font weight
- **Count Label**: Event count with styling variations
- **Background**: Selection state background color

### State Management
- `isSelected` property with automatic visual updates
- Configuration method for league option data
- Tap gesture handling with callback execution
- Dynamic styling based on selection state

## Styling Integration

The component integrates with `StyleProvider` for consistent theming:

- **Colors**: 
  - `highlightPrimary`: Orange accent color for selections
  - `textPrimary`: Main text color
  - `separatorLine`: Background color for selected rows
- **Typography**: 
  - Regular and bold font variants
  - Size 14 for titles, size 12 for counts
- **Spacing**: Consistent 16pt margins and 12pt padding

## League Data Examples

### Popular Football Leagues
```swift
let footballLeagues = [
    LeagueOption(id: 1, icon: "trophy.fill", title: "Premier League", count: 32),
    LeagueOption(id: 2, icon: "trophy.fill", title: "La Liga", count: 28),
    LeagueOption(id: 3, icon: "trophy.fill", title: "Bundesliga", count: 25),
    LeagueOption(id: 4, icon: "trophy.fill", title: "Serie A", count: 27),
    LeagueOption(id: 5, icon: "trophy.fill", title: "Champions League", count: 16),
    LeagueOption(id: 6, icon: "trophy.fill", title: "Europa League", count: 12)
]
```

### Multi-Sport Leagues
```swift
let multiSportLeagues = [
    LeagueOption(id: 10, icon: "trophy.fill", title: "NFL", count: 42),
    LeagueOption(id: 11, icon: "trophy.fill", title: "NBA", count: 38),
    LeagueOption(id: 12, icon: "trophy.fill", title: "MLB", count: 65),
    LeagueOption(id: 13, icon: "trophy.fill", title: "NHL", count: 28)
]
```

## Accessibility Features

- **Tap Targets**: Full row touch areas (56pt height minimum)
- **Visual Hierarchy**: Clear typography and color distinctions
- **State Communication**: Multiple visual indicators for selection
- **Dynamic Type**: Font scaling support through StyleProvider
- **Contrast**: Appropriate color contrasts for text readability

## SwiftUI Preview Support

The component includes comprehensive SwiftUI preview with realistic data:

```swift
@available(iOS 17.0, *)
struct LeaguesFilterView_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIView {
            // Preview with 10 sample leagues
        }
        .frame(height: 900)
        .background(Color(uiColor: .systemGray6))
    }
}
```

## Technical Implementation

### Memory Management
- Weak references in closures to prevent retain cycles
- Proper Combine cancellable storage with `Set<AnyCancellable>`
- Automatic cleanup of gesture recognizers and observers

### Performance Considerations
- Efficient constraint management during animations
- Lazy loading of row views in stack view
- Optimized for large league lists (100+ leagues)
- Minimal layout passes during state changes

### Animation Performance
- Hardware-accelerated transforms for chevron rotation
- Efficient height constraint animations
- Proper animation completion handling
- Smooth 60fps animations on supported devices

## Error Handling

### Defensive Programming
- Safe array access patterns
- Graceful fallbacks for missing icons
- Proper nil checking for optional league data
- Safe state transitions during animations

### Data Validation
- Unique ID requirements for league options
- Count value validation (non-negative)
- Title validation (non-empty strings)
- Icon existence verification

## Dependencies

- **UIKit**: Core UI framework and animations
- **Combine**: Reactive programming and state management  
- **StyleProvider**: Internal styling and theming system
- **Foundation**: Basic data structures and utilities

## Best Practices

1. **Data Consistency**: Ensure all league options have unique IDs
2. **Memory Management**: Always use weak references in closures
3. **Animation Timing**: Don't interrupt ongoing collapse/expand animations
4. **State Synchronization**: Keep view model and UI state in sync
5. **Accessibility Testing**: Test with VoiceOver and Dynamic Type
6. **Performance**: Monitor memory usage with large league datasets
7. **Icon Management**: Provide fallbacks for missing league icons

## Integration Patterns

### With Other Filter Components
```swift
// Coordinate with other filters
func setupMultipleFilters() {
    let sportsFilter = SportGamesFilterView(viewModel: sportsViewModel)
    let leaguesFilter = LeaguesFilterView(viewModel: leaguesViewModel)
    let sortFilter = SortFilterView(viewModel: sortViewModel)
    
    // Stack them vertically
    let stackView = UIStackView(arrangedSubviews: [
        sportsFilter, leaguesFilter, sortFilter
    ])
    stackView.axis = .vertical
    stackView.spacing = 16
}
```

### With Data Sources
```swift
// Connect to data source
leaguesFilterView.onLeagueFilterSelected = { [weak self] leagueId in
    self?.dataSource.filterByLeague(id: leagueId)
    self?.refreshUI()
}
```

## Future Enhancements

- Multi-selection support with checkboxes
- Search functionality within leagues
- Drag-to-reorder league preferences
- Custom league grouping (by region, sport type)
- League favorite/bookmark functionality
- Dynamic league loading with pagination
- League logos instead of generic trophy icons
- Custom animation styles and durations 