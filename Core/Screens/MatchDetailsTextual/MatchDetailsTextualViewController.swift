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
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // Component views will be added step by step
    // Step 2: MultiWidgetToolbarView
    private lazy var multiWidgetToolbarView: MultiWidgetToolbarView = {
        let view = MultiWidgetToolbarView(viewModel: viewModel.multiWidgetToolbarViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Step 3: MatchDateNavigationBarView
    private lazy var matchDateNavigationBarView: MatchDateNavigationBarView = {
        let view = MatchDateNavigationBarView(viewModel: viewModel.matchDateNavigationBarViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Step 4: MatchHeaderCompactView
    private lazy var matchHeaderCompactView: MatchHeaderCompactView = {
        let view = MatchHeaderCompactView(viewModel: viewModel.matchHeaderCompactViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Step 5: StatisticsWidgetView (collapsible)
    private lazy var statisticsWidgetView: StatisticsWidgetView = {
        let view = StatisticsWidgetView(viewModel: viewModel.statisticsWidgetViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Statistics height constraint for collapsible animation
    private var statisticsHeightConstraint: NSLayoutConstraint!
    
    // Step 6: MarketGroupSelectorTabView
    private lazy var marketGroupSelectorTabView: MarketGroupSelectorTabView = {
        let view = MarketGroupSelectorTabView(
            viewModel: viewModel.marketGroupSelectorTabViewModel,
            imageResolver: AppMarketGroupTabImageResolver(),
            backgroundStyle: .light
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Step 7: UIPageViewController for markets
    private var pageViewController: UIPageViewController!
    private var marketControllers: [String: MarketsTabSimpleViewController] = [:]
    private var isAnimating = false
    
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
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Match Details"
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        // Configure content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure main stack view
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        
        // Configure loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        // Setup components (will be added step by step)
        setupComponents()
    }
    
    private func setupComponents() {
        // Components will be added here step by step:
        // 1. MultiWidgetToolbarView ✅
        // 2. MatchDateNavigationBarView ✅
        // 3. MatchHeaderCompactView ✅
        // 4. StatisticsWidgetView (collapsible) ✅
        // 5. MarketGroupSelectorTabView ✅
        // 6. UIPageViewController for markets ✅
        
        // Step 2: Add MultiWidgetToolbarView
        setupMultiWidgetToolbarView()
        
        // Step 3: Add MatchDateNavigationBarView
        setupMatchDateNavigationBarView()
        
        // Step 4: Add MatchHeaderCompactView
        setupMatchHeaderCompactView()
        
        // Step 5: Add StatisticsWidgetView (collapsible)
        setupStatisticsWidgetView()
        
        // Step 6: Add MarketGroupSelectorTabView
        setupMarketGroupSelectorTabView()
        
        // Step 7: Add UIPageViewController
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
        
        // Initially hidden (height = 0)
        statisticsWidgetView.isHidden = true
        
        // Style the statistics widget
        statisticsWidgetView.backgroundColor = .systemBackground
        statisticsWidgetView.layer.cornerRadius = 8
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
        mainStackView.addArrangedSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
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
        // Notify view model of back navigation request
        viewModel.navigationRequestPublisher
            .first()
            .sink { _ in
                // The binding in setupBindings() will handle the actual navigation
            }
            .store(in: &cancellables)
        
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
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Main stack view
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
        
        // Bind navigation actions
        viewModel.navigationRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                self?.handleNavigationAction(action)
            }
            .store(in: &cancellables)
        
        // Bind statistics visibility
        viewModel.statisticsVisibilityPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                self?.updateStatisticsVisibility(isVisible)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.refresh()
        })
        present(alert, animated: true)
    }
    
    private func handleNavigationAction(_ action: MatchDetailsNavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        case .share:
            // Share functionality placeholder
            break
        case .favorite:
            // Favorite functionality placeholder
            break
        }
    }
    
    private func updateStatisticsVisibility(_ isVisible: Bool) {
        // Animate statistics widget visibility
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
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
