//
//  MatchDetailsTextualViewController.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import UIKit
import Combine
import GomaUI

class MatchDetailsTextualViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MatchDetailsTextualViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Navigation Closures
    // Closure called when betslip is requested - handled by coordinator
    var onBetslipRequested: (() -> Void)?
    
    // MARK: - UI Components
    
    private let mainStackView = UIStackView()
    private let pageContainerView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // Loading overlay for page container
    private lazy var pageLoadingOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        view.isHidden = true
        return view
    }()
    
    private lazy var pageLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = UIColor.App.textPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var pageLoadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading markets..."
        label.textColor = UIColor.App.textSecondary
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
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
            imageResolver: AppMarketGroupTabImageResolver()
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Betslip Floating View
    private lazy var betslipFloatingView: BetslipFloatingThinView = {
        let view = BetslipFloatingThinView(viewModel: viewModel.betslipFloatingViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private var pageViewController: UIPageViewController!
    private var marketControllers: [String: MarketsTabSimpleViewController] = [:]
    private var isAnimating = false
    private var isFirstStatisticsUpdate = true
    private var marketGroupsSubscription: AnyCancellable?
    
    // MARK: - Initialization
    
    init(viewModel: MatchDetailsTextualViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        
        self.setupBindings()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        
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
        view.addSubview(mainStackView)
        view.addSubview(pageContainerView)
        view.addSubview(loadingIndicator)
        
        // Add loading overlay on top of page container
        view.addSubview(pageLoadingOverlay)
        pageLoadingOverlay.addSubview(pageLoadingIndicator)
        pageLoadingOverlay.addSubview(pageLoadingLabel)
        
        // Add betslip floating view
        view.addSubview(betslipFloatingView)
        
        setupComponents()
    }
    
    private func setupComponents() {
        setupMatchDateNavigationBarView()

        setupMatchHeaderCompactView()

        setupStatisticsWidgetView()

        setupMarketGroupSelectorTabView()

        setupPageViewController()
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
        
        pageViewController.willMove(toParent: self)
        
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
    }
    
    private func handleMarketGroupSelection(_ selectionEvent: MarketGroupSelectionEvent) {
        // Prevent animation if already animating
        guard !isAnimating else { 
            print("[📱MTDTXT] Already animating, ignoring selection")
            return 
        }
        
        guard let targetController = marketControllers[selectionEvent.selectedId] else {
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
        viewModel.navigateBack()
    }
    
    
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
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
            loadingIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Page loading overlay (covers page container)
            pageLoadingOverlay.topAnchor.constraint(equalTo: pageContainerView.topAnchor),
            pageLoadingOverlay.leadingAnchor.constraint(equalTo: pageContainerView.leadingAnchor),
            pageLoadingOverlay.trailingAnchor.constraint(equalTo: pageContainerView.trailingAnchor),
            pageLoadingOverlay.bottomAnchor.constraint(equalTo: pageContainerView.bottomAnchor),
            
            // Page loading indicator (centered in overlay)
            pageLoadingIndicator.centerXAnchor.constraint(equalTo: pageLoadingOverlay.centerXAnchor),
            pageLoadingIndicator.centerYAnchor.constraint(equalTo: pageLoadingOverlay.centerYAnchor, constant: -16),
            
            // Page loading label (below indicator)
            pageLoadingLabel.topAnchor.constraint(equalTo: pageLoadingIndicator.bottomAnchor, constant: 16),
            pageLoadingLabel.centerXAnchor.constraint(equalTo: pageLoadingOverlay.centerXAnchor),
            pageLoadingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: pageLoadingOverlay.leadingAnchor, constant: 20),
            pageLoadingLabel.trailingAnchor.constraint(lessThanOrEqualTo: pageLoadingOverlay.trailingAnchor, constant: -20)
        ])
        
        // Page container view constraints
        NSLayoutConstraint.activate([
            pageContainerView.topAnchor.constraint(equalTo: marketGroupSelectorTabView.bottomAnchor),
            pageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Betslip floating view constraints
        NSLayoutConstraint.activate([
            betslipFloatingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            betslipFloatingView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
        
    }
    
    private func setupBindings() {

        // Wire ViewModel's betslip callback to Coordinator
        viewModel.onBetslipRequested = { [weak self] in
            self?.onBetslipRequested?()
        }

        // Bind loading state
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.loadingIndicator.startAnimating()
                    self.pageLoadingOverlay.isHidden = false
                    self.pageLoadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.pageLoadingOverlay.isHidden = true
                    self.pageLoadingIndicator.stopAnimating()
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
                guard let self = self else { return }
                self.marketGroupSelectorTabView.configure(with: newViewModel)
                
                // CRITICAL: Re-subscribe to market groups when view model instance changes
                self.subscribeToMarketGroupsData()
            }
            .store(in: &cancellables)
        
        
        // Initial subscription to market groups data
        subscribeToMarketGroupsData()
    }
    
    // MARK: - Market Groups Subscription
    
    private func subscribeToMarketGroupsData() {
        // Cancel any existing subscription to avoid memory leaks
        marketGroupsSubscription?.cancel()
        
        
        // Subscribe to market groups data changes from the CURRENT view model instance
        marketGroupsSubscription = viewModel.marketGroupSelectorTabViewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                guard let self = self else { return }
                
                // Recreate market controllers when market groups data changes
                self.recreateMarketControllers()
                
                // Set initial page if we have market groups and no current page
                if let firstMarketGroupId = marketGroups.first?.id,
                   let firstController = self.marketControllers[firstMarketGroupId],
                   self.pageViewController.viewControllers?.isEmpty == true {
                    self.pageViewController.setViewControllers([firstController], direction: .forward, animated: false)
                }
            }
    }
    
    // MARK: - Helper Methods
    private func recreateMarketControllers() {
        print("[📱MTDTXT] recreateMarketControllers - start")
        
        // Clear existing controllers
        marketControllers.removeAll()
        
        // Create new controllers for current market groups
        let marketGroups = viewModel.marketGroupSelectorTabViewModel.currentMarketGroups
        print("[📱MTDTXT] Recreating \(marketGroups.count) market controllers")
        
        for marketGroup in marketGroups {
            print("[📱MTDTXT] Recreating controller for group: \(marketGroup.id) - \(marketGroup.title)")
            
            // Create proper view model with all required data
            let tabViewModel = MarketsTabSimpleViewModel(
                marketGroupId: marketGroup.id,
                marketGroupTitle: marketGroup.title,
                eventId: viewModel.eventId,
                marketGroupKey: marketGroup.id // Using marketGroup.id as key for now
            )
            
            tabViewModel.onOutcomeSelected = { [weak self] marketGroup, outcomeId in
                self?.viewModel.handleOutcomeSelection(marketGroup: marketGroup, outcomeId: outcomeId, isSelected: true)
            }
            
            tabViewModel.onOutcomeDeselected = { [weak self] marketGroup, outcomeId in
                self?.viewModel.handleOutcomeSelection(marketGroup: marketGroup, outcomeId: outcomeId, isSelected: false)
            }
            
            let controller = MarketsTabSimpleViewController(viewModel: tabViewModel)
            marketControllers[marketGroup.id] = controller
            
            print("[📱MTDTXT] Recreated controller for group: \(marketGroup.id)")
        }
        
        print("[📱MTDTXT] recreateMarketControllers - completed with \(marketControllers.count) controllers")
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
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? MarketsTabSimpleViewController else { return nil }
        
        let marketGroups = viewModel.marketGroupSelectorTabViewModel.currentMarketGroups
        guard let currentIndex = marketGroups.firstIndex(where: { $0.id == currentController.marketGroupId }) else { return nil }
        
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 else { return nil }
        
        let previousMarketGroup = marketGroups[previousIndex]
        return marketControllers[previousMarketGroup.id]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentController = pageViewController.viewControllers?.first as? MarketsTabSimpleViewController else { return }
        
        // Update the tab selection to match the current page
        // This ensures the tab bar reflects the current page when user swipes
        viewModel.marketGroupSelectorTabViewModel.selectMarketGroup(id: currentController.marketGroupId)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // Optional: Handle will transition if needed
    }
}
