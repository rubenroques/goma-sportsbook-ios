//
//  MatchDetailsTextualViewController.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import UIKit
import Combine
import GomaUI

public class MatchDetailsTextualViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MatchDetailsTextualViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var topSafeAreaView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView = UIStackView()
    private let pageContainerView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private lazy var multiWidgetToolbarView: MultiWidgetToolbarView = {
        let view = MultiWidgetToolbarView(viewModel: viewModel.multiWidgetToolbarViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var matchDateNavigationBarView: MatchDateNavigationBarView = {
        let view = MatchDateNavigationBarView(viewModel: viewModel.matchDateNavigationBarViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var matchHeaderCompactView: MatchHeaderCompactView = {
        let view = MatchHeaderCompactView(viewModel: viewModel.matchHeaderCompactViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statisticsWidgetView: StatisticsWidgetView = {
        let view = StatisticsWidgetView(viewModel: viewModel.statisticsWidgetViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Statistics height constraint for collapsible animation
    private var statisticsHeightConstraint: NSLayoutConstraint!
    
    private lazy var marketGroupSelectorTabView: MarketGroupSelectorTabView = {
        let view = MarketGroupSelectorTabView(
            viewModel: viewModel.marketGroupSelectorTabViewModel,
            imageResolver: AppMarketGroupTabImageResolver(),
            backgroundStyle: .light
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var pageViewController: UIPageViewController!
    private var marketControllers: [String: MarketsTabSimpleViewController] = [:]
    private var isAnimating = false
    private var isFirstStatisticsUpdate = true
    
    // MARK: - Initialization
    
    public init(viewModel: MatchDetailsTextualViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        
        self.setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        topSafeAreaView.backgroundColor = UIColor.App.topBarGradient1
        
        // Configure page container view
        pageContainerView.translatesAutoresizingMaskIntoConstraints = false
        pageContainerView.backgroundColor = .clear
        
        // Configure main stack view
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        
        // Configure loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .systemGray
        
        // Add views to hierarchy
        view.addSubview(topSafeAreaView)
        view.addSubview(mainStackView)
        view.addSubview(pageContainerView)
        view.addSubview(loadingIndicator)
        
        setupComponents()
    }
    
    private func setupComponents() {
        setupMultiWidgetToolbarView()
        
        setupMatchDateNavigationBarView()
        
        setupMatchHeaderCompactView()
        
        setupStatisticsWidgetView()
        
        setupMarketGroupSelectorTabView()
        
        setupPageViewController()
    }
    
    private func setupMultiWidgetToolbarView() {
        mainStackView.addArrangedSubview(multiWidgetToolbarView)
        
        // Setup widget selection handling
        multiWidgetToolbarView.onWidgetSelected = { [weak self] widgetID in
            self?.handleWidgetSelection(widgetID)
        }
    }
    
    private func setupMatchDateNavigationBarView() {
        mainStackView.addArrangedSubview(matchDateNavigationBarView)
        
        // Setup back button handling
        matchDateNavigationBarView.onBackTapped = { [weak self] in
            self?.handleBackTapped()
        }
    }
    
    private func setupMatchHeaderCompactView() {
        mainStackView.addArrangedSubview(matchHeaderCompactView)
        
        // The statistics button tap is handled through the view model binding
        // (setupBindings() in the view model wires up the statistics toggle)
    }
    
    private func setupStatisticsWidgetView() {
        mainStackView.addArrangedSubview(statisticsWidgetView)
        
        // Set up the height constraint for collapsible animation
        statisticsHeightConstraint = statisticsWidgetView.heightAnchor.constraint(equalToConstant: 0)
        statisticsHeightConstraint.isActive = true
        
        // Initially hidden
        statisticsWidgetView.isHidden = true

        statisticsWidgetView.clipsToBounds = true
    }
    
    private func setupMarketGroupSelectorTabView() {
        mainStackView.addArrangedSubview(marketGroupSelectorTabView)
        
        // Set up market group selection handling
        viewModel.marketGroupSelectorTabViewModel.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectionEvent in
                self?.handleMarketGroupSelection(selectionEvent)
            }
            .store(in: &cancellables)
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageContainerView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        // Set up page view controller constraints
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: pageContainerView.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: pageContainerView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: pageContainerView.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageContainerView.bottomAnchor)
        ])
        
        // Initialize market controllers based on current market groups
        initializeMarketControllers()
        
        // Set initial page if we have market groups
        if let firstMarketGroupId = viewModel.marketGroupSelectorTabViewModel.currentMarketGroups.first?.id,
           let firstController = marketControllers[firstMarketGroupId] {
            pageViewController.setViewControllers([firstController], direction: .forward, animated: false)
        }
    }
    
    private func initializeMarketControllers() {
        let marketGroups = viewModel.marketGroupSelectorTabViewModel.currentMarketGroups
        
        for marketGroup in marketGroups {
            let controller = MarketsTabSimpleViewController(marketGroupId: marketGroup.id, title: marketGroup.title)
            marketControllers[marketGroup.id] = controller
        }
    }
    
    private func handleMarketGroupSelection(_ selectionEvent: MarketGroupSelectionEvent) {
        print("Market group selected: \(selectionEvent.selectedId)")
        
        // Prevent animation if already animating
        guard !isAnimating else { return }
        
        guard let targetController = marketControllers[selectionEvent.selectedId] else {
            print("No controller found for market group: \(selectionEvent.selectedId)")
            return
        }
        
        // Get current controller to determine animation direction
        let currentController = pageViewController.viewControllers?.first as? MarketsTabSimpleViewController
        let currentMarketGroupId = currentController?.marketGroupId
        
        // If we're already on the target page, no need to animate
        if currentMarketGroupId == selectionEvent.selectedId {
            print("Already on target market group: \(selectionEvent.selectedId)")
            return
        }
        
        // Determine animation direction based on tab positions
        let direction = determineAnimationDirection(
            from: currentMarketGroupId,
            to: selectionEvent.selectedId
        )
        
        isAnimating = true
        
        pageViewController.setViewControllers(
            [targetController],
            direction: direction,
            animated: true,
            completion: { [weak self] completed in
                self?.isAnimating = false
                if completed {
                    print("Successfully switched to market group: \(selectionEvent.selectedId)")
                } else {
                    print("Failed to switch to market group: \(selectionEvent.selectedId)")
                }
            }
        )
    }
    
    private func determineAnimationDirection(from currentMarketGroupId: String?, to targetMarketGroupId: String) -> UIPageViewController.NavigationDirection {
        guard let currentMarketGroupId = currentMarketGroupId else {
            return .forward
        }
        
        guard currentMarketGroupId != targetMarketGroupId else {
            return .forward
        }
        
        let marketGroups = viewModel.marketGroupSelectorTabViewModel.currentMarketGroups
        
        // Find indices of current and target market groups
        guard let currentIndex = marketGroups.firstIndex(where: { $0.id == currentMarketGroupId }),
              let targetIndex = marketGroups.firstIndex(where: { $0.id == targetMarketGroupId }) else {
            return .forward
        }
        
        // If target is to the right of current, go forward; otherwise, go backward
        return targetIndex > currentIndex ? .forward : .reverse
    }
    
    private func handleBackTapped() {
        // Or directly navigate
        navigationController?.popViewController(animated: true)
    }
    
    private func handleWidgetSelection(_ widgetID: String) {
        print("Widget selected: \(widgetID)")
        
        // Handle specific widget actions
        switch widgetID {
        case "avatar":
            // Navigate to user profile
            break
        case "wallet":
            // Navigate to wallet/balance
            break
        case "support":
            // Show support/help
            break
        case "loginButton":
            // Navigate to login
            break
        case "joinButton":
            // Navigate to registration
            break
        default:
            break
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Top Safe Area
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            
            // Main stack view (fixed at top)
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Page container view (fills remaining space)
            pageContainerView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor),
            pageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Loading indicator (top-right corner)
            loadingIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            loadingIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        // Bind loading state
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // Bind error state
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
        
        // Bind statistics visibility
        viewModel.statisticsVisibilityPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                guard let self = self else { return }
                let animated = !self.isFirstStatisticsUpdate
                self.isFirstStatisticsUpdate = false
                self.updateStatisticsVisibility(isVisible, animated: animated)
            }
            .store(in: &cancellables)
        
        // Bind market group selector tab view model changes
        viewModel.marketGroupSelectorTabViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newViewModel in
                self?.updateMarketGroupSelectorTabView(with: newViewModel)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    private func updateMarketGroupSelectorTabView(with newViewModel: MarketGroupSelectorTabViewModelProtocol) {
        // Efficiently reconfigure existing view with new view model (follows GomaUI pattern)
        marketGroupSelectorTabView.configure(with: newViewModel)
        
        // Recreate market controllers for new market groups
        recreateMarketControllers()
        
        // Set initial page if we have market groups
        if let firstMarketGroupId = newViewModel.currentMarketGroups.first?.id,
           let firstController = marketControllers[firstMarketGroupId] {
            pageViewController.setViewControllers([firstController], direction: .forward, animated: false)
        }
    }
    
    private func recreateMarketControllers() {
        // Clear existing controllers
        marketControllers.removeAll()
        
        // Create new controllers for current market groups
        let marketGroups = viewModel.marketGroupSelectorTabViewModel.currentMarketGroups
        for marketGroup in marketGroups {
            let controller = MarketsTabSimpleViewController(marketGroupId: marketGroup.id, title: marketGroup.title)
            marketControllers[marketGroup.id] = controller
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.refresh()
        })
        present(alert, animated: true)
    }
        
    private func updateStatisticsVisibility(_ isVisible: Bool, animated: Bool) {
        if animated {
            // Animate statistics widget visibility
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.statisticsHeightConstraint.constant = isVisible ? 220 : 0
                self.statisticsWidgetView.isHidden = !isVisible
                self.view.layoutIfNeeded()
            }
        } else {
            // Set initial state without animation
            self.statisticsHeightConstraint.constant = isVisible ? 220 : 0
            self.statisticsWidgetView.isHidden = !isVisible
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension MatchDetailsTextualViewController: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? MarketsTabSimpleViewController else { return nil }
        
        let marketGroups = viewModel.marketGroupSelectorTabViewModel.currentMarketGroups
        guard let currentIndex = marketGroups.firstIndex(where: { $0.id == currentController.marketGroupId }) else { return nil }
        
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 else { return nil }
        
        let previousMarketGroup = marketGroups[previousIndex]
        return marketControllers[previousMarketGroup.id]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? MarketsTabSimpleViewController else { return nil }
        
        let marketGroups = viewModel.marketGroupSelectorTabViewModel.currentMarketGroups
        guard let currentIndex = marketGroups.firstIndex(where: { $0.id == currentController.marketGroupId }) else { return nil }
        
        let nextIndex = currentIndex + 1
        guard nextIndex < marketGroups.count else { return nil }
        
        let nextMarketGroup = marketGroups[nextIndex]
        return marketControllers[nextMarketGroup.id]
    }
}

// MARK: - UIPageViewControllerDelegate
extension MatchDetailsTextualViewController: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentController = pageViewController.viewControllers?.first as? MarketsTabSimpleViewController else { return }
        
        // Update the tab selection to match the current page
        // This ensures the tab bar reflects the current page when user swipes
        viewModel.marketGroupSelectorTabViewModel.selectMarketGroup(id: currentController.marketGroupId)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // Optional: Handle will transition if needed
    }
}
