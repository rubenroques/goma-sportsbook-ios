import UIKit
import WebKit
import Combine

public class StatisticsWidgetView: UIView {
    
    // MARK: - Private Properties
    private let viewModel: StatisticsWidgetViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let mainStackView = UIStackView()
    private let tabSelectorView: MarketGroupSelectorTabView
    private let contentScrollView = UIScrollView()
    private let loadingOverlay = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let errorLabel = UILabel()
    
    // MARK: - Web Views Management
    private var webViews: [String: WKWebView] = [:]
    private var tabViews: [String: UIView] = [:]
    private var currentTabs: [StatisticsTabData] = []
    
    // MARK: - Layout Constants
    private struct Constants {
        static let tabSelectorHeight: CGFloat = 50.0
        static let horizontalPadding: CGFloat = 0.0
        static let verticalPadding: CGFloat = 0.0
        static let loadingOverlayAlpha: CGFloat = 0.8
        static let animationDuration: TimeInterval = 0.3
        static let errorRetryDelay: TimeInterval = 1.0
    }
    
    // MARK: - Initialization
    public init(viewModel: StatisticsWidgetViewModelProtocol) {
        self.viewModel = viewModel
        
        // Create tab selector view model that maps to our statistics tabs
        let tabSelectorViewModel = StatisticsTabSelectorViewModel(statisticsViewModel: viewModel)
        self.tabSelectorView = MarketGroupSelectorTabView(viewModel: tabSelectorViewModel)
        
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = StyleProvider.Color.backgroundTertiary
        
        // Main stack view setup
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        mainStackView.distribution = .fill
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        
        // Tab selector setup
        tabSelectorView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(tabSelectorView)
        
        // Content scroll view setup
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.isPagingEnabled = true
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.bounces = false
        contentScrollView.delegate = self
        contentScrollView.backgroundColor = StyleProvider.Color.backgroundTertiary
        mainStackView.addArrangedSubview(contentScrollView)
        
        // Loading overlay setup
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.backgroundColor = StyleProvider.Color.backgroundTertiary.withAlphaComponent(Constants.loadingOverlayAlpha)
        loadingOverlay.isHidden = true
        addSubview(loadingOverlay)
        
        // Loading indicator setup
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = StyleProvider.Color.highlightPrimary
        loadingIndicator.hidesWhenStopped = true
        loadingOverlay.addSubview(loadingIndicator)
        
        // Error label setup
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = StyleProvider.Color.textSecondary
        errorLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        loadingOverlay.addSubview(errorLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Main stack view constraints
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Tab selector height constraint
            tabSelectorView.heightAnchor.constraint(equalToConstant: Constants.tabSelectorHeight),
            
            // Loading overlay constraints
            loadingOverlay.topAnchor.constraint(equalTo: topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor),
            
            // Error label constraints
            errorLabel.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor, constant: 40),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: loadingOverlay.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: loadingOverlay.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        // Bind to tabs data changes
        viewModel.tabsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tabs in
                self?.updateTabs(tabs)
            }
            .store(in: &cancellables)
        
        // Bind to selected tab index changes
        viewModel.selectedTabIndexPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedIndex in
                self?.updateSelectedTab(index: selectedIndex)
            }
            .store(in: &cancellables)
        
        // Bind to loading state changes
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Tab Management
    private func updateTabs(_ tabs: [StatisticsTabData]) {
        let previousTabs = currentTabs
        currentTabs = tabs
        
        // Check if we need to rebuild the scroll view content
        let tabIdsChanged = Set(previousTabs.map(\.id)) != Set(tabs.map(\.id))
        
        if tabIdsChanged || previousTabs.isEmpty {
            rebuildScrollViewContent()
        } else {
            updateExistingTabContent()
        }
    }
    
    private func rebuildScrollViewContent() {
        // Clear existing content
        clearScrollViewContent()
        
        // Create new web views and tab containers for each tab
        for (index, tab) in currentTabs.enumerated() {
            createTabContent(for: tab, at: index)
        }
        
        // Update scroll view content size
        updateScrollViewContentSize()
        
        // Update selected tab position
        updateSelectedTab(index: viewModel.currentSelectedTabIndex)
    }
    
    private func updateExistingTabContent() {
        // Update content for existing tabs
        for tab in currentTabs {
            if let webView = webViews[tab.id] {
                updateWebViewContent(webView, with: tab)
            }
        }
    }
    
    private func createTabContent(for tab: StatisticsTabData, at index: Int) {
        // Create container view for this tab
        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create web view
        let webView = createWebView(for: tab)
        containerView.addSubview(webView)
        
        // Store references
        tabViews[tab.id] = containerView
        webViews[tab.id] = webView
        
        // Add to scroll view
        contentScrollView.addSubview(containerView)
        
        // Setup constraints for container
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: contentScrollView.heightAnchor)
        ])
        
        // Position container horizontally
        if index == 0 {
            containerView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor).isActive = true
        } else if let previousTab = currentTabs.dropLast(currentTabs.count - index).last,
                  let previousContainer = tabViews[previousTab.id] {
            containerView.leadingAnchor.constraint(equalTo: previousContainer.trailingAnchor).isActive = true
        }
        
        // Setup constraints for web view within container
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: containerView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func createWebView(for tab: StatisticsTabData) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = false // Disable user interaction as requested
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = StyleProvider.Color.backgroundTertiary
        webView.isOpaque = false
        webView.navigationDelegate = self
        
        // Load content if available
        updateWebViewContent(webView, with: tab)
        
        return webView
    }
    
    private func updateWebViewContent(_ webView: WKWebView, with tab: StatisticsTabData) {
        switch tab.loadingState {
        case .loaded:
            if !tab.htmlContent.isEmpty {
                webView.loadHTMLString(tab.htmlContent, baseURL: nil)
            }
        case .loading:
            // Show loading state in web view
            let loadingHTML = generateLoadingHTML()
            webView.loadHTMLString(loadingHTML, baseURL: nil)
        case .error(let message):
            // Show error state in web view
            let errorHTML = generateErrorHTML(message: message)
            webView.loadHTMLString(errorHTML, baseURL: nil)
        case .notLoaded:
            // Show placeholder or trigger loading
            let placeholderHTML = generatePlaceholderHTML()
            webView.loadHTMLString(placeholderHTML, baseURL: nil)
            
            // Trigger content loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.viewModel.loadContent(for: tab.id)
            }
        }
    }
    
    private func clearScrollViewContent() {
        // Remove all subviews from scroll view
        contentScrollView.subviews.forEach { $0.removeFromSuperview() }
        
        // Clear references
        webViews.removeAll()
        tabViews.removeAll()
    }
    
    private func updateScrollViewContentSize() {
        let contentWidth = CGFloat(currentTabs.count) * contentScrollView.frame.width
        contentScrollView.contentSize = CGSize(width: contentWidth, height: contentScrollView.frame.height)
    }
    
    private func updateSelectedTab(index: Int) {
        guard index >= 0 && index < currentTabs.count else { return }
        
        // Calculate target offset
        let targetOffsetX = CGFloat(index) * contentScrollView.frame.width
        let targetOffset = CGPoint(x: targetOffsetX, y: 0)
        
        // Update scroll position if needed
        if contentScrollView.contentOffset.x != targetOffsetX {
            contentScrollView.setContentOffset(targetOffset, animated: true)
        }
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            errorLabel.isHidden = true
            loadingOverlay.isHidden = false
        } else {
            loadingIndicator.stopAnimating()
            loadingOverlay.isHidden = true
        }
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update scroll view content size when layout changes
        if !currentTabs.isEmpty {
            updateScrollViewContentSize()
            
            // Maintain current selected tab position
            let selectedIndex = viewModel.currentSelectedTabIndex
            updateSelectedTab(index: selectedIndex)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension StatisticsWidgetView: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == contentScrollView else { return }
        
        let pageWidth = scrollView.frame.width
        guard pageWidth > 0 else { return }
        
        let currentPage = Int(scrollView.contentOffset.x / pageWidth)
        
        // Update view model selection if page changed
        if currentPage != viewModel.currentSelectedTabIndex {
            viewModel.selectTab(index: currentPage)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Handle the case where scrolling ends without deceleration
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
}

// MARK: - WKNavigationDelegate

extension StatisticsWidgetView: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Web view finished loading content
        // Could trigger any completion callbacks here if needed
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Handle web view loading errors
        print("WebView loading failed: \(error.localizedDescription)")
    }
}

// MARK: - HTML Generation

private extension StatisticsWidgetView {
    
    func generateLoadingHTML() -> String {
        return """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
                    margin: 0;
                    padding: 40px 20px;
                    background-color: #f6f6f8;
                    color: #84858c;
                    text-align: center;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                    min-height: 200px;
                }
                .loading-indicator {
                    width: 20px;
                    height: 20px;
                    border: 2px solid #e1e1e1;
                    border-top: 2px solid #ff6600;
                    border-radius: 50%;
                    animation: spin 1s linear infinite;
                    margin-bottom: 16px;
                }
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
                .loading-text {
                    font-size: 14px;
                    color: #84858c;
                }
            </style>
        </head>
        <body>
            <div class="loading-indicator"></div>
            <div class="loading-text">Loading statistics...</div>
        </body>
        </html>
        """
    }
    
    func generateErrorHTML(message: String) -> String {
        return """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
                    margin: 0;
                    padding: 40px 20px;
                    background-color: #f6f6f8;
                    color: #ed4f63;
                    text-align: center;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                    min-height: 200px;
                }
                .error-icon {
                    font-size: 24px;
                    margin-bottom: 16px;
                }
                .error-message {
                    font-size: 14px;
                    color: #84858c;
                    line-height: 1.4;
                }
            </style>
        </head>
        <body>
            <div class="error-icon">⚠️</div>
            <div class="error-message">\(message)</div>
        </body>
        </html>
        """
    }
    
    func generatePlaceholderHTML() -> String {
        return """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
                    margin: 0;
                    padding: 40px 20px;
                    background-color: #f6f6f8;
                    color: #84858c;
                    text-align: center;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                    min-height: 200px;
                }
                .placeholder-text {
                    font-size: 14px;
                    color: #84858c;
                }
            </style>
        </head>
        <body>
            <div class="placeholder-text">Preparing statistics...</div>
        </body>
        </html>
        """
    }
}

// MARK: - Intrinsic Content Size
extension StatisticsWidgetView {
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 400) // Default height
    }
}

// MARK: - Preview Provider
#if DEBUG
import SwiftUI

#Preview("Football Match Statistics") {
    PreviewUIViewController {
        let vc = UIViewController()
        let statisticsView = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.footballMatch)
        statisticsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(statisticsView)
        
        NSLayoutConstraint.activate([
            statisticsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statisticsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            statisticsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            statisticsView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

#Preview("Tennis Match Statistics") {
    PreviewUIViewController {
        let vc = UIViewController()
        let statisticsView = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.tennisMatch)
        statisticsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(statisticsView)
        
        NSLayoutConstraint.activate([
            statisticsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statisticsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            statisticsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            statisticsView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

#Preview("Loading State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let statisticsView = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.loadingState)
        statisticsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(statisticsView)
        
        NSLayoutConstraint.activate([
            statisticsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statisticsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            statisticsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            statisticsView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

#Preview("Error State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let statisticsView = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.errorState)
        statisticsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(statisticsView)
        
        NSLayoutConstraint.activate([
            statisticsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statisticsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            statisticsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            statisticsView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

#Preview("Empty State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let statisticsView = StatisticsWidgetView(viewModel: MockStatisticsWidgetViewModel.emptyState)
        statisticsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(statisticsView)
        
        NSLayoutConstraint.activate([
            statisticsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statisticsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            statisticsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            statisticsView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}


#endif

// MARK: - Statistics Tab Selector Adapter

private class StatisticsTabSelectorViewModel: MarketGroupSelectorTabViewModelProtocol {
    
    private let statisticsViewModel: StatisticsWidgetViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(statisticsViewModel: StatisticsWidgetViewModelProtocol) {
        self.statisticsViewModel = statisticsViewModel
    }
    
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> {
        statisticsViewModel.tabsPublisher
            .map { tabs in
                tabs.enumerated().map { index, tab in
                    MarketGroupTabItemData(
                        id: tab.id,
                        title: tab.title,
                        visualState: index == self.statisticsViewModel.currentSelectedTabIndex ? .selected : .idle
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> {
        statisticsViewModel.selectedTabIdPublisher
    }
    
    var selectionEventPublisher: AnyPublisher<MarketGroupSelectionEvent, Never> {
        statisticsViewModel.selectedTabIdPublisher
            .dropFirst()
            .compactMap { selectedId in
                guard let selectedId = selectedId else { return nil }
                return MarketGroupSelectionEvent(selectedId: selectedId)
            }
            .eraseToAnyPublisher()
    }
    
    var currentSelectedMarketGroupId: String? {
        statisticsViewModel.currentSelectedTabId
    }
    
    var currentMarketGroups: [MarketGroupTabItemData] {
        statisticsViewModel.currentTabs.enumerated().map { index, tab in
            MarketGroupTabItemData(
                id: tab.id,
                title: tab.title,
                visualState: index == statisticsViewModel.currentSelectedTabIndex ? .selected : .idle
            )
        }
    }
    
    func selectMarketGroup(id: String) {
        statisticsViewModel.selectTab(id: id)
    }
    
    func updateMarketGroups(_ marketGroups: [MarketGroupTabItemData]) {
        // Not implemented for this adapter
    }
    
    func addMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        // Not implemented for this adapter
    }
    
    func removeMarketGroup(id: String) {
        // Not implemented for this adapter
    }
    
    func updateMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        // Not implemented for this adapter
    }
    
    func clearSelection() {
        // Not implemented for this adapter
    }
    
    func selectFirstAvailableMarketGroup() {
        if !statisticsViewModel.currentTabs.isEmpty {
            statisticsViewModel.selectTab(index: 0)
        }
    }
}
