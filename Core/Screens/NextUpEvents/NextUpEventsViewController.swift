import UIKit
import GomaUI
import Combine

// MARK: - NextUpEventsViewController
class NextUpEventsViewController: UIViewController {

    // MARK: - UI Components
    private var marketGroupSelectorTabView: MarketGroupSelectorTabView!
    private var pageViewController: UIPageViewController!
    private let quickLinksTabBarView: QuickLinksTabBarView

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

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground

        setupMarketGroupSelectorTabView()
        setupPageViewController()
        setupQuickLinksTabBar()
        setupLoadingIndicator()
        setupConstraints()
    }

    private func setupMarketGroupSelectorTabView() {
        marketGroupSelectorTabView = MarketGroupSelectorTabView(viewModel: viewModel.marketGroupSelectorViewModel)
        marketGroupSelectorTabView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(marketGroupSelectorTabView)
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
    }

    private func setupQuickLinksTabBar() {
        view.addSubview(quickLinksTabBarView)
        quickLinksTabBarView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicatorView)
    }

    private func setupConstraints() {
        
        var topConstraint = marketGroupSelectorTabView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // Quick Links Tab Bar at the very top
            quickLinksTabBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLinksTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickLinksTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            quickLinksTabBarView.heightAnchor.constraint(equalToConstant: 40),

            // Market Group Selector below QuickLinks
            // marketGroupSelectorTabView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor),
            topConstraint,
            marketGroupSelectorTabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            marketGroupSelectorTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            marketGroupSelectorTabView.heightAnchor.constraint(equalToConstant: 42),

            // Page View Controller below the market tabs
            pageViewController.view.topAnchor.constraint(equalTo: marketGroupSelectorTabView.bottomAnchor),
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
        viewModel.$marketGroups
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                self?.updateMarketGroupControllers(marketGroups: marketGroups)
            }
            .store(in: &cancellables)

        // Bind to selection changes from ViewModel
        viewModel.$selectedMarketGroupId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedId in
                guard let selectedId = selectedId else { return }
                self?.handleMarketGroupSelection(marketGroupId: selectedId)
            }
            .store(in: &cancellables)

        // Bind to loading state (optional, for showing loading indicators)
        viewModel.$isLoading
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
    }
}
