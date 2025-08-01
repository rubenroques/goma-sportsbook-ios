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
        static let topBannerHeight: CGFloat = 200.0
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
                self?.categorySections = categorySections
                self?.collectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 1 TopBanner + 1 RecentlyPlayed + n CategorySections
        return 2 + categorySections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            // Top Banner Slider
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopBannerCell", for: indexPath) as! TopBannerSliderCollectionViewCell
            
            // Configure with mock viewModel for now
            cell.configure(with: viewModel.topBannerSliderViewModel)
            
            // Setup callbacks
            cell.onBannerTapped = { bannerIndex in
                print("Banner tapped at index: \(bannerIndex)")
                // TODO: Handle banner tap navigation
            }
            
            return cell
            
        case 1:
            // Recently Played Games
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentlyPlayedCell", for: indexPath) as! RecentlyPlayedGamesCollectionViewCell
            
            // Configure with mock viewModel for now  
            cell.configure(with: viewModel.recentlyPlayedGamesViewModel)
            
            // Setup callbacks
            cell.onGameSelected = { [weak self] gameId in
                print("Recently played game selected: \(gameId)")
                // TODO: Handle game selection navigation via coordinator
            }
            
            return cell
            
        default:
            // Casino Category Sections
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategorySectionCell", for: indexPath) as! CasinoCategorySectionCollectionViewCell
            
            let categoryIndex = indexPath.item - 2
            let categorySection = categorySections[categoryIndex]
            
            cell.configure(with: categorySection)
            
            // Setup callbacks
            cell.onCategoryButtonTapped = { [weak self] categoryId in
                self?.viewModel.categoryButtonTapped(
                    categoryId: categoryId,
                    categoryTitle: categorySection.categoryTitle
                )
            }
            
            cell.onGameSelected = { gameId in
                print("Game selected in category section: \(gameId)")
                // Games can be selected from the preview, but navigation happens via category button
            }
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CasinoCategoriesListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        
        switch indexPath.item {
        case 0:
            // Top Banner Slider
            return CGSize(width: width, height: Constants.topBannerHeight)
        case 1:
            // Recently Played Games
            return CGSize(width: width, height: Constants.recentlyPlayedHeight)
        default:
            // Casino Category Sections
            return CGSize(width: width, height: Constants.categorySectionHeight)
        }
    }
}
