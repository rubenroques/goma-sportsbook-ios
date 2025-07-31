//
//  CasinoCategoriesListViewController.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import UIKit
import Combine
import GomaUI

class CasinoCategoriesListViewController: UIViewController {
    
    // MARK: - UI Components
    private let quickLinksTabBarView: QuickLinksTabBarView
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
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
    let viewModel: CasinoCategoriesListViewModel
    private var cancellables = Set<AnyCancellable>()
    private var categorySectionViews: [CasinoCategorySectionView] = []
    
    // MARK: - Lifecycle
    init(viewModel: CasinoCategoriesListViewModel) {
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
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
        setupQuickLinksTabBar()
        setupScrollView()
        setupContentStackView()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupQuickLinksTabBar() {
        quickLinksTabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quickLinksTabBarView)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
    }
    
    private func setupContentStackView() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        scrollView.addSubview(contentStackView)
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicatorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // QuickLinks Tab Bar
            quickLinksTabBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLinksTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickLinksTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content Stack View
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Loading Indicator
            loadingIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingIndicatorView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        // Category sections
        viewModel.$categorySections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categorySections in
                self?.updateCategorySections(categorySections)
            }
            .store(in: &cancellables)
        
        // Error handling
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        viewModel.reloadCategories()
    }
    
    // MARK: - UI Updates
    private func updateCategorySections(_ categorySections: [MockCasinoCategorySectionViewModel]) {
        // Clear existing views
        categorySectionViews.forEach { $0.removeFromSuperview() }
        categorySectionViews.removeAll()
        
        // Remove all arranged subviews
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create new category section views
        for categorySection in categorySections {
            let sectionView = CasinoCategorySectionView(viewModel: categorySection)
            
            // Setup callbacks
            sectionView.onCategoryButtonTapped = { [weak self] categoryId in
                self?.viewModel.categoryButtonTapped(
                    categoryId: categoryId,
                    categoryTitle: categorySection.categoryTitle
                )
            }
            
            sectionView.onGameSelected = { gameId in
                print("Game selected in categories list: \(gameId)")
                // Games can be selected from the preview, but navigation happens via category button
            }
            
            categorySectionViews.append(sectionView)
            contentStackView.addArrangedSubview(sectionView)
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.reloadCategories()
        })
        
        present(alert, animated: true)
    }
}
