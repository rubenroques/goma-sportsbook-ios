# StatisticsWidgetView

A tabbed statistics widget displaying match data via embedded WebViews.

## Overview

StatisticsWidgetView provides a comprehensive statistics display for sports matches. It features a tab selector (using MarketGroupSelectorTabView) and a horizontally pageable scroll view containing WKWebViews that render HTML statistics content. The widget supports multiple content types like Head-to-Head, Form, Team Stats, and Last Matches. It handles loading states, errors, and content refreshing.

## Component Relationships

### Used By (Parents)
- Match detail screens
- Pre-match analysis sections

### Uses (Children)
- `MarketGroupSelectorTabView` (for tab navigation)

## Features

- Tab selector for different statistics types
- Horizontal paging between tabs (swipe or tap)
- WKWebView for rendering HTML statistics content
- Loading states per tab with visual indicators
- Error states with error messages
- Content lazy loading (loads when tab becomes visible)
- Retry failed loads
- Refresh all content functionality
- Synchronized tab selection and scroll position
- 400pt default intrinsic height
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockStatisticsWidgetViewModel.footballMatch
let statisticsWidget = StatisticsWidgetView(viewModel: viewModel)

// Navigate to specific tab
viewModel.selectTab(id: "form")
viewModel.selectTab(index: 1)

// Navigate with convenience methods
viewModel.selectNextTab()
viewModel.selectPreviousTab()

// Load content for a specific tab
viewModel.loadContent(for: "head_to_head")

// Retry failed load
viewModel.retryFailedLoad(for: "team_stats")

// Refresh all content
viewModel.refreshAllContent()

// Update tab content directly
viewModel.updateTabContent(tabId: "form", htmlContent: "<html>...</html>")
```

## Data Model

```swift
enum StatisticsContentType: String, CaseIterable {
    case headToHead = "head_to_head"
    case form = "form"
    case teamStats = "team_stats"
    case lastMatches = "last_matches"

    var displayTitle: String
}

enum StatisticsLoadingState: Equatable, Hashable {
    case notLoaded
    case loading
    case loaded
    case error(String)
}

struct StatisticsTabData: Equatable, Hashable {
    let id: String
    let title: String
    let htmlContent: String
    let loadingState: StatisticsLoadingState
}

struct StatisticsWidgetData: Equatable, Hashable {
    let id: String
    let tabs: [StatisticsTabData]
    let selectedTabIndex: Int
}

protocol StatisticsWidgetViewModelProtocol {
    // Publishers
    var statisticsDataPublisher: AnyPublisher<StatisticsWidgetData, Never> { get }
    var tabsPublisher: AnyPublisher<[StatisticsTabData], Never> { get }
    var selectedTabIndexPublisher: AnyPublisher<Int, Never> { get }
    var selectedTabIdPublisher: AnyPublisher<String?, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }

    // Current state
    var currentStatisticsData: StatisticsWidgetData { get }
    var currentTabs: [StatisticsTabData] { get }
    var currentSelectedTabIndex: Int { get }
    var currentSelectedTabId: String? { get }
    var isCurrentlyLoading: Bool { get }

    // Actions
    func selectTab(id: String)
    func selectTab(index: Int)
    func loadContent(for tabId: String)
    func retryFailedLoad(for tabId: String)
    func refreshAllContent()
    func updateTabContent(tabId: String, htmlContent: String)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - widget and web view backgrounds
- `StyleProvider.Color.highlightPrimary` - loading indicator color
- `StyleProvider.Color.textSecondary` - error label color
- `StyleProvider.fontWith(type: .regular, size: 14)` - error label font

Layout constants:
- Tab selector height: 50pt
- Loading overlay alpha: 0.8
- Animation duration: 0.3s
- Default widget height: 400pt (intrinsic)

WebView behavior:
- User interaction disabled
- Scrolling disabled
- Transparent background
- Inline media playback enabled

HTML content:
- Generated dynamically for each statistics type
- Styled with inline CSS for consistent appearance
- Loading, error, and placeholder HTML templates

## Mock ViewModels

Available presets:
- `.footballMatch` - 4 tabs (H2H, Form, Team Stats, Last Matches)
- `.tennisMatch` - 2 tabs with pre-loaded content
- `.loadingState` - First tab loading, others not loaded
- `.errorState` - First tab with error, second loaded
- `.emptyState` - No tabs

Methods:
- `selectTab(id:)` / `selectTab(index:)` - Navigate tabs
- `loadContent(for:)` - Load content with simulated delay
- `retryFailedLoad(for:)` - Reset and retry loading
- `refreshAllContent()` - Clear and reload all tabs
