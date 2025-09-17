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
    
    // MARK: - UI Components
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var searchView: SearchView = Self.createSearchView(with: viewModel.searchViewModel)
    private lazy var searchHeaderInfoView: SearchHeaderInfoView = Self.createSearchHeaderInfoView(with: viewModel.searchHeaderInfoViewModel)
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private var marketGroupSelectorTabView: MarketGroupSelectorTabView!
    private var pageViewController: UIPageViewController!
    
    // Loading overlay
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
        setupMarketGroupSelectorTabView()
        setupPageViewController()
        setupLoadingIndicator()
        
        // Initially hide search header and show empty state
        searchHeaderInfoView.isHidden = true
        emptyStateView.isHidden = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ContainerView
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // SearchView
            searchView.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // SearchHeaderInfoView below search
            searchHeaderInfoView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            searchHeaderInfoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchHeaderInfoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
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
            loadingIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
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
                print("🔍 SportsSearchViewController: Search text changed to: '\(searchText)'")
                self?.updateSearchState(searchText: searchText)
            }
            .store(in: &cancellables)
        
        // Search submission
        viewModel.onSearchSubmitted
            .sink { [weak self] searchText in
                print("🔍 SportsSearchViewController: Search submitted: '\(searchText)'")
                self?.updateSearchState(searchText: searchText)
            }
            .store(in: &cancellables)
        
        // Loading state
        viewModel.isLoadingPublisher
            .sink { [weak self] isLoading in
                self?.setLoadingIndicatorVisible(isLoading)
            }
            .store(in: &cancellables)
        
        // Search results
        viewModel.searchResultsPublisher
            .sink { [weak self] results in
                print("🔍 SportsSearchViewController: Search results count: \(results)")
                self?.updateSearchResultsState(results: results)
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
            // Show empty state, hide search header and market groups
            emptyStateView.isHidden = false
            searchHeaderInfoView.isHidden = true
            marketGroupSelectorTabView.isHidden = true
            pageViewController.view.isHidden = true
        } else {
            // Hide empty state, show search header and market groups
            emptyStateView.isHidden = true
            searchHeaderInfoView.isHidden = false
            marketGroupSelectorTabView.isHidden = false
            pageViewController.view.isHidden = false
        }
    }
    
    private func updateSearchResultsState(results: Int) {
        guard !searchHeaderInfoView.isHidden else { return }
        
        // Get current search text from the view model
        let searchText = viewModel.currentSearchText
        
        // Determine state based on loading status and results
        let state: SearchState
        if viewModel.isLoading {
            state = .loading
        } else if results == 0 {
            state = .noResults
        } else {
            state = .results
        }
        
        let count = results > 0 ? results : nil
        
        // Update the view model with new data
        viewModel.searchHeaderInfoViewModel.updateSearch(
            term: searchText,
            category: "Sports",
            state: state,
            count: count
        )
        
        // Configure the view with the updated view model
        searchHeaderInfoView.refreshConfiguration()
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
        
        // Create empty state content
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "magnifyingglass")
        iconImageView.tintColor = StyleProvider.Color.textSecondary
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Search Sports"
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 20)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Find matches, teams, leagues and more"
        subtitleLabel.font = StyleProvider.fontWith(type: .regular, size: 16)
        subtitleLabel.textColor = StyleProvider.Color.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        emptyStateView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -32),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 64),
            iconImageView.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        return emptyStateView
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

extension SportsSearchViewController: MarketGroupCardsScrollDelegate {
    func marketGroupCardsDidScroll(_ scrollView: UIScrollView, scrollDirection: ScrollDirection, in viewController: MarketGroupCardsViewController) {
        // No header animation on search
    }
    
    func marketGroupCardsDidEndScrolling(_ scrollView: UIScrollView, in viewController: MarketGroupCardsViewController) { }
}
