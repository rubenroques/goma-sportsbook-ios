import UIKit
import GomaUI
import Combine
import ServicesProvider

// MARK: - NextUpEventsViewModel
class NextUpEventsViewModel {

    var sportType: SportType
    var eventsState: AnyPublisher<LoadableContent<[Match]>, Never> {
        return self.eventsStateSubject.eraseToAnyPublisher()
    }

    var quickLinksTabBarViewModel: QuickLinksTabBarViewModelProtocol

    private var eventsStateSubject = CurrentValueSubject<LoadableContent<[Match]>, Never>.init(.loading)
    private var cancellables: Set<AnyCancellable> = []

    private var preLiveMatchesCancellable: AnyCancellable?

    init(sportType: SportType = SportType.defaultFootball) {
        self.sportType = sportType
        self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.sportsMockViewModel
    }

    func reloadEvents(forced: Bool = false) {
        self.loadEvents()
    }

    private func loadEvents() {
        self.eventsStateSubject.send(.loading)

        self.preLiveMatchesCancellable?.cancel()

        self.preLiveMatchesCancellable = Env.servicesProvider.subscribePreLiveMatches(
            forSportType: self.sportType,
            sortType: EventListSort.popular)
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("subscribePreLiveMatches \(completion)")
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                print("Connected to pre-live matches subscription \(subscription.id)")
                break

            case .contentUpdate(let content):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: content)
                self?.process(matches: matches)

            case .disconnected:
                print("Disconnected from pre-live matches subscription")
                break
            }
        }
    }

    private func process(matches: [Match]) {
        self.eventsStateSubject.send(LoadableContent.loaded(matches))
    }
}

// MARK: - NextUpEventsViewController
class NextUpEventsViewController: UIViewController {

    // MARK: - Private Properties
    private let marketGroupSelectorViewModel = NextUpEventsMarketGroupSelectorViewModel()
    
    private var marketGroupSelectorTabView: MarketGroupSelectorTabView!
    
    private var pageViewController: UIPageViewController!
    private var marketGroupControllers: [String: MarketGroupCardsViewController] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private var allMatches: [Match] = [] {
        didSet {
            updateContent()
        }
    }
    
    private let quickLinksTabBarView: QuickLinksTabBarView!
    private let viewModel: NextUpEventsViewModel

    // MARK: Lifetime and cycle
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
        viewModel.reloadEvents()
    }

    // MARK: Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        setupMarketGroupSelectorTabView()
        setupPageViewController()
        setupQuickLinksTabBar()
        setupConstraints()
    }
    
    private func setupMarketGroupSelectorTabView() {
        marketGroupSelectorTabView = MarketGroupSelectorTabView(viewModel: marketGroupSelectorViewModel)
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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Quick Links Tab Bar at the very top
            quickLinksTabBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLinksTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickLinksTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            quickLinksTabBarView.heightAnchor.constraint(equalToConstant: 40),
            
            // Market Group Selector below QuickLinks
            marketGroupSelectorTabView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor),
            marketGroupSelectorTabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            marketGroupSelectorTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            marketGroupSelectorTabView.heightAnchor.constraint(equalToConstant: 42),
            
            // Page View Controller below the market tabs
            pageViewController.view.topAnchor.constraint(equalTo: marketGroupSelectorTabView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBindings() {
        // Original data loading from view model
        viewModel.eventsState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchesResult in
                switch matchesResult {
                case .idle, .loading:
                    break
                case .loaded(let matches):
                    self?.allMatches = matches
                    print("Loaded \(matches.count) matches")
                case .failed:
                    print("Failed to load matches")
                }
            }
            .store(in: &cancellables)
        
        // Listen to market group selection changes
        marketGroupSelectorViewModel.selectionEventPublisher
            .sink { [weak self] selectionEvent in
                self?.handleMarketGroupSelection(marketGroupId: selectionEvent.selectedId)
            }
            .store(in: &cancellables)
        
        // Listen to market groups updates
        marketGroupSelectorViewModel.marketGroupsPublisher
            .sink { [weak self] marketGroups in
                self?.updateMarketGroupControllers(marketGroups: marketGroups)
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading
    private func loadData() {
        // Trigger data loading from view model
        viewModel.reloadEvents()
    }
    
    // MARK: - Content Updates
    private func updateContent() {
        // Update the market group selector with new matches
        marketGroupSelectorViewModel.updateWithMatches(allMatches)
        print("Updated content with \(allMatches.count) matches")
        
        // Log market types found
        let marketTypes = Set(allMatches.flatMap { $0.markets.compactMap { $0.marketTypeId } })
        print("Found market types: \(marketTypes)")
    }
    
    private func updateMarketGroupControllers(marketGroups: [MarketGroupTabItemData]) {
        print("Updating market group controllers for \(marketGroups.count) groups")
        
        // Create controllers for each market group
        for marketGroup in marketGroups {
            if marketGroupControllers[marketGroup.id] == nil {
                let controller = MarketGroupCardsViewController(marketTypeId: marketGroup.id)
                controller.updateMatches(allMatches)
                marketGroupControllers[marketGroup.id] = controller
                print("Created new controller for market type: \(marketGroup.id)")
            } else {
                // Update existing controller with latest matches
                marketGroupControllers[marketGroup.id]?.updateMatches(allMatches)
                print("Updated existing controller for market type: \(marketGroup.id)")
            }
        }
        
        // Remove controllers for market groups that no longer exist
        let currentMarketGroupIds = Set(marketGroups.map { $0.id })
        let controllersToRemove = marketGroupControllers.keys.filter { !currentMarketGroupIds.contains($0) }
        for idToRemove in controllersToRemove {
            marketGroupControllers.removeValue(forKey: idToRemove)
            print("Removed controller for market type: \(idToRemove)")
        }
        
        // If we have controllers but no current page, set the first one
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
            print("No controller found for market type: \(marketGroupId)")
            return
        }
        
        let direction: UIPageViewController.NavigationDirection = .forward
        
        pageViewController.setViewControllers(
            [targetController],
            direction: direction,
            animated: false, // No animation for now as requested
            completion: { [weak self] completed in
                if completed {
                    print("Successfully switched to market type: \(marketGroupId)")
                } else {
                    print("Failed to switch to market type: \(marketGroupId)")
                }
            }
        )
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
        
        let marketGroups = marketGroupSelectorViewModel.currentMarketGroups
        let previousMarketTypeId = marketGroups[currentIndex - 1].id
        return marketGroupControllers[previousMarketTypeId]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? MarketGroupCardsViewController,
              let currentMarketTypeId = getCurrentMarketTypeId(for: currentController),
              let currentIndex = getMarketGroupIndex(for: currentMarketTypeId) else {
            return nil
        }
        
        let marketGroups = marketGroupSelectorViewModel.currentMarketGroups
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
        return marketGroupSelectorViewModel.currentMarketGroups.firstIndex { $0.id == marketTypeId }
    }
}

// MARK: - UIPageViewControllerDelegate
extension NextUpEventsViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed,
              let currentController = pageViewController.viewControllers?.first as? MarketGroupCardsViewController,
              let currentMarketTypeId = getCurrentMarketTypeId(for: currentController) else {
            return
        }
        
        // Update the tab selection to match the current page
        marketGroupSelectorViewModel.selectMarketGroup(id: currentMarketTypeId)
    }
}

