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
    
    // MARK: - UI Components
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var searchView: SearchView = Self.createSearchView(with: viewModel.searchViewModel)
    
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
            searchView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
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
                // TODO: Implement search functionality
            }
            .store(in: &cancellables)
        
        // Search submission
        viewModel.onSearchSubmitted
            .sink { [weak self] searchText in
                print("🔍 SportsSearchViewController: Search submitted: '\(searchText)'")
                // TODO: Implement search submission
            }
            .store(in: &cancellables)
        
        // Loading state
        viewModel.isLoadingPublisher
            .sink { [weak self] isLoading in
                print("🔍 SportsSearchViewController: Loading state: \(isLoading)")
                // TODO: Show/hide loading indicator
            }
            .store(in: &cancellables)
        
        // Search results
        viewModel.searchResultsPublisher
            .sink { [weak self] results in
                print("🔍 SportsSearchViewController: Search results count: \(results.count)")
                // TODO: Display search results
            }
            .store(in: &cancellables)
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
    
}
