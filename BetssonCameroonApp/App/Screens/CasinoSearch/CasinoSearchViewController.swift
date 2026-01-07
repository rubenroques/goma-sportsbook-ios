//
//  CasinoSearchViewController.swift
//  BetssonCameroonApp
//
//  Created on 22/09/2025.
//

import UIKit
import Combine
import GomaUI

final class CasinoSearchViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CasinoSearchViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentSearchText: String = ""
    
    // MARK: - UI Components
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var searchView: SearchView = Self.createSearchView(with: viewModel.searchViewModel)
    private lazy var searchHeaderInfoView: SearchHeaderInfoView = Self.createSearchHeaderInfoView(with: viewModel.searchHeaderInfoViewModel)
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var suggestedErrorView: UIView = Self.createSuggestedErrorView()
    private lazy var suggestedErrorLabel: UILabel = Self.createSuggestedErrorLabel()
    private lazy var resultsScrollView: UIScrollView = Self.createResultsScrollView()
    private lazy var resultsScrollContainerView: UIView = Self.createResultsScrollContainerView()
    private lazy var resultsContentStackView: UIStackView = Self.createResultsStackView()
    private lazy var resultsContainerView: UIView = Self.createResultsContainerView()
    private lazy var resultsStackView: UIStackView = Self.createResultsStackView()
    private lazy var mostPlayedHeaderLabel: UILabel = Self.createMostPlayedHeaderLabel()
    private lazy var mostPlayedContainerView: UIView = Self.createResultsContainerView()
    private lazy var mostPlayedStackView: UIStackView = Self.createResultsStackView()
    private lazy var suggestedScrollView: UIScrollView = Self.createSuggestedScrollView()
    private lazy var suggestedScrollContainerView: UIView = Self.createSuggestedScrollContainerView()
    private lazy var suggestedHeaderView: HeaderTextView = Self.createSuggestedHeaderView()
    private lazy var suggestedStackView: UIStackView = Self.createSuggestedStackView()
    
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
    init(viewModel: CasinoSearchViewModelProtocol) {
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
        title = localized("casino_search_title")
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(searchView)
        containerView.addSubview(searchHeaderInfoView)
        containerView.addSubview(emptyStateView)
        containerView.addSubview(resultsScrollView)
        containerView.addSubview(suggestedScrollView)
        resultsScrollView.addSubview(resultsScrollContainerView)
        suggestedScrollView.addSubview(suggestedScrollContainerView)
        emptyStateView.addSubview(suggestedErrorView)
        suggestedErrorView.addSubview(suggestedErrorLabel)
        resultsScrollContainerView.addSubview(resultsContentStackView)
        suggestedScrollContainerView.addSubview(suggestedHeaderView)
        suggestedScrollContainerView.addSubview(suggestedStackView)
        resultsContentStackView.addArrangedSubview(resultsContainerView)
        resultsContentStackView.addArrangedSubview(mostPlayedHeaderLabel)
        resultsContentStackView.addArrangedSubview(mostPlayedContainerView)
        resultsContainerView.addSubview(resultsStackView)
        mostPlayedContainerView.addSubview(mostPlayedStackView)
        containerView.addSubview(loadingIndicatorView)
        
        // Initial visibility based on config
        emptyStateView.isHidden = false
        resultsScrollView.isHidden = !(viewModel.config.searchResults.enabled && viewModel.config.searchResults.showResults)
        suggestedScrollView.isHidden = true // Will be shown by updateSuggested if there are games
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // SearchView
            searchView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            searchView.topAnchor.constraint(equalTo: containerView.topAnchor),
            
            // Header info below search
            searchHeaderInfoView.leadingAnchor.constraint(equalTo: searchView.leadingAnchor),
            searchHeaderInfoView.trailingAnchor.constraint(equalTo: searchView.trailingAnchor),
            searchHeaderInfoView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            
            // Results scroll view fills remainder
            resultsScrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            resultsScrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            resultsScrollView.topAnchor.constraint(equalTo: searchHeaderInfoView.bottomAnchor),
            resultsScrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Suggested scroll view fills remainder (same as results)
            suggestedScrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            suggestedScrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            suggestedScrollView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            suggestedScrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Scroll container sizing
            resultsScrollContainerView.leadingAnchor.constraint(equalTo: resultsScrollView.leadingAnchor),
            resultsScrollContainerView.trailingAnchor.constraint(equalTo: resultsScrollView.trailingAnchor),
            resultsScrollContainerView.topAnchor.constraint(equalTo: resultsScrollView.topAnchor),
            resultsScrollContainerView.bottomAnchor.constraint(equalTo: resultsScrollView.bottomAnchor),
            resultsScrollContainerView.widthAnchor.constraint(equalTo: resultsScrollView.widthAnchor),

            // Suggested scroll container sizing
            suggestedScrollContainerView.leadingAnchor.constraint(equalTo: suggestedScrollView.leadingAnchor),
            suggestedScrollContainerView.trailingAnchor.constraint(equalTo: suggestedScrollView.trailingAnchor),
            suggestedScrollContainerView.topAnchor.constraint(equalTo: suggestedScrollView.topAnchor),
            suggestedScrollContainerView.bottomAnchor.constraint(equalTo: suggestedScrollView.bottomAnchor),
            suggestedScrollContainerView.widthAnchor.constraint(equalTo: suggestedScrollView.widthAnchor),

            // Content stack inside scroll container
            resultsContentStackView.leadingAnchor.constraint(equalTo: resultsScrollContainerView.leadingAnchor, constant: 8),
            resultsContentStackView.trailingAnchor.constraint(equalTo: resultsScrollContainerView.trailingAnchor, constant: -8),
            resultsContentStackView.topAnchor.constraint(equalTo: resultsScrollContainerView.topAnchor, constant: 8),
            resultsContentStackView.bottomAnchor.constraint(equalTo: resultsScrollContainerView.bottomAnchor, constant: -8),

            // Suggested header view
            suggestedHeaderView.leadingAnchor.constraint(equalTo: suggestedScrollContainerView.leadingAnchor, constant: 8),
            suggestedHeaderView.trailingAnchor.constraint(equalTo: suggestedScrollContainerView.trailingAnchor, constant: -8),
            suggestedHeaderView.topAnchor.constraint(equalTo: suggestedScrollContainerView.topAnchor, constant: 8),

            // Suggested stack view below header
            suggestedStackView.leadingAnchor.constraint(equalTo: suggestedScrollContainerView.leadingAnchor, constant: 8),
            suggestedStackView.trailingAnchor.constraint(equalTo: suggestedScrollContainerView.trailingAnchor, constant: -8),
            suggestedStackView.topAnchor.constraint(equalTo: suggestedHeaderView.bottomAnchor, constant: 16),
            suggestedStackView.bottomAnchor.constraint(equalTo: suggestedScrollContainerView.bottomAnchor, constant: -8),

            // Results container view should fill width of content stack
            resultsContainerView.leadingAnchor.constraint(equalTo: resultsContentStackView.leadingAnchor),
            resultsContainerView.trailingAnchor.constraint(equalTo: resultsContentStackView.trailingAnchor),
            
            
            // Stack view inside scroll container
            resultsStackView.leadingAnchor.constraint(equalTo: resultsContainerView.leadingAnchor, constant: 8),
            resultsStackView.trailingAnchor.constraint(equalTo: resultsContainerView.trailingAnchor, constant: -8),
            resultsStackView.topAnchor.constraint(equalTo: resultsContainerView.topAnchor, constant: 8),
            resultsStackView.bottomAnchor.constraint(equalTo: resultsContainerView.bottomAnchor, constant: -8),

            // Most played header below results container, aligned to content stack
            mostPlayedHeaderLabel.leadingAnchor.constraint(equalTo: resultsContentStackView.leadingAnchor, constant: 8),
            mostPlayedHeaderLabel.trailingAnchor.constraint(equalTo: resultsContentStackView.trailingAnchor, constant: -8),

            // Most played container view should fill width of content stack
            mostPlayedContainerView.leadingAnchor.constraint(equalTo: resultsContentStackView.leadingAnchor),
            mostPlayedContainerView.trailingAnchor.constraint(equalTo: resultsContentStackView.trailingAnchor),

            // Most played stack inside its container
            mostPlayedStackView.leadingAnchor.constraint(equalTo: mostPlayedContainerView.leadingAnchor, constant: 8),
            mostPlayedStackView.trailingAnchor.constraint(equalTo: mostPlayedContainerView.trailingAnchor, constant: -8),
            mostPlayedStackView.topAnchor.constraint(equalTo: mostPlayedContainerView.topAnchor, constant: 8),
            mostPlayedStackView.bottomAnchor.constraint(equalTo: mostPlayedContainerView.bottomAnchor, constant: -8),

            // Empty state fills remainder under header when shown
            emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emptyStateView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Suggested error view inside empty state
            suggestedErrorView.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            suggestedErrorView.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            suggestedErrorView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),

            suggestedErrorLabel.leadingAnchor.constraint(equalTo: suggestedErrorView.leadingAnchor, constant: 12),
            suggestedErrorLabel.trailingAnchor.constraint(equalTo: suggestedErrorView.trailingAnchor, constant: -12),
            suggestedErrorLabel.topAnchor.constraint(equalTo: suggestedErrorView.topAnchor, constant: 12),
            suggestedErrorLabel.bottomAnchor.constraint(equalTo: suggestedErrorView.bottomAnchor, constant: -12),
            
            // Loading overlay covers container
            loadingIndicatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            loadingIndicatorView.topAnchor.constraint(equalTo: searchHeaderInfoView.bottomAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupWithTheme() {
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        containerView.backgroundColor = .clear
        emptyStateView.backgroundColor = StyleProvider.Color.backgroundSecondary
        suggestedErrorView.backgroundColor = StyleProvider.Color.backgroundPrimary
        suggestedErrorLabel.textColor = StyleProvider.Color.textPrimary
        resultsScrollContainerView.backgroundColor = .clear
        resultsContainerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        mostPlayedContainerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        resultsStackView.backgroundColor = .clear
        mostPlayedStackView.backgroundColor = .clear
        mostPlayedHeaderLabel.textColor = StyleProvider.Color.textPrimary
        suggestedScrollView.backgroundColor = StyleProvider.Color.backgroundTertiary
        suggestedScrollContainerView.backgroundColor = .clear
    }
    
    private func setupBindings() {
        viewModel.searchTextPublisher
            .sink { [weak self] searchText in
                self?.currentSearchText = searchText
                self?.updateSearchState(searchText: searchText)
            }
            .store(in: &cancellables)
        
        viewModel.searchedGameViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModels in
                self?.updateResults(with: viewModels)
            }
            .store(in: &cancellables)

        viewModel.mostPlayedGameViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModels in
                self?.updateMostPlayed(with: viewModels)
            }
            .store(in: &cancellables)

        viewModel.recommendedGameViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModels in
                self?.updateSuggested(with: viewModels)
            }
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingIndicatorView.isHidden = !isLoading
            }
            .store(in: &cancellables)

        viewModel.recommendedGamesErrorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                let hasError = (message != nil)
                self?.suggestedErrorLabel.text = hasError ? "\(localized("casino_api_error_prefix")) \(message!)" : ""
                self?.suggestedErrorView.isHidden = !hasError
            }
            .store(in: &cancellables)
    }

    private func updateResults(with viewModels: [CasinoGameSearchedViewModelProtocol]) {
        let hasResults = !viewModels.isEmpty
        // Show header + mostPlayed only when search text is non-empty and we are showing results area
        let shouldShowSections = (viewModel.config.sections.searchResults.enabled && !currentSearchText.isEmpty) && (hasResults || !mostPlayedStackView.arrangedSubviews.isEmpty)
        mostPlayedHeaderLabel.isHidden = !(viewModel.config.sections.mostPlayed.enabled) || !shouldShowSections || mostPlayedStackView.arrangedSubviews.isEmpty
        mostPlayedContainerView.isHidden = !(viewModel.config.sections.mostPlayed.enabled) || !shouldShowSections || mostPlayedStackView.arrangedSubviews.isEmpty
        resultsContainerView.isHidden = !(viewModel.config.sections.searchResults.enabled) || !hasResults
        resultsScrollView.isHidden = !(viewModel.config.searchResults.enabled && viewModel.config.searchResults.showResults) || (!shouldShowSections && !hasResults)
        
        if !hasResults {
            searchHeaderInfoView.isHidden = !(viewModel.config.noResults.enabled)
        }
        
        // Clear
        resultsStackView.arrangedSubviews.forEach { sub in
            resultsStackView.removeArrangedSubview(sub)
            sub.removeFromSuperview()
        }

        // Add items
        for viewModel in viewModels {
            let itemView = CasinoGameSearchedView(viewModel: viewModel)
            resultsStackView.addArrangedSubview(itemView)
        }
    }

    private func updateMostPlayed(with viewModels: [CasinoGameSearchedViewModelProtocol]) {
        // Clear
        mostPlayedStackView.arrangedSubviews.forEach { sub in
            mostPlayedStackView.removeArrangedSubview(sub)
            sub.removeFromSuperview()
        }
        
        let hasMostPlayed = !viewModels.isEmpty
        let shouldShow = viewModel.config.sections.mostPlayed.enabled && !currentSearchText.isEmpty && hasMostPlayed
        mostPlayedHeaderLabel.isHidden = !shouldShow
        mostPlayedContainerView.isHidden = !shouldShow
        
        guard hasMostPlayed else { return }
        
        for vm in viewModels {
            let itemView = CasinoGameSearchedView(viewModel: vm)
            mostPlayedStackView.addArrangedSubview(itemView)
        }
    }
    
    private func updateSuggested(with viewModels: [CasinoGameSearchedViewModelProtocol]) {
        // Clear
        suggestedStackView.arrangedSubviews.forEach { sub in
            suggestedStackView.removeArrangedSubview(sub)
            sub.removeFromSuperview()
        }
        
        // Hide suggested scroll view if no games
        let hasSuggestedGames = !viewModels.isEmpty
        suggestedScrollView.isHidden = !hasSuggestedGames
        
        guard hasSuggestedGames else { return }
        
        // Add items
        for viewModel in viewModels {
            let itemView = CasinoGameSearchedView(viewModel: viewModel)
            suggestedStackView.addArrangedSubview(itemView)
        }
    }

    private func updateSearchState(searchText: String) {
        
        if searchText.isEmpty {
            emptyStateView.isHidden = false
            searchHeaderInfoView.isHidden = true
            resultsScrollView.isHidden = true
            let currentSuggestedGames = !suggestedStackView.arrangedSubviews.isEmpty
            suggestedScrollView.isHidden = !currentSuggestedGames
            
        } else {
            emptyStateView.isHidden = true
            searchHeaderInfoView.isHidden = false
            suggestedScrollView.isHidden = true
            resultsScrollView.isHidden = !(viewModel.config.searchResults.enabled && viewModel.config.searchResults.showResults)
        }
        
    }
}

// MARK: - Factory Methods
private extension CasinoSearchViewController {
    static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createSearchView(with viewModel: SearchViewModelProtocol) -> SearchView {
        let searchView = SearchView(viewModel: viewModel)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        return searchView
    }
    
    static func createSearchHeaderInfoView(with viewModel: SearchHeaderInfoViewModelProtocol) -> SearchHeaderInfoView {
        let header = SearchHeaderInfoView(viewModel: viewModel)
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }
    
    static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createSuggestedErrorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    static func createSuggestedErrorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 12)
        label.text = "\(localized("casino_api_error_prefix")) \(localized("casino_suggested_games_error"))"
        label.numberOfLines = 0
        return label
    }

    static func createResultsScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    static func createResultsScrollContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createResultsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }
    
    static func createResultsStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }

    static func createMostPlayedHeaderLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("casino_you_might_be_interested")
        label.font = AppFont.with(type: .semibold, size: 14)
        label.isHidden = true
        return label
    }

    static func createSuggestedScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    static func createSuggestedScrollContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createSuggestedHeaderView() -> HeaderTextView {
        let headerViewModel = MockHeaderTextViewModel(title: localized("casino_suggested_games_title"))
        let headerView = HeaderTextView(viewModel: headerViewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.configure()
        return headerView
    }
    
    static func createSuggestedStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }
}


