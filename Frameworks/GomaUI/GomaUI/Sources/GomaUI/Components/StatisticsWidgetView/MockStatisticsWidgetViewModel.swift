import Combine
import Foundation

public class MockStatisticsWidgetViewModel: StatisticsWidgetViewModelProtocol {
    
    // MARK: - Private Properties
    private let dataSubject: CurrentValueSubject<StatisticsWidgetData, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(data: StatisticsWidgetData) {
        self.dataSubject = CurrentValueSubject(data)
        startMockContentLoading()
    }
    
    // MARK: - Content Publishers
    public var statisticsDataPublisher: AnyPublisher<StatisticsWidgetData, Never> {
        dataSubject.removeDuplicates().eraseToAnyPublisher()
    }
    
    public var tabsPublisher: AnyPublisher<[StatisticsTabData], Never> {
        dataSubject
            .map(\.tabs)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var selectedTabIndexPublisher: AnyPublisher<Int, Never> {
        dataSubject
            .map(\.selectedTabIndex)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var selectedTabIdPublisher: AnyPublisher<String?, Never> {
        dataSubject
            .map(\.selectedTabId)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        dataSubject
            .map { data in
                data.tabs.contains { $0.loadingState.isLoading }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Current State Access
    public var currentStatisticsData: StatisticsWidgetData {
        dataSubject.value
    }
    
    public var currentTabs: [StatisticsTabData] {
        dataSubject.value.tabs
    }
    
    public var currentSelectedTabIndex: Int {
        dataSubject.value.selectedTabIndex
    }
    
    public var currentSelectedTabId: String? {
        dataSubject.value.selectedTabId
    }
    
    public var isCurrentlyLoading: Bool {
        currentTabs.contains { $0.loadingState.isLoading }
    }
    
    // MARK: - Actions
    public func selectTab(id: String) {
        let currentData = dataSubject.value
        
        guard let tabIndex = currentData.tabs.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        selectTab(index: tabIndex)
    }
    
    public func selectTab(index: Int) {
        let currentData = dataSubject.value
        
        guard index >= 0 && index < currentData.tabs.count else {
            return
        }
        
        let updatedData = StatisticsWidgetData(
            id: currentData.id,
            tabs: currentData.tabs,
            selectedTabIndex: index
        )
        
        dataSubject.send(updatedData)
    }
    
    public func loadContent(for tabId: String) {
        let currentData = dataSubject.value
        
        guard let tabIndex = currentData.tabs.firstIndex(where: { $0.id == tabId }) else {
            return
        }
        
        let tab = currentData.tabs[tabIndex]
        
        // Don't reload if already loaded
        guard !tab.loadingState.isLoaded else { return }
        
        // Set loading state
        var updatedTabs = currentData.tabs
        updatedTabs[tabIndex] = StatisticsTabData(
            id: tab.id,
            title: tab.title,
            htmlContent: tab.htmlContent,
            loadingState: .loading
        )
        
        let updatedData = StatisticsWidgetData(
            id: currentData.id,
            tabs: updatedTabs,
            selectedTabIndex: currentData.selectedTabIndex
        )
        
        dataSubject.send(updatedData)
        
        // Simulate loading with delay
        let loadingDelay = Double.random(in: 0.5...2.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + loadingDelay) { [weak self] in
            self?.completeContentLoading(for: tabId)
        }
    }
    
    public func retryFailedLoad(for tabId: String) {
        let currentData = dataSubject.value
        
        guard let tabIndex = currentData.tabs.firstIndex(where: { $0.id == tabId }) else {
            return
        }
        
        var updatedTabs = currentData.tabs
        let tab = updatedTabs[tabIndex]
        
        updatedTabs[tabIndex] = StatisticsTabData(
            id: tab.id,
            title: tab.title,
            htmlContent: tab.htmlContent,
            loadingState: .notLoaded
        )
        
        let updatedData = StatisticsWidgetData(
            id: currentData.id,
            tabs: updatedTabs,
            selectedTabIndex: currentData.selectedTabIndex
        )
        
        dataSubject.send(updatedData)
        
        // Retry loading
        loadContent(for: tabId)
    }
    
    public func refreshAllContent() {
        let currentData = dataSubject.value
        
        let refreshedTabs = currentData.tabs.map { tab in
            StatisticsTabData(
                id: tab.id,
                title: tab.title,
                htmlContent: "",
                loadingState: .notLoaded
            )
        }
        
        let updatedData = StatisticsWidgetData(
            id: currentData.id,
            tabs: refreshedTabs,
            selectedTabIndex: currentData.selectedTabIndex
        )
        
        dataSubject.send(updatedData)
        
        // Load all content
        for tab in refreshedTabs {
            loadContent(for: tab.id)
        }
    }
    
    public func updateTabContent(tabId: String, htmlContent: String) {
        let currentData = dataSubject.value
        
        guard let tabIndex = currentData.tabs.firstIndex(where: { $0.id == tabId }) else {
            return
        }
        
        var updatedTabs = currentData.tabs
        let tab = updatedTabs[tabIndex]
        
        updatedTabs[tabIndex] = StatisticsTabData(
            id: tab.id,
            title: tab.title,
            htmlContent: htmlContent,
            loadingState: .loaded
        )
        
        let updatedData = StatisticsWidgetData(
            id: currentData.id,
            tabs: updatedTabs,
            selectedTabIndex: currentData.selectedTabIndex
        )
        
        dataSubject.send(updatedData)
    }
    
    // MARK: - Private Methods
    private func startMockContentLoading() {
        // Auto-load content for tabs with notLoaded state
        let currentData = dataSubject.value
        
        for tab in currentData.tabs where tab.loadingState == .notLoaded {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.loadContent(for: tab.id)
            }
        }
    }
    
    private func completeContentLoading(for tabId: String) {
        let currentData = dataSubject.value
        
        guard let tabIndex = currentData.tabs.firstIndex(where: { $0.id == tabId }) else {
            return
        }
        
        let tab = currentData.tabs[tabIndex]
        var updatedTabs = currentData.tabs
        
        // Simulate occasional loading failures
        let shouldFail = Double.random(in: 0...1) < 0.1 // 10% failure rate
        
        if shouldFail {
            updatedTabs[tabIndex] = StatisticsTabData(
                id: tab.id,
                title: tab.title,
                htmlContent: tab.htmlContent,
                loadingState: .error("Failed to load statistics data")
            )
        } else {
            let htmlContent = generateHTMLContent(for: StatisticsContentType(rawValue: tabId) ?? .headToHead)
            
            updatedTabs[tabIndex] = StatisticsTabData(
                id: tab.id,
                title: tab.title,
                htmlContent: htmlContent,
                loadingState: .loaded
            )
        }
        
        let updatedData = StatisticsWidgetData(
            id: currentData.id,
            tabs: updatedTabs,
            selectedTabIndex: currentData.selectedTabIndex
        )
        
        dataSubject.send(updatedData)
    }
    
    private func generateHTMLContent(for contentType: StatisticsContentType) -> String {
        switch contentType {
        case .headToHead:
            return generateHeadToHeadHTML()
        case .form:
            return generateFormHTML()
        case .teamStats:
            return generateTeamStatsHTML()
        case .lastMatches:
            return generateLastMatchesHTML()
        }
    }
}

// MARK: - HTML Content Generation

private extension MockStatisticsWidgetViewModel {
    
    func generateHeadToHeadHTML() -> String {
        return """
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
                    line-height: 1.4;
                }
                .stats-container {
                    background: white;
                    border-radius: 12px;
                    padding: 20px;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                }
                .header {
                    text-align: center;
                    margin-bottom: 24px;
                }
                .header h2 {
                    margin: 0;
                    font-size: 18px;
                    font-weight: 600;
                    color: #000114;
                }
                .teams {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 20px;
                }
                .team {
                    text-align: center;
                    flex: 1;
                }
                .team-name {
                    font-weight: 600;
                    font-size: 16px;
                    margin-bottom: 4px;
                }
                .vs {
                    font-size: 14px;
                    color: #84858c;
                    margin: 0 16px;
                }
                .record {
                    display: flex;
                    justify-content: center;
                    gap: 12px;
                    margin-top: 16px;
                }
                .record-item {
                    text-align: center;
                    background: #f6f6f8;
                    padding: 8px 12px;
                    border-radius: 8px;
                    min-width: 40px;
                }
                .record-value {
                    font-size: 18px;
                    font-weight: 600;
                    color: #ff6600;
                }
                .record-label {
                    font-size: 12px;
                    color: #84858c;
                    margin-top: 2px;
                }
                .matches-list {
                    margin-top: 20px;
                }
                .match-item {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 12px 0;
                    border-bottom: 1px solid #e1e1e1;
                }
                .match-item:last-child {
                    border-bottom: none;
                }
                .match-teams {
                    font-size: 14px;
                    font-weight: 500;
                }
                .match-score {
                    font-size: 14px;
                    font-weight: 600;
                    color: #ff6600;
                }
                .match-date {
                    font-size: 12px;
                    color: #84858c;
                }
            </style>
        </head>
        <body>
            <div class="stats-container">
                <div class="header">
                    <h2>Head to Head Record</h2>
                </div>
                
                <div class="teams">
                    <div class="team">
                        <div class="team-name">MAN</div>
                    </div>
                    <div class="vs">vs</div>
                    <div class="team">
                        <div class="team-name">GLA</div>
                    </div>
                </div>
                
                <div class="record">
                    <div class="record-item">
                        <div class="record-value">8</div>
                        <div class="record-label">MAN Wins</div>
                    </div>
                    <div class="record-item">
                        <div class="record-value">3</div>
                        <div class="record-label">Draws</div>
                    </div>
                    <div class="record-item">
                        <div class="record-value">4</div>
                        <div class="record-label">GLA Wins</div>
                    </div>
                </div>
                
                <div class="matches-list">
                    <div class="match-item">
                        <div>
                            <div class="match-teams">MAN vs GLA</div>
                            <div class="match-date">March 15, 2024</div>
                        </div>
                        <div class="match-score">2-1</div>
                    </div>
                    <div class="match-item">
                        <div>
                            <div class="match-teams">GLA vs MAN</div>
                            <div class="match-date">October 22, 2023</div>
                        </div>
                        <div class="match-score">1-3</div>
                    </div>
                    <div class="match-item">
                        <div>
                            <div class="match-teams">MAN vs GLA</div>
                            <div class="match-date">April 8, 2023</div>
                        </div>
                        <div class="match-score">1-1</div>
                    </div>
                    <div class="match-item">
                        <div>
                            <div class="match-teams">GLA vs MAN</div>
                            <div class="match-date">December 3, 2022</div>
                        </div>
                        <div class="match-score">0-2</div>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
    }
    
    func generateFormHTML() -> String {
        return """
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
                    line-height: 1.4;
                }
                .stats-container {
                    background: white;
                    border-radius: 12px;
                    padding: 20px;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                }
                .header {
                    text-align: center;
                    margin-bottom: 24px;
                }
                .header h2 {
                    margin: 0;
                    font-size: 18px;
                    font-weight: 600;
                    color: #000114;
                }
                .team-form {
                    margin-bottom: 24px;
                }
                .team-header {
                    display: flex;
                    align-items: center;
                    margin-bottom: 12px;
                }
                .team-name {
                    font-weight: 600;
                    font-size: 16px;
                    margin-right: 12px;
                }
                .form-indicator {
                    display: flex;
                    gap: 4px;
                }
                .form-result {
                    width: 24px;
                    height: 24px;
                    border-radius: 4px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 12px;
                    font-weight: 600;
                    color: white;
                }
                .form-result.win {
                    background-color: #40b840;
                }
                .form-result.draw {
                    background-color: #ff6600;
                }
                .form-result.loss {
                    background-color: #ed4f63;
                }
                .form-summary {
                    margin-top: 8px;
                    font-size: 14px;
                    color: #84858c;
                }
            </style>
        </head>
        <body>
            <div class="stats-container">
                <div class="header">
                    <h2>Recent Form</h2>
                    <p style="margin: 8px 0 0 0; font-size: 14px; color: #84858c;">Last 5 matches</p>
                </div>
                
                <div class="team-form">
                    <div class="team-header">
                        <div class="team-name">MAN</div>
                        <div class="form-indicator">
                            <div class="form-result win">W</div>
                            <div class="form-result win">W</div>
                            <div class="form-result draw">D</div>
                            <div class="form-result win">W</div>
                            <div class="form-result loss">L</div>
                        </div>
                    </div>
                    <div class="form-summary">3 wins, 1 draw, 1 loss</div>
                </div>
                
                <div class="team-form">
                    <div class="team-header">
                        <div class="team-name">GLA</div>
                        <div class="form-indicator">
                            <div class="form-result loss">L</div>
                            <div class="form-result win">W</div>
                            <div class="form-result win">W</div>
                            <div class="form-result draw">D</div>
                            <div class="form-result win">W</div>
                        </div>
                    </div>
                    <div class="form-summary">3 wins, 1 draw, 1 loss</div>
                </div>
            </div>
        </body>
        </html>
        """
    }
    
    func generateTeamStatsHTML() -> String {
        return """
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
                    line-height: 1.4;
                }
                .stats-container {
                    background: white;
                    border-radius: 12px;
                    padding: 20px;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                }
                .header {
                    text-align: center;
                    margin-bottom: 24px;
                }
                .header h2 {
                    margin: 0;
                    font-size: 18px;
                    font-weight: 600;
                    color: #000114;
                }
                .stat-row {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 12px 0;
                    border-bottom: 1px solid #e1e1e1;
                }
                .stat-row:last-child {
                    border-bottom: none;
                }
                .stat-label {
                    font-size: 14px;
                    font-weight: 500;
                    color: #252634;
                }
                .stat-values {
                    display: flex;
                    align-items: center;
                    gap: 16px;
                }
                .stat-value {
                    font-size: 14px;
                    font-weight: 600;
                    min-width: 40px;
                    text-align: center;
                }
                .stat-value.home {
                    color: #d99f00;
                }
                .stat-value.away {
                    color: #46c1a7;
                }
                .stat-bar {
                    width: 60px;
                    height: 4px;
                    background-color: #e1e1e1;
                    border-radius: 2px;
                    overflow: hidden;
                    position: relative;
                }
                .stat-bar-fill {
                    height: 100%;
                    background-color: #ff6600;
                    border-radius: 2px;
                }
            </style>
        </head>
        <body>
            <div class="stats-container">
                <div class="header">
                    <h2>Team Statistics</h2>
                    <p style="margin: 8px 0 0 0; font-size: 14px; color: #84858c;">Season comparison</p>
                </div>
                
                <div class="stat-row">
                    <div class="stat-label">Goals Scored</div>
                    <div class="stat-values">
                        <div class="stat-value home">24</div>
                        <div class="stat-bar">
                            <div class="stat-bar-fill" style="width: 70%;"></div>
                        </div>
                        <div class="stat-value away">18</div>
                    </div>
                </div>
                
                <div class="stat-row">
                    <div class="stat-label">Goals Conceded</div>
                    <div class="stat-values">
                        <div class="stat-value home">12</div>
                        <div class="stat-bar">
                            <div class="stat-bar-fill" style="width: 40%;"></div>
                        </div>
                        <div class="stat-value away">15</div>
                    </div>
                </div>
                
                <div class="stat-row">
                    <div class="stat-label">Possession %</div>
                    <div class="stat-values">
                        <div class="stat-value home">58%</div>
                        <div class="stat-bar">
                            <div class="stat-bar-fill" style="width: 58%;"></div>
                        </div>
                        <div class="stat-value away">52%</div>
                    </div>
                </div>
                
                <div class="stat-row">
                    <div class="stat-label">Shots per Game</div>
                    <div class="stat-values">
                        <div class="stat-value home">14.2</div>
                        <div class="stat-bar">
                            <div class="stat-bar-fill" style="width: 65%;"></div>
                        </div>
                        <div class="stat-value away">11.8</div>
                    </div>
                </div>
                
                <div class="stat-row">
                    <div class="stat-label">Pass Accuracy</div>
                    <div class="stat-values">
                        <div class="stat-value home">86%</div>
                        <div class="stat-bar">
                            <div class="stat-bar-fill" style="width: 86%;"></div>
                        </div>
                        <div class="stat-value away">82%</div>
                    </div>
                </div>
                
                <div class="stat-row">
                    <div class="stat-label">Yellow Cards</div>
                    <div class="stat-values">
                        <div class="stat-value home">28</div>
                        <div class="stat-bar">
                            <div class="stat-bar-fill" style="width: 45%;"></div>
                        </div>
                        <div class="stat-value away">32</div>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
    }
    
    func generateLastMatchesHTML() -> String {
        return """
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
                    line-height: 1.4;
                }
                .stats-container {
                    background: white;
                    border-radius: 12px;
                    padding: 20px;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                }
                .header {
                    text-align: center;
                    margin-bottom: 24px;
                }
                .header h2 {
                    margin: 0;
                    font-size: 18px;
                    font-weight: 600;
                    color: #000114;
                }
                .matches-list {
                    display: flex;
                    flex-direction: column;
                    gap: 12px;
                }
                .match-item {
                    background: #f6f6f8;
                    border-radius: 8px;
                    padding: 16px;
                }
                .match-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 8px;
                }
                .match-teams {
                    font-size: 14px;
                    font-weight: 600;
                }
                .match-score {
                    font-size: 16px;
                    font-weight: 600;
                    color: #ff6600;
                }
                .match-details {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    font-size: 12px;
                    color: #84858c;
                }
                .match-competition {
                    font-weight: 500;
                }
                .result-win {
                    color: #40b840;
                }
                .result-loss {
                    color: #ed4f63;
                }
                .result-draw {
                    color: #ff6600;
                }
            </style>
        </head>
        <body>
            <div class="stats-container">
                <div class="header">
                    <h2>Last Matches</h2>
                    <p style="margin: 8px 0 0 0; font-size: 14px; color: #84858c;">Recent results</p>
                </div>
                
                <div class="matches-list">
                    <div class="match-item">
                        <div class="match-header">
                            <div class="match-teams">MAN vs CHE</div>
                            <div class="match-score result-win">2-0</div>
                        </div>
                        <div class="match-details">
                            <div class="match-competition">Premier League</div>
                            <div class="match-date">March 10, 2024</div>
                        </div>
                    </div>
                    
                    <div class="match-item">
                        <div class="match-header">
                            <div class="match-teams">LIV vs MAN</div>
                            <div class="match-score result-loss">3-1</div>
                        </div>
                        <div class="match-details">
                            <div class="match-competition">Premier League</div>
                            <div class="match-date">March 3, 2024</div>
                        </div>
                    </div>
                    
                    <div class="match-item">
                        <div class="match-header">
                            <div class="match-teams">MAN vs ARS</div>
                            <div class="match-score result-draw">1-1</div>
                        </div>
                        <div class="match-details">
                            <div class="match-competition">Premier League</div>
                            <div class="match-date">February 25, 2024</div>
                        </div>
                    </div>
                    
                    <div class="match-item">
                        <div class="match-header">
                            <div class="match-teams">GLA vs NEW</div>
                            <div class="match-score result-win">2-1</div>
                        </div>
                        <div class="match-details">
                            <div class="match-competition">Championship</div>
                            <div class="match-date">March 8, 2024</div>
                        </div>
                    </div>
                    
                    <div class="match-item">
                        <div class="match-header">
                            <div class="match-teams">BIR vs GLA</div>
                            <div class="match-score result-loss">1-0</div>
                        </div>
                        <div class="match-details">
                            <div class="match-competition">Championship</div>
                            <div class="match-date">March 1, 2024</div>
                        </div>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
    }
}

// MARK: - Factory Methods

public extension MockStatisticsWidgetViewModel {
    
    static var footballMatch: MockStatisticsWidgetViewModel {
        let tabs = [
            StatisticsTabData(
                id: StatisticsContentType.headToHead.rawValue,
                title: StatisticsContentType.headToHead.displayTitle,
                loadingState: .notLoaded
            ),
            StatisticsTabData(
                id: StatisticsContentType.form.rawValue,
                title: StatisticsContentType.form.displayTitle,
                loadingState: .notLoaded
            ),
            StatisticsTabData(
                id: StatisticsContentType.teamStats.rawValue,
                title: StatisticsContentType.teamStats.displayTitle,
                loadingState: .notLoaded
            ),
            StatisticsTabData(
                id: StatisticsContentType.lastMatches.rawValue,
                title: StatisticsContentType.lastMatches.displayTitle,
                loadingState: .notLoaded
            )
        ]
        
        let data = StatisticsWidgetData(
            id: "football_match_stats",
            tabs: tabs,
            selectedTabIndex: 0
        )
        
        return MockStatisticsWidgetViewModel(data: data)
    }
    
    static var tennisMatch: MockStatisticsWidgetViewModel {
        let tabs = [
            StatisticsTabData(
                id: StatisticsContentType.headToHead.rawValue,
                title: StatisticsContentType.headToHead.displayTitle,
                htmlContent: "<html><body><h2>Tennis H2H</h2><p>Djokovic leads 5-2</p></body></html>",
                loadingState: .loaded
            ),
            StatisticsTabData(
                id: StatisticsContentType.form.rawValue,
                title: StatisticsContentType.form.displayTitle,
                htmlContent: "<html><body><h2>Recent Form</h2><p>Both players in good form</p></body></html>",
                loadingState: .loaded
            )
        ]
        
        let data = StatisticsWidgetData(
            id: "tennis_match_stats",
            tabs: tabs,
            selectedTabIndex: 0
        )
        
        return MockStatisticsWidgetViewModel(data: data)
    }
    
    static var loadingState: MockStatisticsWidgetViewModel {
        let tabs = [
            StatisticsTabData(
                id: StatisticsContentType.headToHead.rawValue,
                title: StatisticsContentType.headToHead.displayTitle,
                loadingState: .loading
            ),
            StatisticsTabData(
                id: StatisticsContentType.form.rawValue,
                title: StatisticsContentType.form.displayTitle,
                loadingState: .notLoaded
            ),
            StatisticsTabData(
                id: StatisticsContentType.teamStats.rawValue,
                title: StatisticsContentType.teamStats.displayTitle,
                loadingState: .notLoaded
            )
        ]
        
        let data = StatisticsWidgetData(
            id: "loading_stats",
            tabs: tabs,
            selectedTabIndex: 0
        )
        
        return MockStatisticsWidgetViewModel(data: data)
    }
    
    static var errorState: MockStatisticsWidgetViewModel {
        let tabs = [
            StatisticsTabData(
                id: StatisticsContentType.headToHead.rawValue,
                title: StatisticsContentType.headToHead.displayTitle,
                loadingState: .error("Network connection failed")
            ),
            StatisticsTabData(
                id: StatisticsContentType.form.rawValue,
                title: StatisticsContentType.form.displayTitle,
                htmlContent: "<html><body><h2>Form loaded successfully</h2></body></html>",
                loadingState: .loaded
            )
        ]
        
        let data = StatisticsWidgetData(
            id: "error_stats",
            tabs: tabs,
            selectedTabIndex: 0
        )
        
        return MockStatisticsWidgetViewModel(data: data)
    }
    
    static var emptyState: MockStatisticsWidgetViewModel {
        let data = StatisticsWidgetData(
            id: "empty_stats",
            tabs: [],
            selectedTabIndex: 0
        )
        
        return MockStatisticsWidgetViewModel(data: data)
    }
}
