import UIKit
import GomaUI
import Combine

// MARK: - InPlayEventsViewController
class InPlayEventsViewController: UIViewController {

    // MARK: - UI Components
    private let quickLinksTabBarView: QuickLinksTabBarView
    private var topBannerSliderView: TopBannerSliderView!
    private var pillSelectorBarView: PillSelectorBarView!
    private var marketGroupSelectorTabView: MarketGroupSelectorTabView!
    private var pageViewController: UIPageViewController!

    // ComplexScroll: Unified header stack view
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.backgroundColor = UIColor.App.backgroundPrimary
        return stack
    }()
    
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
    private let viewModel: InPlayEventsViewModel
    private var marketGroupControllers: [String: MarketGroupCardsViewController] = [:]
    private var cancellables = Set<AnyCancellable>()

    // MARK: - MVVM-C Navigation Closures (Coordinator handles navigation)
    var onURLOpenRequested: ((URL) -> Void)?
    var onEmailRequested: ((String) -> Void)?

    // MARK: - ComplexScroll Properties
    private var calculatedHeaderHeight: CGFloat = 0
    private var headerHeight: CGFloat {
        return calculatedHeaderHeight > 0 ? calculatedHeaderHeight : 286
    }

    // ComplexScroll: Container view for page controller (like POC)
    private lazy var pageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        return view
    }()

    // Header components container
    private var pillsContainerStackView: UIStackView!

    // Scroll Synchronization Properties
    private var isSyncing = false
    private var lastSyncedOffset: CGFloat = 0

    // MARK: - Lifecycle
    init(viewModel: InPlayEventsViewModel) {
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
        updateHeaderHeightAndInsets()
    }

    // ComplexScroll: Dynamic header height calculation
    private func updateHeaderHeightAndInsets() {
        headerStackView.layoutIfNeeded()
        let newHeaderHeight = headerStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        if abs(newHeaderHeight - calculatedHeaderHeight) > 1 {
            calculatedHeaderHeight = newHeaderHeight
            updateChildTableViewInsets()
        }
    }

    private func updateChildTableViewInsets() {
        for controller in marketGroupControllers.values {
            controller.updateContentInset(headerHeight: headerHeight)
        }
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = UIColor.App.backgroundPrimary

        view.addSubview(pageContainerView)
        
        setupHeaderComponents()
        setupPageViewController()
        setupLoadingIndicator()

        setupConstraints()
    }

    // ComplexScroll: Unified header setup
    private func setupHeaderComponents() {
        // Initialize components
        topBannerSliderView = TopBannerSliderView(viewModel: viewModel.topBannerSliderViewModel)
        pillSelectorBarView = PillSelectorBarView(viewModel: viewModel.pillSelectorBarViewModel)
        marketGroupSelectorTabView = MarketGroupSelectorTabView(viewModel: viewModel.marketGroupSelectorViewModel)

        // Configure components
        topBannerSliderView.translatesAutoresizingMaskIntoConstraints = false
        pillSelectorBarView.translatesAutoresizingMaskIntoConstraints = false
        marketGroupSelectorTabView.translatesAutoresizingMaskIntoConstraints = false
        quickLinksTabBarView.translatesAutoresizingMaskIntoConstraints = false

        // Add to header stack in order (top to bottom)
        headerStackView.addArrangedSubview(quickLinksTabBarView)
        headerStackView.addArrangedSubview(topBannerSliderView)
        headerStackView.addArrangedSubview(createPillsContainer())
        headerStackView.addArrangedSubview(marketGroupSelectorTabView)

        // Add header stack to view
        view.addSubview(headerStackView)

        setupHeaderCallbacks()
    }

    private func createPillsContainer() -> UIStackView {
        // Create horizontal stack view for pills + filter button
        let pillsContainerStackView = UIStackView()
        pillsContainerStackView.axis = .horizontal
        pillsContainerStackView.distribution = .fill
        pillsContainerStackView.alignment = .fill
        pillsContainerStackView.spacing = 0
        pillsContainerStackView.translatesAutoresizingMaskIntoConstraints = false

        // Create filter button container
        let filterButtonContainer = UIView()
        filterButtonContainer.backgroundColor = UIColor.App.navPills
        filterButtonContainer.translatesAutoresizingMaskIntoConstraints = false

        // Create filter pill button (uses FilterPillViewModel for non-toggling action button)
        let filterPillViewModel = FilterPillViewModel()
        let filterPillView = PillItemView(viewModel: filterPillViewModel)
        filterPillView.translatesAutoresizingMaskIntoConstraints = false

        // Handle filter button tap
        filterPillView.onPillSelected = { [weak self] in
            self?.viewModel.onFiltersRequested()
        }

        // Add filter pill to container with padding
        filterButtonContainer.addSubview(filterPillView)

        // Add views to stack
        pillsContainerStackView.addArrangedSubview(pillSelectorBarView)
        pillsContainerStackView.addArrangedSubview(filterButtonContainer)

        // Setup constraints
        NSLayoutConstraint.activate([
            // Filter pill constraints within container (8px padding)
            filterPillView.topAnchor.constraint(equalTo: filterButtonContainer.topAnchor, constant: 8),
            filterPillView.leadingAnchor.constraint(equalTo: filterButtonContainer.leadingAnchor, constant: 8),
            filterPillView.trailingAnchor.constraint(equalTo: filterButtonContainer.trailingAnchor, constant: -8),
            filterPillView.bottomAnchor.constraint(equalTo: filterButtonContainer.bottomAnchor, constant: -8),
            filterPillView.heightAnchor.constraint(equalToConstant: 40)
        ])

        self.pillsContainerStackView = pillsContainerStackView
        return pillsContainerStackView
    }

    private func setupHeaderCallbacks() {
        // Setup banner tap callback
        topBannerSliderView.onBannerTapped = { [weak self] bannerIndex in
            print("🎯 InPlayEventsViewController: Sports Banner tapped at index - \(bannerIndex)")
        }

        // Handle pill selection events
        pillSelectorBarView.onPillSelected = { [weak self] pillId in
            print("🎯 InPlayEventsViewController: Pill selected - \(pillId)")
            if pillId == "sport_selector" {
                self?.viewModel.onSportsSelectionRequested()
            }
        }

        // Handle sports selector modal presentation
        viewModel.pillSelectorBarViewModel.onShowSportsSelector = { [weak self] in
            self?.viewModel.onSportsSelectionRequested()
        }
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
        pageContainerView.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.didMove(toParent: self)
    }



    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicatorView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container fills entire safe area (like POC)
            pageContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            pageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Header Stack View - positioned at safe area top (like POC)
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Top Banner height constraint
            topBannerSliderView.heightAnchor.constraint(equalToConstant: TopBannerSliderView.bannerHeight),

            // Market Group Selector height constraint
            marketGroupSelectorTabView.heightAnchor.constraint(equalToConstant: 42),

            // Page View Controller fills container
            pageViewController.view.topAnchor.constraint(equalTo: pageContainerView.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: pageContainerView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: pageContainerView.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageContainerView.bottomAnchor),

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
    }

    // MARK: - Data Loading
    private func loadData() {
        viewModel.reloadEvents()
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
                controller.scrollSyncDelegate = self
                controller.updateContentInset(headerHeight: headerHeight)

                // Add card tap callback for match detail navigation
                controller.onCardTapped = { [weak self] tappedMatch in
                    self?.viewModel.onMatchSelected(tappedMatch)
                }

                // Add load more callback for pagination - delegate to ViewModel
                controller.onLoadMoreTapped = { [weak self] in
                    print("[InPlayEventsVC] Load more tapped")
                    self?.viewModel.loadNextPage()
                }

                // Wire up footer ViewModel callbacks (MVVM-C pattern)
                marketGroupCardsViewModel.onURLOpenRequested = { [weak self] url in
                    self?.openURL(url)
                }

                marketGroupCardsViewModel.onEmailComposeRequested = { [weak self] email in
                    self?.openEmailCompose(email: email)
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
        print("Handling market group selection: \(marketGroupId)")


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

        pageViewController.setViewControllers(
            [targetController],
            direction: direction,
            animated: true,
            completion: nil
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
    
    // MARK: - ComplexScroll Header Animation
    private func updateHeaderVisibility(for scrollOffset: CGFloat) {
        // ComplexScroll algorithm: scrollOffset ranges from -headerHeight (visible) to 0+ (hidden)
        // When scrollOffset = -headerHeight (showing headers): progress = 1 (fully visible)
        // When scrollOffset = 0 (headers gone): progress = 0 (fully hidden)
        let progress = min(max((-scrollOffset) / headerHeight, 0), 1)
        let translateY = -headerHeight * (1 - progress)

        headerStackView.transform = CGAffineTransform(translationX: 0, y: translateY)
    }
    
    // MARK: - Navigation Methods Removed (MVVM-C Pattern)
    // All navigation now handled by coordinators through ViewModel closures:
    // - presentSportsSelector() -> viewModel.onSportsSelectionRequested?()  
    // - presentFilters() -> viewModel.onFiltersRequested?()
    // - handleCardTapped() -> viewModel.onMatchSelected?(match)
    //
    // This follows proper MVVM-C separation:
    // - ViewController: Pure UI presentation
    // - ViewModel: Business logic + navigation signals (closures)
    // - Coordinator: Navigation implementation
}

// MARK: - UIPageViewControllerDataSource
extension InPlayEventsViewController: UIPageViewControllerDataSource {

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
extension InPlayEventsViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {


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
        // No special handling needed - content insets handle everything naturally
    }
}

// MARK: - ComplexScroll Implementation
extension InPlayEventsViewController: ScrollSyncDelegate {

    func didScroll(to offset: CGPoint, from controller: MarketGroupCardsViewController) {
        // Update header visibility using ComplexScroll algorithm
        updateHeaderVisibility(for: offset.y)

        // Sync scroll position to all other pages (like POC)
        syncScrollPositions(from: offset, excluding: controller)
    }

    private func syncScrollPositions(from sourceOffset: CGPoint, excluding excludedController: MarketGroupCardsViewController?) {
        guard !isSyncing else { return }

        let offsetY = sourceOffset.y
        guard abs(offsetY - lastSyncedOffset) > 1 else { return }

        isSyncing = true
        lastSyncedOffset = offsetY

        for controller in marketGroupControllers.values {
            if controller !== excludedController {
                controller.setSyncedContentOffset(CGPoint(x: 0, y: offsetY))
            }
        }

        isSyncing = false
    }

    // MARK: - Footer Navigation Delegation (MVVM-C Pattern)

    /// Delegates URL opening to coordinator - ViewController doesn't decide how to open
    private func openURL(_ url: URL) {
        onURLOpenRequested?(url)
    }

    /// Delegates email opening to coordinator - ViewController doesn't decide how to open
    private func openEmailCompose(email: String) {
        onEmailRequested?(email)
    }
}
