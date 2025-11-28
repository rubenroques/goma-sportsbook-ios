//
//  SportsSearchViewController.swift
//  BetssonCameroonApp
//
//  Created by Andre on 27/01/2025.
//

import UIKit
import Combine
import GomaUI

class SportsSearchViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: SportsSearchViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var marketGroupControllers: [String: MarketGroupCardsViewController] = [:]

    // MARK: - MVVM-C Navigation Closures
    var onURLOpenRequested: ((URL) -> Void)?
    var onEmailRequested: ((String) -> Void)?
    
    // MARK: - UI Components
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var searchView: SearchView = Self.createSearchView(with: viewModel.searchViewModel)
    private lazy var searchHeaderInfoView: SearchHeaderInfoView = Self.createSearchHeaderInfoView(with: viewModel.searchHeaderInfoViewModel)
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var recentSearchesScrollView: UIScrollView = Self.createRecentSearchesScrollView()
    private lazy var recentSearchesStackView: UIStackView = Self.createRecentSearchesStackView()
    private lazy var recommendedCollectionView: UICollectionView = Self.createRecommendedCollectionView()
    private var recommendedItems: [TallOddsMatchCardViewModelProtocol] = []
    private var marketGroupSelectorTabView: MarketGroupSelectorTabView!
    private var pageViewController: UIPageViewController!
    
    // Loading overlay
    private let loadingIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
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
    
    // MARK: - Initialization
    init(viewModel: SportsSearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupWithTheme()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "Search Sports"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(searchView)
        containerView.addSubview(searchHeaderInfoView)
        containerView.addSubview(emptyStateView)
        containerView.addSubview(recentSearchesScrollView)
        containerView.addSubview(recommendedCollectionView)
        recentSearchesScrollView.addSubview(recentSearchesStackView)
        setupMarketGroupSelectorTabView()
        setupPageViewController()
        setupLoadingIndicator()

        recommendedCollectionView.dataSource = self
        recommendedCollectionView.delegate = self
        
        // Initial visibility based on config
        emptyStateView.isHidden = false
        recentSearchesScrollView.isHidden = true
        recommendedCollectionView.isHidden = true // Will be shown by updateRecommendedVisibility if there are items
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ContainerView
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            
            // SearchView
            searchView.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // SearchHeaderInfoView below search
            searchHeaderInfoView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            searchHeaderInfoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchHeaderInfoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Recent searches scroll view below search (when no search text)
            recentSearchesScrollView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            recentSearchesScrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            recentSearchesScrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            recentSearchesScrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Recommended collection view below search
            recommendedCollectionView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            recommendedCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            recommendedCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            recommendedCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Recent searches stack view inside scroll view
            recentSearchesStackView.topAnchor.constraint(equalTo: recentSearchesScrollView.topAnchor),
            recentSearchesStackView.leadingAnchor.constraint(equalTo: recentSearchesScrollView.leadingAnchor),
            recentSearchesStackView.trailingAnchor.constraint(equalTo: recentSearchesScrollView.trailingAnchor),
            recentSearchesStackView.bottomAnchor.constraint(equalTo: recentSearchesScrollView.bottomAnchor),
            recentSearchesStackView.widthAnchor.constraint(equalTo: recentSearchesScrollView.widthAnchor),
            
            // MarketGroup selector below search header
            marketGroupSelectorTabView.topAnchor.constraint(equalTo: searchHeaderInfoView.bottomAnchor),
            marketGroupSelectorTabView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            marketGroupSelectorTabView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            marketGroupSelectorTabView.heightAnchor.constraint(equalToConstant: 42),
            
            // Page View Controller fills below selector
            pageViewController.view.topAnchor.constraint(equalTo: marketGroupSelectorTabView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Empty State View (occupies space from search to bottom)
            emptyStateView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Loading Indicator overlay
            loadingIndicatorView.topAnchor.constraint(equalTo: searchHeaderInfoView.bottomAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupWithTheme() {
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
    }
    
    private func setupBindings() {
        // Search text changes
        viewModel.searchTextPublisher
            .sink { [weak self] searchText in
                self?.updateSearchState(searchText: searchText)
            }
            .store(in: &cancellables)
        
        // Search submission (keyboard search button pressed)
        viewModel.onSearchSubmitted
            .sink { [weak self] searchText in
                self?.updateSearchState(searchText: searchText)
                
            }
            .store(in: &cancellables)
        
        // Focus changes from SearchView: show/hide recent searches scroll view
        viewModel.searchFocusPublisher
            .sink { [weak self] isFocused in
                guard let self = self else { return }
                let hasText = !self.viewModel.currentSearchText.isEmpty
                let shouldShowRecent = isFocused && !hasText
                self.recentSearchesScrollView.isHidden = !shouldShowRecent

                if isFocused {
                    // While focused, hide suggested events
                    self.recommendedCollectionView.isHidden = true
                } else {
                    // On blur and no text, show suggested events if we have any
                    if !hasText {
                        self.updateRecommendedVisibility()
                    }
                }
            }
            .store(in: &cancellables)
        
        // Loading state
        viewModel.isLoadingPublisher
            .sink { [weak self] isLoading in
                self?.setLoadingIndicatorVisible(isLoading)
            }
            .store(in: &cancellables)

        // Recommended items (TallOddsMatchCardViewModelProtocol)
        viewModel.recommendedItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.recommendedItems = items
                self.recommendedCollectionView.reloadData()
                self.updateRecommendedVisibility()
            }
            .store(in: &cancellables)

        viewModel.searchResultsPublisher
            .sink { [weak self] results in
                guard let self = self else { return }
                if results == 0 {
                    if let pageViewController,
                       let viewControllers = pageViewController.viewControllers {
                        for viewController in viewControllers {
                            pageViewController.removeChildViewController(viewController)
                        }
                    }
                    self.marketGroupSelectorTabView.isHidden = true
                    
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchHeaderInfoViewModel.statePublisher
            .sink(receiveValue: { [weak self] searchState in
                guard let self = self else { return }

                if searchState == .noResults {
                    searchHeaderInfoView.isHidden = !(viewModel.config.noResults.enabled)
                    searchHeaderInfoView.alpha = !(viewModel.config.noResults.enabled) ? 0 : 1
                }
                else {
                    searchHeaderInfoView.isHidden = false
                    searchHeaderInfoView.alpha = 1
                }
            })
            .store(in: &cancellables)

        
        // Recent searches
        viewModel.recentSearchesPublisher
            .sink { [weak self] recentSearches in
                self?.updateRecentSearches(recentSearches)
            }
            .store(in: &cancellables)
        
        // Market group paging bindings
        bindMarketGroups()
    }

    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicatorView)
    }

    private func setLoadingIndicatorVisible(_ isVisible: Bool) {
        if isVisible {
            loadingIndicatorView.isHidden = false
            loadingIndicatorView.alpha = 0.0
            UIView.animate(withDuration: 0.03) {
                self.loadingIndicatorView.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.loadingIndicatorView.alpha = 0.0
            } completion: { _ in
                self.loadingIndicatorView.isHidden = true
            }
        }
    }
    
    // MARK: - Search State Management
    
    private func updateSearchState(searchText: String) {
        if searchText.isEmpty {
            // Show empty state and suggested events, hide search results
            emptyStateView.isHidden = false
            searchHeaderInfoView.isHidden = true
            recentSearchesScrollView.isHidden = true
            marketGroupSelectorTabView.isHidden = true
            pageViewController.view.isHidden = true
            // Show recommended collection view if we have items
            updateRecommendedVisibility()
        } else {
            // Hide empty state and recent searches, show search header and market groups
            emptyStateView.isHidden = true
            searchHeaderInfoView.isHidden = false
            recentSearchesScrollView.isHidden = true
            marketGroupSelectorTabView.isHidden = !(viewModel.config.searchResults.enabled && viewModel.config.searchResults.showResults)
            pageViewController.view.isHidden = marketGroupSelectorTabView.isHidden
            recommendedCollectionView.isHidden = true
        }
    }
    
    private func updateRecommendedVisibility() {
        let hasRecommendedItems = !recommendedItems.isEmpty
        let shouldShow = viewModel.config.suggestedEvents.enabled && hasRecommendedItems && viewModel.currentSearchText.isEmpty
        recommendedCollectionView.isHidden = !shouldShow
    }
    
    private func updateRecentSearches(_ recentSearches: [String]) {
        // Clear existing recent search views
        recentSearchesStackView.arrangedSubviews.forEach { view in
            recentSearchesStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // Add new recent search views
        for searchText in recentSearches {
            let viewModel = MockRecentSearchViewModel(
                searchText: searchText,
                onTap: { [weak self] in
                    // Handle tap - perform search with this term
                    self?.viewModel.searchFromRecent(searchText)
                },
                onDelete: { [weak self] in
                    // Handle delete - remove from recent searches
                    self?.viewModel.removeRecentSearch(searchText)
                }
            )
            
            let recentSearchView = RecentSearchView(viewModel: viewModel)
            recentSearchView.configure()
            recentSearchesStackView.addArrangedSubview(recentSearchView)
        }
    }
}

// MARK: - Factory Methods
private extension SportsSearchViewController {
    
    static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createSearchView(with searchViewModel: SearchViewModelProtocol) -> SearchView {
        let searchView = SearchView(viewModel: searchViewModel)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        return searchView
    }
    
    static func createSearchHeaderInfoView(with viewModel: SearchHeaderInfoViewModelProtocol) -> SearchHeaderInfoView {
        let searchHeaderInfoView = SearchHeaderInfoView(viewModel: viewModel)
        searchHeaderInfoView.translatesAutoresizingMaskIntoConstraints = false
        return searchHeaderInfoView
    }
    
    static func createEmptyStateView() -> UIView {
        let emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.backgroundColor = StyleProvider.Color.backgroundSecondary
        return emptyStateView
    }
    
    static func createRecentSearchesScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    static func createRecentSearchesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }
    
    private func setupMarketGroupSelectorTabView() {
        marketGroupSelectorTabView = MarketGroupSelectorTabView(viewModel: viewModel.marketGroupSelectorViewModel)
        marketGroupSelectorTabView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(marketGroupSelectorTabView)
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChild(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.didMove(toParent: self)
    }
    
    // Bind market group selector and page transitions
    func bindMarketGroups() {
        viewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                self?.updateMarketGroupControllers(marketGroups: marketGroups)
            }
            .store(in: &cancellables)
        
        viewModel.selectedMarketGroupIdPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedId in
                guard let selectedId = selectedId else { return }
                self?.handleMarketGroupSelection(marketGroupId: selectedId)
            }
            .store(in: &cancellables)
    }
    
    func updateMarketGroupControllers(marketGroups: [MarketGroupTabItemData]) {
        for marketGroup in marketGroups {
            if marketGroupControllers[marketGroup.id] == nil {
                guard let vm = viewModel.getMarketGroupCardsViewModel(for: marketGroup.id) else { continue }

                // Wire up footer ViewModel callbacks (MVVM-C pattern)
                vm.onURLOpenRequested = { [weak self] url in
                    self?.openURL(url)
                }

                vm.onEmailComposeRequested = { [weak self] email in
                    self?.openEmailCompose(email: email)
                }

                let controller = MarketGroupCardsViewController(viewModel: vm)
                controller.scrollDelegate = self
                marketGroupControllers[marketGroup.id] = controller
            }
        }
        let currentIds = Set(marketGroups.map { $0.id })
        let toRemove = marketGroupControllers.keys.filter { !currentIds.contains($0) }
        for id in toRemove { marketGroupControllers.removeValue(forKey: id) }
        
        if pageViewController.viewControllers?.isEmpty == true,
           let first = marketGroups.first,
           let firstController = marketGroupControllers[first.id] {
            pageViewController.setViewControllers([firstController], direction: .forward, animated: false, completion: nil)
        }
    }
    
    func handleMarketGroupSelection(marketGroupId: String) {
        guard let target = marketGroupControllers[marketGroupId] else { return }
        let current = pageViewController.viewControllers?.first as? MarketGroupCardsViewController
        let currentId = current.flatMap { getCurrentMarketTypeId(for: $0) }
        if currentId == marketGroupId { return }
        let direction = determineAnimationDirection(from: currentId, to: marketGroupId)
        pageViewController.setViewControllers([target], direction: direction, animated: true, completion: nil)
    }
    
    func determineAnimationDirection(from currentMarketTypeId: String?, to targetMarketTypeId: String) -> UIPageViewController.NavigationDirection {
        guard let currentId = currentMarketTypeId else { return .forward }
        guard currentId != targetMarketTypeId else { return .forward }
        let groups = viewModel.getCurrentMarketGroups()
        guard let currentIndex = groups.firstIndex(where: { $0.id == currentId }),
              let targetIndex = groups.firstIndex(where: { $0.id == targetMarketTypeId }) else { return .forward }
        return targetIndex > currentIndex ? .forward : .reverse
    }
    
    func getCurrentMarketTypeId(for controller: MarketGroupCardsViewController) -> String? {
        return marketGroupControllers.first { $0.value === controller }?.key
    }
    
    func getMarketGroupIndex(for marketTypeId: String) -> Int? {
        return viewModel.getCurrentMarketGroups().firstIndex { $0.id == marketTypeId }
    }

    static func createRecommendedCollectionView() -> UICollectionView {
        // Match MarketGroupCards layout: full-width list with estimated item height and insets
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(180)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(180)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 1.5
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            // Header supplementary item
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(36)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = false
            section.boundarySupplementaryItems = [header]
            return section
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = StyleProvider.Color.backgroundTertiary
        collectionView.register(TallOddsMatchCardCollectionViewCell.self, forCellWithReuseIdentifier: TallOddsMatchCardCollectionViewCell.identifier)
        collectionView.register(HeaderTextReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderTextReusableView.identifier)
        return collectionView
    }
}

// MARK: - Page VC Protocols
extension SportsSearchViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? MarketGroupCardsViewController,
              let currentId = getCurrentMarketTypeId(for: current),
              let currentIndex = getMarketGroupIndex(for: currentId),
              currentIndex > 0 else { return nil }
        let groups = viewModel.getCurrentMarketGroups()
        let prevId = groups[currentIndex - 1].id
        return marketGroupControllers[prevId]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? MarketGroupCardsViewController,
              let currentId = getCurrentMarketTypeId(for: current),
              let currentIndex = getMarketGroupIndex(for: currentId) else { return nil }
        let groups = viewModel.getCurrentMarketGroups()
        guard currentIndex < groups.count - 1 else { return nil }
        let nextId = groups[currentIndex + 1].id
        return marketGroupControllers[nextId]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let current = pageViewController.viewControllers?.first as? MarketGroupCardsViewController,
              let currentId = getCurrentMarketTypeId(for: current) else { return }
        if viewModel.getCurrentSelectedMarketGroupId() != currentId {
            viewModel.selectMarketGroup(id: currentId)
        }
    }
}

// MARK: - Recommended Collection Data Source & Delegate
extension SportsSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TallOddsMatchCardCollectionViewCell.identifier, for: indexPath) as? TallOddsMatchCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        let viewModel = recommendedItems[indexPath.item]
        let isFirst = indexPath.item == 0
        let isLast = indexPath.item == recommendedItems.count - 1
        cell.configure(with: viewModel, backgroundColor: StyleProvider.Color.backgroundSecondary)
        cell.configureCellPosition(isFirst: isFirst, isLast: isLast)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderTextReusableView.identifier, for: indexPath) as! HeaderTextReusableView
            header.configure(title: localized("suggested_bets"))
            return header
        }
        return UICollectionReusableView()
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

extension SportsSearchViewController: MarketGroupCardsScrollDelegate {
    func marketGroupCardsDidScroll(_ scrollView: UIScrollView, scrollDirection: ScrollDirection, in viewController: MarketGroupCardsViewController) {
        // No header animation on search
    }
    
    func marketGroupCardsDidEndScrolling(_ scrollView: UIScrollView, in viewController: MarketGroupCardsViewController) { }
}
