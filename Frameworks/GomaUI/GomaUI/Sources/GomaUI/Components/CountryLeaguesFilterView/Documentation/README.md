# CountryLeaguesFilterView

A hierarchical, collapsible filter component built with UIKit and Combine that allows users to browse and select leagues organized by country. The component features a two-level structure with expandable country sections containing their respective leagues, complete with visual selection indicators and event counts.

## Overview

The `CountryLeaguesFilterView` displays leagues grouped by country in an expandable/collapsible interface. Each country can be expanded to reveal its leagues, and users can select individual leagues within any country. The component follows MVVM architecture and uses reactive programming with Combine for state management across multiple nested levels.

## Architecture

### Component Structure
```
CountryLeaguesFilterView/
├── CountryLeaguesFilterView.swift                     # Main component view
├── CountryLeaguesFilterViewModelProtocol.swift        # View model protocol
├── MockCountryLeaguesFilterViewModel.swift            # Mock implementation
├── CountryLeagueOptionRowView/
│   ├── CountryLeagueOptionRowView.swift               # Country header row
│   ├── CountryLeagueOptionRowViewModelProtocol.swift  # Country row protocol
│   └── MockCountryLeagueOptionRowViewModel.swift     # Country row mock
├── LeagueOptionSelectionRowView/
│   ├── LeagueOptionSelectionRowView.swift             # Individual league row
│   ├── LeagueOptionSelectionRowViewModelProtocol.swift # League row protocol
│   └── MockLeagueOptionSelectionRowViewModel.swift   # League row mock
└── Models/
    └── CountryLeaguesModels.swift                     # Data models
```

### MVVM Pattern
- **View**: `CountryLeaguesFilterView` - Main hierarchical filter component
- **ViewModel**: `CountryLeaguesFilterViewModelProtocol` - Business logic and state management
- **Model**: `CountryLeagueOptions` - Data structure for country-league relationships
- **Sub-Views**: Country and league row components with their own view models

## Key Features

### Hierarchical Structure
- **Country Headers**: Expandable sections with country flags and total counts
- **League Lists**: Nested leagues within each country with individual selection
- **Two-Level Navigation**: Country expansion and league selection
- **Visual Hierarchy**: Clear distinction between country headers and league items

### Interactive Elements
- **Country Expansion**: Tap country headers to expand/collapse league lists
- **League Selection**: Individual league selection with radio button interface
- **Main Collapse**: Global collapse/expand functionality for entire component
- **Visual Feedback**: Multiple levels of selection and state indicators

### Visual Design
- **Country Indicators**: Left accent lines for countries containing selected leagues
- **League Selection**: Radio buttons with visual selection states
- **Count Displays**: Event counts for both countries and individual leagues
- **Smooth Animations**: Coordinated expand/collapse transitions across levels
- **Flag Icons**: Country flag support for visual identification

### State Management
- **Multi-Level State**: Country expansion and league selection states
- **Reactive Updates**: Combine-based synchronization across all levels
- **Selection Propagation**: Country selection state based on contained leagues
- **Dynamic Updates**: Support for refreshing country and league data

## Models

### CountryLeagueOptions
```swift
public struct CountryLeagueOptions: Equatable {
    public let id: Int
    public let icon: String?
    public let title: String
    public var leagues: [LeagueOption]
    public var isExpanded: Bool
}
```

**Properties:**
- `id`: Unique identifier for the country
- `icon`: Optional country flag icon name
- `title`: Country display name (e.g., "England", "Spain")
- `leagues`: Array of leagues within this country
- `isExpanded`: Current expansion state of the country section

### Integration with LeagueOption
The component reuses the `LeagueOption` model from other filter components:
```swift
public struct LeagueOption: Equatable {
    public let id: Int
    public let icon: String?
    public let title: String
    public let count: Int
}
```

## Protocols

### CountryLeaguesFilterViewModelProtocol
```swift
public protocol CountryLeaguesFilterViewModelProtocol {
    var title: String { get }
    var countryLeagueOptions: [CountryLeagueOptions] { get }
    var selectedOptionId: CurrentValueSubject<Int, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    var shouldRefreshData: PassthroughSubject<Void, Never> { get }

    func toggleCollapse()
    func toggleCountryExpansion(at index: Int)
    func updateCountryLeagueOptions(_ newSortOptions: [CountryLeagueOptions])
}
```

**Key Methods:**
- `toggleCollapse()`: Collapses/expands the entire component
- `toggleCountryExpansion(at:)`: Expands/collapses individual country sections
- `updateCountryLeagueOptions(_:)`: Updates the data and refreshes UI

## Usage Examples

### Basic Implementation
```swift
let countryLeagueOptions = [
    CountryLeagueOptions(
        id: 1,
        icon: "england_flag",
        title: "England",
        leagues: [
            LeagueOption(id: 1, icon: nil, title: "Premier League", count: 25),
            LeagueOption(id: 2, icon: nil, title: "Championship", count: 24),
            LeagueOption(id: 3, icon: nil, title: "League One", count: 22)
        ],
        isExpanded: true
    ),
    CountryLeagueOptions(
        id: 2,
        icon: "spain_flag",
        title: "Spain",
        leagues: [
            LeagueOption(id: 16, icon: nil, title: "La Liga", count: 20),
            LeagueOption(id: 17, icon: nil, title: "La Liga 2", count: 22)
        ],
        isExpanded: false
    )
]

let viewModel = MockCountryLeaguesFilterViewModel(
    title: "Popular Countries",
    countryLeagueOptions: countryLeagueOptions
)

let countryLeaguesFilterView = CountryLeaguesFilterView(viewModel: viewModel)

// Handle league selection
countryLeaguesFilterView.onLeagueFilterSelected = { selectedLeagueId in
    print("Selected league ID: \(selectedLeagueId)")
}
```

### Custom ViewModel Implementation
```swift
class CustomCountryLeaguesFilterViewModel: CountryLeaguesFilterViewModelProtocol {
    var title: String = "Countries & Leagues"
    var countryLeagueOptions: [CountryLeagueOptions] = []
    var selectedOptionId = CurrentValueSubject<Int, Never>(0)
    var isCollapsed = CurrentValueSubject<Bool, Never>(false)
    var shouldRefreshData = PassthroughSubject<Void, Never>()
    
    private let apiService: LeagueAPIService
    
    init(apiService: LeagueAPIService) {
        self.apiService = apiService
        loadCountryLeagues()
    }
    
    func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }
    
    func toggleCountryExpansion(at index: Int) {
        guard index < countryLeagueOptions.count else { return }
        countryLeagueOptions[index].isExpanded.toggle()
        
        // Save expansion preferences
        UserDefaults.standard.set(
            countryLeagueOptions[index].isExpanded,
            forKey: "country_\(countryLeagueOptions[index].id)_expanded"
        )
    }
    
    func updateCountryLeagueOptions(_ newOptions: [CountryLeagueOptions]) {
        self.countryLeagueOptions = newOptions
        shouldRefreshData.send()
    }
    
    private func loadCountryLeagues() {
        apiService.fetchCountryLeagues { [weak self] result in
            switch result {
            case .success(let options):
                self?.updateCountryLeagueOptions(options)
            case .failure(let error):
                // Handle error
                print("Failed to load country leagues: \(error)")
            }
        }
    }
}
```

### Integration in Filter Interface
```swift
class FiltersViewController: UIViewController {
    private var countryLeaguesFilterView: CountryLeaguesFilterView!
    private var selectedLeagueIds: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCountryLeaguesFilter()
    }
    
    private func setupCountryLeaguesFilter() {
        let countryData = loadCountryLeagueData()
        let viewModel = MockCountryLeaguesFilterViewModel(
            title: "Browse by Country",
            countryLeagueOptions: countryData
        )
        
        countryLeaguesFilterView = CountryLeaguesFilterView(viewModel: viewModel)
        countryLeaguesFilterView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(countryLeaguesFilterView)
        
        NSLayoutConstraint.activate([
            countryLeaguesFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            countryLeaguesFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            countryLeaguesFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        countryLeaguesFilterView.onLeagueFilterSelected = { [weak self] leagueId in
            self?.handleLeagueSelection(leagueId)
        }
    }
    
    private func handleLeagueSelection(_ leagueId: Int) {
        if selectedLeagueIds.contains(leagueId) {
            selectedLeagueIds.remove(leagueId)
        } else {
            selectedLeagueIds.insert(leagueId)
        }
        
        updateFilteredContent()
    }
}
```

### Multi-Selection Support
```swift
class MultiSelectCountryLeaguesViewModel: CountryLeaguesFilterViewModelProtocol {
    var selectedLeagueIds = CurrentValueSubject<Set<Int>, Never>([])
    
    func selectLeague(_ leagueId: Int) {
        var current = selectedLeagueIds.value
        if current.contains(leagueId) {
            current.remove(leagueId)
        } else {
            current.insert(leagueId)
        }
        selectedLeagueIds.send(current)
    }
    
    func clearAllSelections() {
        selectedLeagueIds.send([])
    }
    
    func selectAllLeaguesInCountry(_ countryId: Int) {
        guard let country = countryLeagueOptions.first(where: { $0.id == countryId }) else { return }
        
        var current = selectedLeagueIds.value
        country.leagues.forEach { league in
            current.insert(league.id)
        }
        selectedLeagueIds.send(current)
    }
}
```

## Component Behavior

### Hierarchical Selection Logic
- **League Selection**: Individual leagues can be selected within any country
- **Country Indication**: Countries show selection state if they contain selected leagues
- **Visual Hierarchy**: Clear distinction between country headers and league items
- **State Propagation**: Country selection state reflects contained league selections

### Expansion/Collapse Behavior
- **Country Expansion**: Individual countries can be expanded/collapsed independently
- **Global Collapse**: Main component can be collapsed hiding all countries
- **Animation Coordination**: Smooth transitions across multiple levels
- **State Persistence**: Expansion states maintained during data updates

### Visual Feedback System
- **Country Headers**: Left indicators for countries with selected leagues
- **League Rows**: Radio button selection with color changes
- **Count Updates**: Real-time event count displays
- **Smooth Animations**: 0.3 second transitions for all state changes

## Sub-Component Details

### CountryLeagueOptionRowView
The country header component handles:

#### Visual Elements
- **Country Flag**: Flag icon display (16x16pt)
- **Country Name**: Bold country title
- **Total Count**: Aggregate event count for all leagues
- **Expand/Collapse Chevron**: Animated rotation indicator
- **Left Indicator**: Orange accent line when containing selected leagues

#### Functionality
- Individual country expand/collapse
- Selection state management
- League count aggregation
- Nested league list management

### LeagueOptionSelectionRowView
The individual league component handles:

#### Visual Elements
- **League Name**: League title with indentation (40pt left margin)
- **Event Count**: Individual league event count
- **Radio Button**: Selection indicator with filled state
- **Bottom Separator**: Visual separation between leagues

#### Functionality
- Individual league selection
- Visual selection feedback
- Event count display
- Radio button state management

## Country Data Examples

### European Football Countries
```swift
let europeanCountries = [
    CountryLeagueOptions(
        id: 1,
        icon: "england_flag",
        title: "England",
        leagues: [
            LeagueOption(id: 1, icon: nil, title: "Premier League", count: 25),
            LeagueOption(id: 2, icon: nil, title: "Championship", count: 24),
            LeagueOption(id: 3, icon: nil, title: "FA Cup", count: 18)
        ],
        isExpanded: false
    ),
    CountryLeagueOptions(
        id: 2,
        icon: "spain_flag", 
        title: "Spain",
        leagues: [
            LeagueOption(id: 16, icon: nil, title: "La Liga", count: 20),
            LeagueOption(id: 17, icon: nil, title: "Copa del Rey", count: 15)
        ],
        isExpanded: false
    )
]
```

### International Competitions
```swift
let internationalCompetitions = [
    CountryLeagueOptions(
        id: 99,
        icon: "international_flag",
        title: "International",
        leagues: [
            LeagueOption(id: 101, icon: nil, title: "Champions League", count: 32),
            LeagueOption(id: 102, icon: nil, title: "Europa League", count: 24),
            LeagueOption(id: 103, icon: nil, title: "World Cup Qualifiers", count: 28)
        ],
        isExpanded: true
    )
]
```

## Styling Integration

The component integrates with `StyleProvider` for consistent theming:

- **Colors**:
  - `highlightPrimary`: Orange accent for indicators and selections
  - `textPrimary`: Main text color for titles
  - `separatorLine`: Background color for selected items
  - `allWhite`: Radio button and dot colors
- **Typography**:
  - Bold 14pt for country names and selected leagues
  - Regular 14pt for unselected league names
  - Regular 12pt for count displays
- **Spacing**:
  - 16pt margins for main elements
  - 40pt left margin for league indentation
  - 4pt indicator width

## Accessibility Features

- **Clear Hierarchy**: Visual and structural distinction between levels
- **Touch Targets**: Appropriate sizes for country headers and league rows
- **State Communication**: Multiple visual indicators for selection states
- **Logical Navigation**: Intuitive expand/collapse behavior
- **Screen Reader Support**: Proper accessibility labels and hints

## Performance Considerations

### Efficient Updates
- Selective row updates during selection changes
- Optimized constraint management during animations
- Efficient state propagation across hierarchical structure
- Minimal layout calculations for large country/league lists

### Memory Management
- Weak references in nested callbacks
- Proper Combine cancellable storage across multiple levels
- Efficient view recycling for large datasets
- Automatic cleanup of nested components

## Integration Patterns

### With Other Filter Components
```swift
class CombinedFiltersViewController: UIViewController {
    private var sportsFilter: SportGamesFilterView!
    private var countryLeaguesFilter: CountryLeaguesFilterView!
    private var sortFilter: SortFilterView!
    
    func setupCombinedFilters() {
        let stackView = UIStackView(arrangedSubviews: [
            sportsFilter,
            countryLeaguesFilter,
            sortFilter
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        // Coordinate filter selections
        countryLeaguesFilter.onLeagueFilterSelected = { [weak self] leagueId in
            self?.syncFilters(selectedLeague: leagueId)
        }
    }
}
```

### With Search Functionality
```swift
class SearchableCountryLeaguesFilter {
    private let originalData: [CountryLeagueOptions]
    private let filterView: CountryLeaguesFilterView
    
    func filterBySearch(_ searchText: String) {
        let filteredData = originalData.compactMap { country in
            let filteredLeagues = country.leagues.filter { league in
                league.title.localizedCaseInsensitiveContains(searchText)
            }
            
            guard !filteredLeagues.isEmpty else { return nil }
            
            return CountryLeagueOptions(
                id: country.id,
                icon: country.icon,
                title: country.title,
                leagues: filteredLeagues,
                isExpanded: true // Expand when filtering
            )
        }
        
        filterView.viewModel.updateCountryLeagueOptions(filteredData)
    }
}
```

## Error Handling

### Data Validation
- Unique ID validation for countries and leagues
- Non-empty league arrays for countries
- Valid country flag icon verification
- Proper count value validation (non-negative)

### State Management
- Safe array access patterns
- Graceful handling of missing country data
- Proper state synchronization across levels
- Recovery from inconsistent selection states

## Dependencies

- **UIKit**: Core UI framework and animations
- **Combine**: Reactive programming and multi-level state management
- **StyleProvider**: Internal styling and theming system
- **Foundation**: Basic data structures and utilities

## Best Practices

1. **Data Consistency**: Ensure unique IDs across all countries and leagues
2. **Memory Management**: Use weak references in nested callback chains
3. **State Synchronization**: Keep country and league selection states consistent
4. **Performance**: Monitor memory usage with large country/league datasets
5. **User Experience**: Provide clear visual feedback for hierarchical navigation
6. **Accessibility**: Test with VoiceOver for proper hierarchy navigation
7. **Animation Timing**: Coordinate expand/collapse animations across levels

## Future Enhancements

- Multi-selection support with checkboxes
- Search and filter functionality within countries/leagues
- Drag-to-reorder favorite countries
- Country grouping by region (Europe, Americas, etc.)
- League favorites and bookmarking
- Dynamic loading with pagination for large datasets
- Custom country flag support beyond predefined assets
- Keyboard navigation support for accessibility
- Export/import of country/league preferences
- Advanced filtering (by league type, division level, etc.)
- Integration with live data updates for event counts
- Custom expansion animations and effects 