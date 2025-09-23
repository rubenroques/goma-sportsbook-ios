import UIKit
import GomaUI
import Combine

// MARK: - NextUpEventsViewController
class NextUpEventsViewController: UIViewController {

    // MARK: - UI Components
    private let quickLinksTabBarView: QuickLinksTabBarView
    private var topBannerSliderView: TopBannerSliderView!
    private var pillSelectorBarView: PillSelectorBarView!
    private var marketGroupSelectorTabView: MarketGroupSelectorTabView!
    private var pageViewController: UIPageViewController!
    
    private let loadingIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()

        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }()

    // MARK: - Properties
    private let viewModel: NextUpEventsViewModel
    private var marketGroupControllers: [String: MarketGroupCardsViewController] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var isAnimating = false // Track animation state
    
    // MARK: - Header Animation Properties
    private var headerContainerView: UIView!
    private var headerTopConstraint: NSLayoutConstraint!
    private var isHeaderVisible = true
    private let headerAnimationDuration: TimeInterval = 0.37
    private var pillsContainerStackView: UIStackView!
    private let scrollThreshold: CGFloat = 12.0 // Minimum scroll to trigger hide
    private var headerHeight: CGFloat = 142.0 // Will be calculated dynamically (40 + 60 + 42)

    // MARK: - Lifecycle
    init(viewModel: NextUpEventsViewModel) {
        self.viewModel = viewModel
        self.quickLinksTabBarView = QuickLinksTabBarView(viewModel: viewModel.quickLinksTabBarViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupBindings()
        
        loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderHeightIfNeeded()
    }
    
    private func updateHeaderHeightIfNeeded() {
        let calculatedHeight = headerContainerView.frame.height + 4
        
        // Only update if height actually changed and is valid
        guard calculatedHeight > 0 && abs(calculatedHeight - headerHeight) > 0.1 else { return }
        
        headerHeight = calculatedHeight
        // Update all existing market group controllers
        for controller in marketGroupControllers.values {
            controller.topContentInset = headerHeight
        }
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = UIColor.App.backgroundPrimary

        setupHeaderContainer()
        setupQuickLinksTabBar()
        setupTopBannerSliderView()
        setupPillSelectorBarView()
        setupMarketGroupSelectorTabView()
        setupPageViewController()
        setupLoadingIndicator()
        
        setupConstraints()
    }
    
    private func setupHeaderContainer() {
        headerContainerView = UIView()
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.backgroundColor = UIColor.App.backgroundPrimary
        view.addSubview(headerContainerView)
    }

    private func setupMarketGroupSelectorTabView() {
        marketGroupSelectorTabView = MarketGroupSelectorTabView(viewModel: viewModel.marketGroupSelectorViewModel)
        marketGroupSelectorTabView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(marketGroupSelectorTabView)
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
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.didMove(toParent: self)
        
        // Send page view controller to back so header can overlay
        view.sendSubviewToBack(pageViewController.view)
    }

    private func setupQuickLinksTabBar() {
        headerContainerView.addSubview(quickLinksTabBarView)
        quickLinksTabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup QuickLinks navigation callback
        quickLinksTabBarView.onQuickLinkSelected = { [weak self] quickLinkType in
            print("🎯 NextUpEventsViewController: QuickLink tapped - \(quickLinkType.rawValue)")
            // This callback is already handled by the production QuickLinksTabBarViewModel
            // which will trigger the onCasinoQuickLinkSelected closure in the ViewModel
        }
    }

    private func setupTopBannerSliderView() {
        topBannerSliderView = TopBannerSliderView(viewModel: viewModel.topBannerSliderViewModel)
        topBannerSliderView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(topBannerSliderView)

        // Setup banner tap callback
        topBannerSliderView.onBannerTapped = { [weak self] bannerIndex in
            print("🎯 NextUpEventsViewController: Sports Banner tapped at index - \(bannerIndex)")
            // Banner action handling is done through the ViewModel callbacks
        }
    }

    private func setupPillSelectorBarView() {
        pillSelectorBarView = PillSelectorBarView(viewModel: viewModel.pillSelectorBarViewModel)
        pillSelectorBarView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create horizontal stack view for pills + filter button
        let pillsContainerStackView = UIStackView()
        pillsContainerStackView.axis = .horizontal
        pillsContainerStackView.distribution = .fill
        pillsContainerStackView.alignment = .fill
        pillsContainerStackView.spacing = 0
        pillsContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create filter button container (red for debugging)
        let filterButtonContainer = UIView()
        filterButtonContainer.backgroundColor = UIColor.App.navPills
        filterButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Create filter pill button
        let filterPillData = PillData(
            id: "filter",
            title: "Filter",
            leftIconName: "line.3.horizontal.decrease",
            showExpandIcon: true,
            isSelected: false
        )
        let filterPillViewModel = MockPillItemViewModel(pillData: filterPillData)
        let filterPillView = PillItemView(viewModel: filterPillViewModel)
        filterPillView.translatesAutoresizingMaskIntoConstraints = false
        
        // Handle filter button tap - delegate to ViewModel (MVVM-C pattern)
        filterPillView.onPillSelected = { [weak self] in
            self?.viewModel.onFiltersRequested()
        }
        
        // Add filter pill to container with padding
        filterButtonContainer.addSubview(filterPillView)
        
        // Add views to stack
        pillsContainerStackView.addArrangedSubview(pillSelectorBarView)
        pillsContainerStackView.addArrangedSubview(filterButtonContainer)
        
        // Add stack to header container
        headerContainerView.addSubview(pillsContainerStackView)
        self.pillsContainerStackView = pillsContainerStackView
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Stack view constraints (now positioned after topBannerSliderView)
            pillsContainerStackView.topAnchor.constraint(equalTo: topBannerSliderView.bottomAnchor),
            pillsContainerStackView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            pillsContainerStackView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),

            // Filter pill constraints within container (8px padding)
            filterPillView.topAnchor.constraint(equalTo: filterButtonContainer.topAnchor, constant: 8),
            filterPillView.leadingAnchor.constraint(equalTo: filterButtonContainer.leadingAnchor, constant: 8),
            filterPillView.trailingAnchor.constraint(equalTo: filterButtonContainer.trailingAnchor, constant: -8),
            filterPillView.bottomAnchor.constraint(equalTo: filterButtonContainer.bottomAnchor, constant: -8),
            filterPillView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Handle pill selection events - delegate to ViewModel (MVVM-C pattern)
        pillSelectorBarView.onPillSelected = { [weak self] pillId in
            print("🎯 NextUpEventsViewController: Pill selected - \(pillId)")
            if pillId == "sport_selector" {
                self?.viewModel.onSportsSelectionRequested()
            }
            // Other pills can be handled here as needed
        }
        
        // Handle sports selector modal presentation - delegate to ViewModel (MVVM-C pattern)
        viewModel.pillSelectorBarViewModel.onShowSportsSelector = { [weak self] in
            self?.viewModel.onSportsSelectionRequested()
        }
    }

    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicatorView)
    }

    private func setupConstraints() {
        // Header container constraints - positioned as overlay
        headerTopConstraint = headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([
            // Header Container - floating overlay
            headerTopConstraint,
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainerView.bottomAnchor.constraint(equalTo: marketGroupSelectorTabView.bottomAnchor),
            
            // Quick Links Tab Bar inside header container
            quickLinksTabBarView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            quickLinksTabBarView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            quickLinksTabBarView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),

            
            // Top Banner Slider below Quick Links Tab Bar
            topBannerSliderView.heightAnchor.constraint(equalToConstant: TopBannerSliderView.bannerHeight),
            topBannerSliderView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor),
            topBannerSliderView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            topBannerSliderView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),

            // Market Group Selector below Pills Container inside header container
            marketGroupSelectorTabView.topAnchor.constraint(equalTo: pillsContainerStackView.bottomAnchor),
            marketGroupSelectorTabView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            marketGroupSelectorTabView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            marketGroupSelectorTabView.heightAnchor.constraint(equalToConstant: 42),

            // Page View Controller - decoupled from header, starts from top
            pageViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Loading Indicator
            loadingIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBindings() {
        // Bind to market groups changes from ViewModel
        viewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                self?.updateMarketGroupControllers(marketGroups: marketGroups)
            }
            .store(in: &cancellables)

        // Bind to selection changes from ViewModel
        viewModel.selectedMarketGroupIdPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedId in
                guard let selectedId = selectedId else { return }
                self?.handleMarketGroupSelection(marketGroupId: selectedId)
            }
            .store(in: &cancellables)

        // Bind to loading state (optional, for showing loading indicators)
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.setLoadingIndicatorVisible(isLoading)
            }
            .store(in: &cancellables)
        
//        generalFilterBarView.onMainFilterTapped = { [weak self] in
//            
//            self?.openCombinedFilters()
//        }
        
        viewModel.filterOptionItems
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] filterOptionItems in
                // self?.generalFilterBarView.updateFilterItems(filterOptionItems: filterOptionItems)
            })
            .store(in: &cancellables)
        
    }

    // MARK: - Data Loading
    private func loadData() {
        viewModel.reloadEvents()
    }
    
    // MARK: Functions
    private func openCombinedFilters() {
        // Filter presentation should be handled by the Coordinator
        // This method delegates navigation to the ViewModel closure
        viewModel.onFiltersRequested()
    }

    // MARK: - UI Updates
    private func updateMarketGroupControllers(marketGroups: [MarketGroupTabItemData]) {
        print("Updating UI controllers for \(marketGroups.count) groups")

        // Create UI controllers for each market group ViewModel
        for marketGroup in marketGroups {
            if marketGroupControllers[marketGroup.id] == nil {
                // Get the ViewModel from the main ViewModel
                guard let marketGroupCardsViewModel = viewModel.getMarketGroupCardsViewModel(for: marketGroup.id) else {
                    print("No ViewModel found for market type: \(marketGroup.id)")
                    continue
                }

                // Create UI controller with ViewModel
                let controller = MarketGroupCardsViewController(viewModel: marketGroupCardsViewModel)
                controller.scrollDelegate = self
                controller.topContentInset = headerHeight
                
                // Add card tap callback for match detail navigation - delegate to ViewModel (MVVM-C pattern)
                controller.onCardTapped = { [weak self] selectedMatch in
                    self?.viewModel.onMatchSelected(selectedMatch)
                }
                
                marketGroupControllers[marketGroup.id] = controller
                print("Created new UI controller for market type: \(marketGroup.id)")
            }
        }

        // Remove controllers for market groups that no longer exist
        let currentMarketGroupIds = Set(marketGroups.map { $0.id })
        let controllersToRemove = marketGroupControllers.keys.filter { !currentMarketGroupIds.contains($0) }
        for idToRemove in controllersToRemove {
            marketGroupControllers.removeValue(forKey: idToRemove)
            print("Removed UI controller for market type: \(idToRemove)")
        }

        // Set initial page if needed
        if pageViewController.viewControllers?.isEmpty == true,
           let firstMarketGroup = marketGroups.first,
           let firstController = marketGroupControllers[firstMarketGroup.id] {
            pageViewController.setViewControllers([firstController], direction: .forward, animated: false, completion: nil)
            print("Set initial page controller for market type: \(firstMarketGroup.id)")
        }
    }

    private func handleMarketGroupSelection(marketGroupId: String) {
        // Prevent multiple animations at once
        guard !isAnimating else {
            print("Animation already in progress, ignoring selection")
            return
        }

        guard let targetController = marketGroupControllers[marketGroupId] else {
            print("No UI controller found for market type: \(marketGroupId)")
            return
        }

        // Get current controller to determine animation direction
        let currentController = pageViewController.viewControllers?.first as? MarketGroupCardsViewController
        let currentMarketTypeId = currentController.flatMap { getCurrentMarketTypeId(for: $0) }

        // If we're already on the target page, no need to animate
        if currentMarketTypeId == marketGroupId {
            print("Already on target market type: \(marketGroupId)")
            return
        }

        // Determine animation direction based on tab positions
        let direction = determineAnimationDirection(
            from: currentMarketTypeId,
            to: marketGroupId
        )

        isAnimating = true

        pageViewController.setViewControllers(
            [targetController],
            direction: direction,
            animated: true,
            completion: { [weak self] completed in
                self?.isAnimating = false
                if completed {
                    print("Successfully switched to market type: \(marketGroupId)")
                } else {
                    print("Failed to switch to market type: \(marketGroupId)")
                }
            }
        )
    }

    // MARK: - Animation Direction Helper
    private func determineAnimationDirection(from currentMarketTypeId: String?, to targetMarketTypeId: String) -> UIPageViewController.NavigationDirection {
        guard let currentMarketTypeId = currentMarketTypeId else {
            return .forward
        }

        guard currentMarketTypeId != targetMarketTypeId else {
            return .forward
        }

        let marketGroups = viewModel.getCurrentMarketGroups()
        guard let currentIndex = marketGroups.firstIndex(where: { $0.id == currentMarketTypeId }),
              let targetIndex = marketGroups.firstIndex(where: { $0.id == targetMarketTypeId }) else {
            return .forward
        }

        return targetIndex > currentIndex ? .forward : .reverse
    }

    private func setLoadingIndicatorVisible(_ isVisible: Bool) {
        if isVisible {
            // Show loading indicator
            loadingIndicatorView.isHidden = false
            loadingIndicatorView.alpha = 0.0
            UIView.animate(withDuration: 0.03) {
                self.loadingIndicatorView.alpha = 1.0
            }
        } else {
            // Hide loading indicator
            UIView.animate(withDuration: 0.1) {
                self.loadingIndicatorView.alpha = 0.0
            } completion: { _ in
                self.loadingIndicatorView.isHidden = true
            }
        }
    }

    // MARK: - Testing Helper (can be removed in production)
    @objc private func testLoadingIndicator() {
        // Toggle loading state for testing
        let newState = !viewModel.isLoading
        if newState {
            print("Testing: Showing loading indicator")
        } else {
            print("Testing: Hiding loading indicator")
        }
        // Note: Normally you wouldn't set isLoading directly,
        // but this is useful for testing the UI behavior
    }
    
    // MARK: - Header Animation
    private func animateHeader(show: Bool) {
        guard isHeaderVisible != show else { return }
        
        isHeaderVisible = show
        let targetOffset = show ? 0 : -headerHeight
        
        UIView.animate(
            withDuration: headerAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.headerTopConstraint.constant = targetOffset
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    // MARK: - Navigation Methods Removed (MVVM-C Pattern)
    // All navigation now handled by coordinators through ViewModel closures:
    // - presentSportsSelector() -> viewModel.onSportsSelectionRequested?()  
    // - presentFilters() -> viewModel.onFiltersRequested?()
    // - onMatchSelected() -> viewModel.onMatchSelected?(match)
    //
    // This follows proper MVVM-C separation:
    // - ViewController: Pure UI presentation
    // - ViewModel: Business logic + navigation signals (closures)
    // - Coordinator: Navigation implementation
}

// MARK: - UIPageViewControllerDataSource
extension NextUpEventsViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? MarketGroupCardsViewController,
              let currentMarketTypeId = getCurrentMarketTypeId(for: currentController),
              let currentIndex = getMarketGroupIndex(for: currentMarketTypeId),
              currentIndex > 0 else {
            return nil
        }

        let marketGroups = viewModel.getCurrentMarketGroups()
        let previousMarketTypeId = marketGroups[currentIndex - 1].id
        return marketGroupControllers[previousMarketTypeId]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? MarketGroupCardsViewController,
              let currentMarketTypeId = getCurrentMarketTypeId(for: currentController),
              let currentIndex = getMarketGroupIndex(for: currentMarketTypeId) else {
            return nil
        }

        let marketGroups = viewModel.getCurrentMarketGroups()
        guard currentIndex < marketGroups.count - 1 else {
            return nil
        }

        let nextMarketTypeId = marketGroups[currentIndex + 1].id
        return marketGroupControllers[nextMarketTypeId]
    }

    // MARK: - Helper Methods
    private func getCurrentMarketTypeId(for controller: MarketGroupCardsViewController) -> String? {
        return marketGroupControllers.first { $0.value === controller }?.key
    }

    private func getMarketGroupIndex(for marketTypeId: String) -> Int? {
        return viewModel.getCurrentMarketGroups().firstIndex { $0.id == marketTypeId }
    }
}

// MARK: - UIPageViewControllerDelegate
extension NextUpEventsViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        // Reset animation state regardless of completion
        isAnimating = false

        guard completed,
              let currentController = pageViewController.viewControllers?.first as? MarketGroupCardsViewController,
              let currentMarketTypeId = getCurrentMarketTypeId(for: currentController) else {
            return
        }

        // Update the tab selection to match the current page
        // Only if we're not currently processing a tab selection (to avoid circular updates)
        if viewModel.getCurrentSelectedMarketGroupId() != currentMarketTypeId {
            viewModel.selectMarketGroup(id: currentMarketTypeId)
            print("Updated tab selection to match page: \(currentMarketTypeId)")
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // Set animation state when transition begins (for user swipes)
        isAnimating = true
        
        // Show header when swiping between pages
        animateHeader(show: true)
    }
}

// MARK: - MarketGroupCardsScrollDelegate
extension NextUpEventsViewController: MarketGroupCardsScrollDelegate {
    
    func marketGroupCardsDidScroll(_ scrollView: UIScrollView, scrollDirection: ScrollDirection, in viewController: MarketGroupCardsViewController) {
        // Only react to scroll from the currently visible page
        guard let currentController = pageViewController.viewControllers?.first,
              currentController === viewController else { return }
        
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.bounds.height
        
        // Calculate if we're at the bottom
        let maxScrollOffset = contentHeight - scrollViewHeight
        let isAtBottom = offset >= maxScrollOffset - 10
        
        // Check if we're bouncing at the bottom
        let isBouncing = offset > maxScrollOffset
        
        // Determine whether to show or hide headers
        if scrollDirection == .down && offset > scrollThreshold && !isAtBottom {
            // Only hide when scrolling down and not near bottom
            animateHeader(show: false)
        } else if scrollDirection == .up && !isBouncing && offset < maxScrollOffset {
            // Only show when scrolling up and not bouncing
            animateHeader(show: true)
        } else if offset <= 0 {
            // Always show at top
            animateHeader(show: true)
        }
    }
    
    func marketGroupCardsDidEndScrolling(_ scrollView: UIScrollView, in viewController: MarketGroupCardsViewController) {
        // Show headers if we're at the top after scrolling ends
        if scrollView.contentOffset.y <= 0 {
            animateHeader(show: true)
        }
    }
}
