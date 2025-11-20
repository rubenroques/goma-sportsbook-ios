//
//  CasinoCategoriesListViewController.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import UIKit
import Combine
import GomaUI
import GomaPerformanceKit

class CasinoCategoriesListViewController: UIViewController {
    
    // MARK: - UI Components
    private let quickLinksTabBarView: QuickLinksTabBarView
    private let collectionView: UICollectionView
    
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
    private var categorySections: [MockCasinoCategorySectionViewModel] = []
    
    // MARK: - Constants
    private enum Constants {
        static let topBannerHeight: CGFloat = 136.0
        static let recentlyPlayedHeight: CGFloat = 132.0
        static let categorySectionHeight: CGFloat = 338.0
        static let verticalSpacing: CGFloat = 16.0
    }
    
    // MARK: - Lifecycle
    init(viewModel: CasinoCategoriesListViewModel) {
        self.viewModel = viewModel
        self.quickLinksTabBarView = QuickLinksTabBarView(viewModel: viewModel.quickLinksTabBarViewModel)
        
        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Track casino home screen initialization
        PerformanceTracker.shared.start(
            feature: .casinoHome,
            layer: .app,
            metadata: [
                "screen": "CasinoCategoriesListViewController",
                "lobbyType": viewModel.lobbyType.displayName
            ]
        )

        setupViews()
        setupBindings()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        setupQuickLinksTabBar()
        setupCollectionView()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupQuickLinksTabBar() {
        quickLinksTabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quickLinksTabBarView)
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: Constants.verticalSpacing, left: 0, bottom: Constants.verticalSpacing, right: 0)
        
        // Register cell types
        collectionView.register(TopBannerSliderCollectionViewCell.self, forCellWithReuseIdentifier: "TopBannerCell")
        collectionView.register(RecentlyPlayedGamesCollectionViewCell.self, forCellWithReuseIdentifier: "RecentlyPlayedCell")
        collectionView.register(CasinoCategorySectionCollectionViewCell.self, forCellWithReuseIdentifier: "CategorySectionCell")
        
        // Set delegates
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
  
        view.addSubview(collectionView)
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
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
                guard let self = self else { return }

                self.categorySections = categorySections
                self.collectionView.reloadData()

                // Only end tracking when we have actual data (not the initial empty state)
                if categorySections.count > 0 {
                    PerformanceTracker.shared.end(
                        feature: .casinoHome,
                        layer: .app,
                        metadata: [
                            "status": "complete",
                            "categoriesLoaded": "\(categorySections.count)",
                            "totalGames": "\(categorySections.reduce(0) { $0 + $1.sectionData.games.count })"
                        ]
                    )
                }
            }
            .store(in: &cancellables)
        
        // Error handling
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                // End tracking on error
                PerformanceTracker.shared.end(
                    feature: .casinoHome,
                    layer: .app,
                    metadata: [
                        "status": "error",
                        "error": errorMessage
                    ]
                )
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        viewModel.reloadCategories()
    }
    
    // MARK: - Error Handling
    
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

// MARK: - UICollectionViewDataSource
extension CasinoCategoriesListViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3  // Fixed: Banner, Recently Played, Categories
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.showTopBanner ? 1 : 0  // Banner (ignored if 0 items)
        case 1: return 1  // Recently played (always shown)
        case 2: return categorySections.count  // All categories
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: // Banner section (only called if showTopBanner is true)
            return configureBannerCell(at: indexPath)
        case 1: // Recently played section
            return configureRecentlyPlayedCell(at: indexPath)
        case 2: // Categories section
            return configureCategoryCell(at: indexPath)
        default:
            fatalError("Invalid section: \(indexPath.section)")
        }
    }

    // MARK: - Cell Configuration Methods

    private func configureBannerCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopBannerCell", for: indexPath) as! TopBannerSliderCollectionViewCell

        // Configure with banner viewModel (guaranteed non-nil when this method is called)
        cell.configure(with: viewModel.topBannerSliderViewModel!)

        return cell
    }

    private func configureRecentlyPlayedCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentlyPlayedCell", for: indexPath) as! RecentlyPlayedGamesCollectionViewCell

        cell.configure(with: viewModel.recentlyPlayedGamesViewModel)

        // Setup callbacks
        cell.onGameSelected = { [weak self] gameId in
            self?.viewModel.gameSelected(gameId)
        }

        return cell
    }

    private func configureCategoryCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategorySectionCell", for: indexPath) as! CasinoCategorySectionCollectionViewCell

        let categorySection = categorySections[indexPath.item]

        cell.configure(with: categorySection)

        // Setup callbacks
        cell.onCategoryButtonTapped = { [weak self] categoryId in
            self?.viewModel.categoryButtonTapped(
                categoryId: categoryId,
                categoryTitle: categorySection.categoryTitle
            )
        }

        cell.onGameSelected = { [weak self] gameId in
            self?.viewModel.gameSelected(gameId)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CasinoCategoriesListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width

        switch indexPath.section {
        case 0: // Banner section
            return CGSize(width: width, height: Constants.topBannerHeight)
        case 1: // Recently played section
            return CGSize(width: width, height: Constants.recentlyPlayedHeight)
        case 2: // Categories section
            return CGSize(width: width, height: Constants.categorySectionHeight)
        default:
            return CGSize(width: width, height: 0)
        }
    }
}
