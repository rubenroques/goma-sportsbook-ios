import Combine
import Foundation

// MARK: - Data Models

public struct StatisticsTabData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let htmlContent: String
    public let loadingState: StatisticsLoadingState
    
    public init(
        id: String,
        title: String,
        htmlContent: String = "",
        loadingState: StatisticsLoadingState = .notLoaded
    ) {
        self.id = id
        self.title = title
        self.htmlContent = htmlContent
        self.loadingState = loadingState
    }
}

public enum StatisticsLoadingState: Equatable, Hashable {
    case notLoaded
    case loading
    case loaded
    case error(String)
    
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    public var isLoaded: Bool {
        if case .loaded = self {
            return true
        }
        return false
    }
    
    public var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
    
    public var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

public enum StatisticsContentType: String, CaseIterable {
    case headToHead = "head_to_head"
    case form = "form"
    case teamStats = "team_stats"
    case lastMatches = "last_matches"
    
    public var displayTitle: String {
        switch self {
        case .headToHead:
            return "Head to Head"
        case .form:
            return "Form"
        case .teamStats:
            return "Team Stats"
        case .lastMatches:
            return "Last Matches"
        }
    }
}

public struct StatisticsWidgetData: Equatable, Hashable {
    public let id: String
    public let tabs: [StatisticsTabData]
    public let selectedTabIndex: Int
    
    public init(
        id: String,
        tabs: [StatisticsTabData],
        selectedTabIndex: Int = 0
    ) {
        self.id = id
        self.tabs = tabs
        self.selectedTabIndex = max(0, min(selectedTabIndex, tabs.count - 1))
    }
    
    public var selectedTab: StatisticsTabData? {
        guard selectedTabIndex < tabs.count else { return nil }
        return tabs[selectedTabIndex]
    }
    
    public var selectedTabId: String? {
        return selectedTab?.id
    }
}

// MARK: - View Model Protocol

public protocol StatisticsWidgetViewModelProtocol {
    
    // MARK: - Content Publishers
    
    /// Publisher that emits the complete statistics widget data
    var statisticsDataPublisher: AnyPublisher<StatisticsWidgetData, Never> { get }
    
    /// Publisher that emits the current tabs data
    var tabsPublisher: AnyPublisher<[StatisticsTabData], Never> { get }
    
    /// Publisher that emits the currently selected tab index
    var selectedTabIndexPublisher: AnyPublisher<Int, Never> { get }
    
    /// Publisher that emits the currently selected tab ID
    var selectedTabIdPublisher: AnyPublisher<String?, Never> { get }
    
    /// Publisher that emits whether any content is currently loading
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    
    // MARK: - Current State Access
    
    /// Current statistics widget data
    var currentStatisticsData: StatisticsWidgetData { get }
    
    /// Current tabs array
    var currentTabs: [StatisticsTabData] { get }
    
    /// Current selected tab index
    var currentSelectedTabIndex: Int { get }
    
    /// Current selected tab ID
    var currentSelectedTabId: String? { get }
    
    /// Whether any content is currently loading
    var isCurrentlyLoading: Bool { get }
    
    // MARK: - Actions
    
    /// Select a tab by its ID
    /// - Parameter id: The ID of the tab to select
    func selectTab(id: String)
    
    /// Select a tab by its index
    /// - Parameter index: The index of the tab to select
    func selectTab(index: Int)
    
    /// Load content for a specific tab
    /// - Parameter tabId: The ID of the tab to load content for
    func loadContent(for tabId: String)
    
    /// Retry loading content for a tab that failed to load
    /// - Parameter tabId: The ID of the tab to retry loading
    func retryFailedLoad(for tabId: String)
    
    /// Refresh all content
    func refreshAllContent()
    
    /// Update the HTML content for a specific tab
    /// - Parameters:
    ///   - tabId: The ID of the tab to update
    ///   - htmlContent: The new HTML content
    func updateTabContent(tabId: String, htmlContent: String)
    
    // MARK: - Convenience Methods
    
    /// Get a tab by its ID
    /// - Parameter id: The ID of the tab
    /// - Returns: The tab data if found
    func getTab(by id: String) -> StatisticsTabData?
    
    /// Get a tab by its index
    /// - Parameter index: The index of the tab
    /// - Returns: The tab data if found
    func getTab(at index: Int) -> StatisticsTabData?
    
    /// Select the next tab (if available)
    func selectNextTab()
    
    /// Select the previous tab (if available)
    func selectPreviousTab()
}

// MARK: - Default Implementations

public extension StatisticsWidgetViewModelProtocol {
    
    func selectNextTab() {
        let nextIndex = currentSelectedTabIndex + 1
        if nextIndex < currentTabs.count {
            selectTab(index: nextIndex)
        }
    }
    
    func selectPreviousTab() {
        let previousIndex = currentSelectedTabIndex - 1
        if previousIndex >= 0 {
            selectTab(index: previousIndex)
        }
    }
    
    func getTab(by id: String) -> StatisticsTabData? {
        return currentTabs.first { $0.id == id }
    }
    
    func getTab(at index: Int) -> StatisticsTabData? {
        guard index >= 0 && index < currentTabs.count else { return nil }
        return currentTabs[index]
    }
}