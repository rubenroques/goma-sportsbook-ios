//
//  CasinoSearchViewController.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 22/09/2025.
//

import UIKit
import Combine
import GomaUI

final class CasinoSearchViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CasinoSearchViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var searchView: SearchView = Self.createSearchView(with: viewModel.searchViewModel)
    private lazy var searchHeaderInfoView: SearchHeaderInfoView = Self.createSearchHeaderInfoView(with: viewModel.searchHeaderInfoViewModel)
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var resultsScrollView: UIScrollView = Self.createResultsScrollView()
    private lazy var resultsScrollContainerView: UIView = Self.createResultsScrollContainerView()
    private lazy var resultsContainerView: UIView = Self.createResultsContainerView()
    private lazy var resultsStackView: UIStackView = Self.createResultsStackView()
    
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
        title = "Search Casino"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(searchView)
        containerView.addSubview(searchHeaderInfoView)
        containerView.addSubview(emptyStateView)
        containerView.addSubview(resultsScrollView)
        resultsScrollView.addSubview(resultsScrollContainerView)
        resultsScrollContainerView.addSubview(resultsContainerView)
        resultsContainerView.addSubview(resultsStackView)
        containerView.addSubview(loadingIndicatorView)
        
        // Initial visibility
        searchHeaderInfoView.isHidden = true
        emptyStateView.isHidden = false
        resultsScrollView.isHidden = true
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

            // Scroll container sizing
            resultsScrollContainerView.leadingAnchor.constraint(equalTo: resultsScrollView.leadingAnchor),
            resultsScrollContainerView.trailingAnchor.constraint(equalTo: resultsScrollView.trailingAnchor),
            resultsScrollContainerView.topAnchor.constraint(equalTo: resultsScrollView.topAnchor),
            resultsScrollContainerView.bottomAnchor.constraint(equalTo: resultsScrollView.bottomAnchor),
            resultsScrollContainerView.widthAnchor.constraint(equalTo: resultsScrollView.widthAnchor),

            // Results container view
            resultsContainerView.leadingAnchor.constraint(equalTo: resultsScrollContainerView.leadingAnchor, constant: 8),
            resultsContainerView.trailingAnchor.constraint(equalTo: resultsScrollContainerView.trailingAnchor, constant: -8),
            resultsContainerView.topAnchor.constraint(equalTo: resultsScrollContainerView.topAnchor, constant: 8),
            resultsContainerView.bottomAnchor.constraint(equalTo: resultsScrollContainerView.bottomAnchor),
            
            // Stack view inside scroll container
            resultsStackView.leadingAnchor.constraint(equalTo: resultsContainerView.leadingAnchor, constant: 8),
            resultsStackView.trailingAnchor.constraint(equalTo: resultsContainerView.trailingAnchor, constant: -8),
            resultsStackView.topAnchor.constraint(equalTo: resultsContainerView.topAnchor, constant: 8),
            resultsStackView.bottomAnchor.constraint(equalTo: resultsContainerView.bottomAnchor, constant: -8),

            // Empty state fills remainder under header when shown
            emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emptyStateView.topAnchor.constraint(equalTo: searchHeaderInfoView.bottomAnchor, constant: 12),
            emptyStateView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
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
        resultsScrollContainerView.backgroundColor = .clear
        resultsContainerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        resultsStackView.backgroundColor = .clear
    }
    
    private func setupBindings() {
        viewModel.searchTextPublisher
            .sink { [weak self] searchText in
                print("🔍 CasinoSearchViewController: Search text changed to: '\(searchText)'")
                self?.updateSearchState(searchText: searchText)
            }
            .store(in: &cancellables)
        
        viewModel.searchedGameViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModels in
                self?.updateResults(with: viewModels)
            }
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingIndicatorView.isHidden = !isLoading
            }
            .store(in: &cancellables)
    }

    private func updateResults(with viewModels: [CasinoGameSearchedViewModelProtocol]) {
        let hasResults = !viewModels.isEmpty
        resultsScrollView.isHidden = !hasResults
        emptyStateView.isHidden = hasResults

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
    
    private func updateSearchState(searchText: String) {
        if searchText.isEmpty {
            // Show empty state and recent searches, hide search header and market groups
            emptyStateView.isHidden = false
            searchHeaderInfoView.isHidden = true
        } else {
            // Hide empty state and recent searches, show search header and market groups
            emptyStateView.isHidden = true
            searchHeaderInfoView.isHidden = false
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
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
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
}


