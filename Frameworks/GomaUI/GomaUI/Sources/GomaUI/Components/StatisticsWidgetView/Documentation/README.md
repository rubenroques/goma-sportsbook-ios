# StatisticsWidgetView

A sophisticated statistics widget component that displays match statistics in a paginated, scrollable interface with tab navigation.

## Overview

`StatisticsWidgetView` is a UIKit-based component that combines a tab selector with multiple web views containing statistics content. Users can switch between different statistics categories (Head to Head, Form, Team Stats, Last Matches) either by tapping tabs or swiping horizontally through the content.

## Features

- **Paginated Content**: Horizontal scroll view with snap-to-page behavior
- **Tab Navigation**: Synchronized tab selection and scroll position
- **Multiple Web Views**: Each tab has its own WKWebView to avoid reloading
- **User Interaction Control**: Web views have disabled interaction, only tabs and swiping work
- **Loading States**: Individual loading states per tab with visual feedback
- **Error Handling**: Graceful error display with retry capabilities
- **Responsive Design**: Adapts to different screen sizes and orientations

## Architecture

The component follows the MVVM pattern with a protocol-based design:

```
StatisticsWidgetView (UIView)
├── MarketGroupSelectorTabView (tab navigation)
└── UIScrollView (horizontal, paginated)
    ├── WKWebView (Head to Head)
    ├── WKWebView (Form)
    ├── WKWebView (Team Stats)
    └── WKWebView (Last Matches)
```

## Usage

### Basic Implementation

```swift
import GomaUI

class MatchDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create statistics widget with mock data
        let viewModel = MockStatisticsWidgetViewModel.footballMatch
        let statisticsWidget = StatisticsWidgetView(viewModel: viewModel)
        
        view.addSubview(statisticsWidget)
        statisticsWidget.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statisticsWidget.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statisticsWidget.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statisticsWidget.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statisticsWidget.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
}
```

### Custom Statistics Implementation

```swift
// Create custom tabs
let tabs = [
    StatisticsTabData(
        id: "custom_h2h",
        title: "Head to Head",
        htmlContent: generateCustomHTML(),
        loadingState: .loaded
    ),
    StatisticsTabData(
        id: "custom_form",
        title: "Recent Form",
        loadingState: .loading
    )
]

// Create custom data
let statisticsData = StatisticsWidgetData(
    id: "custom_match_stats",
    tabs: tabs,
    selectedTabIndex: 0
)

// Create custom view model
let customViewModel = MockStatisticsWidgetViewModel(data: statisticsData)
let statisticsWidget = StatisticsWidgetView(viewModel: customViewModel)
```

## View Model Protocol

### StatisticsWidgetViewModelProtocol

The main protocol that defines the interface for statistics data management:

```swift
public protocol StatisticsWidgetViewModelProtocol {
    // Publishers
    var statisticsDataPublisher: AnyPublisher<StatisticsWidgetData, Never> { get }
    var tabsPublisher: AnyPublisher<[StatisticsTabData], Never> { get }
    var selectedTabIndexPublisher: AnyPublisher<Int, Never> { get }
    var selectedTabIdPublisher: AnyPublisher<String?, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    
    // Actions
    func selectTab(id: String)
    func selectTab(index: Int)
    func loadContent(for tabId: String)
    func retryFailedLoad(for tabId: String)
    func refreshAllContent()
}
```

### Data Models

#### StatisticsTabData

```swift
public struct StatisticsTabData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let htmlContent: String
    public let loadingState: StatisticsLoadingState
}
```

#### StatisticsLoadingState

```swift
public enum StatisticsLoadingState: Equatable, Hashable {
    case notLoaded
    case loading
    case loaded
    case error(String)
}
```

#### StatisticsWidgetData

```swift
public struct StatisticsWidgetData: Equatable, Hashable {
    public let id: String
    public let tabs: [StatisticsTabData]
    public let selectedTabIndex: Int
}
```

## Mock Data

The component includes comprehensive mock data for development and testing:

### Available Mock Scenarios

```swift
// Football match with all statistics
let footballStats = MockStatisticsWidgetViewModel.footballMatch

// Tennis match with limited tabs
let tennisStats = MockStatisticsWidgetViewModel.tennisMatch

// Loading state demonstration
let loadingDemo = MockStatisticsWidgetViewModel.loadingState

// Error state demonstration
let errorDemo = MockStatisticsWidgetViewModel.errorState

// Empty state
let emptyDemo = MockStatisticsWidgetViewModel.emptyState
```

### Mock Content Types

The mock implementation includes realistic HTML content for:

1. **Head to Head**: Historical match results and win/loss records
2. **Form**: Recent 5-game performance with visual indicators
3. **Team Stats**: Season statistics comparison with charts
4. **Last Matches**: Recent match results with details

## HTML Content Guidelines

### Structure

Statistics content should be provided as complete HTML documents:

```html
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
            margin: 0;
            padding: 16px;
            background-color: #f6f6f8;
            color: #252634;
        }
        /* Your custom styles */
    </style>
</head>
<body>
    <!-- Your statistics content -->
</body>
</html>
```

### Styling Recommendations

- Use system fonts for consistency
- Apply responsive design principles
- Follow StyleProvider color patterns
- Ensure readability in both light and dark modes
- Keep content scrollable within the web view

### Performance Considerations

- Keep HTML content lightweight
- Avoid external resource dependencies
- Use inline styles for better loading performance
- Optimize images and assets

## Customization

### Tab Configuration

```swift
// Custom tab titles and order
let customTabs = [
    StatisticsTabData(id: "overview", title: "Overview"),
    StatisticsTabData(id: "players", title: "Key Players"),
    StatisticsTabData(id: "tactics", title: "Tactics")
]
```

### Styling Integration

The component automatically uses StyleProvider colors:

- `StyleProvider.Color.backgroundTertiary` - Main background
- `StyleProvider.Color.highlightPrimary` - Loading indicators
- `StyleProvider.Color.textSecondary` - Error messages
- Inherits theme changes automatically

### Loading Behavior

```swift
// Custom loading delays
viewModel.loadContent(for: "head_to_head")

// Retry failed loads
viewModel.retryFailedLoad(for: "team_stats")

// Refresh all content
viewModel.refreshAllContent()
```

## Integration with Services

While the component is designed with mock data, it can easily integrate with real services:

```swift
class ProductionStatisticsViewModel: StatisticsWidgetViewModelProtocol {
    private let statisticsService: StatisticsServiceProtocol
    
    func loadContent(for tabId: String) {
        // Call your statistics service
        statisticsService.loadStatistics(for: tabId)
            .sink(receiveCompletion: { /* handle completion */ },
                  receiveValue: { htmlContent in
                      self.updateTabContent(tabId: tabId, htmlContent: htmlContent)
                  })
            .store(in: &cancellables)
    }
}
```

## Accessibility

The component includes accessibility features:

- VoiceOver support for tab navigation
- Semantic content structure in HTML
- Proper focus management
- Screen reader friendly error messages

## Testing

### Unit Testing

```swift
func testTabSelection() {
    let viewModel = MockStatisticsWidgetViewModel.footballMatch
    
    // Test tab selection
    viewModel.selectTab(id: "team_stats")
    
    XCTAssertEqual(viewModel.currentSelectedTabId, "team_stats")
    XCTAssertEqual(viewModel.currentSelectedTabIndex, 2)
}
```

### UI Testing

The component includes comprehensive SwiftUI previews for visual testing:

- Football Match Statistics
- Tennis Match Statistics  
- Loading State
- Error State
- Empty State
- Full Screen Demo
- Interactive Demo with Navigation

## Requirements

- iOS 16.0+
- UIKit framework
- WebKit framework
- Combine framework

## Dependencies

- StyleProvider (for theming)
- MarketGroupSelectorTabView (for tab navigation)
- PreviewUIViewController (for SwiftUI previews)

## Performance Notes

- Web views are created once and reused
- Content is cached to avoid reloading
- Smooth pagination with optimized scroll behavior
- Minimal memory footprint with proper cleanup

## Known Limitations

- Web view content is not interactive (by design)
- Limited to horizontal scrolling only
- Requires manual content size management for complex layouts
- iOS 16+ requirement due to modern WebKit features

## Future Enhancements

Potential improvements for future versions:

- Support for video content in statistics
- Offline content caching
- Advanced animation transitions
- Dynamic tab configuration
- Accessibility improvements
- Performance optimizations

---

For more information about the GomaUI component library, see the main [GomaUI README](../../README.md).