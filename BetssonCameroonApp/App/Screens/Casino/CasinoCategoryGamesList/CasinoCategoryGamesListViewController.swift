//
//  CasinoCategoryGamesListViewController.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import UIKit
import Combine
import GomaUI

class CasinoCategoryGamesListViewController: UIViewController {
    
    // MARK: - UI Components
    // Top bar components now managed by TopBarContainerController
    private let quickLinksTabBarView: QuickLinksTabBarView
    private let collectionView: UICollectionView
    
    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.setTitle("Back", for: .normal)
        button.tintColor = StyleProvider.Color.textPrimary
        return button
    }()
    
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
    let viewModel: CasinoCategoryGamesListViewModel
    private var cancellables = Set<AnyCancellable>()
    private var games: [MockCasinoGameCardViewModel] = []
    
    // MARK: - Constants
    private enum Constants {
        static let cellSpacing: CGFloat = 16.0
        static let horizontalPadding: CGFloat = 16.0
        static let itemsPerRow: Int = 2
        static let itemAspectRatio: CGFloat = 167.0 / 266.0 // width / height from CasinoGameCardView
    }
    
    // MARK: - Lifecycle
    init(viewModel: CasinoCategoryGamesListViewModel) {
        self.viewModel = viewModel
        self.quickLinksTabBarView = QuickLinksTabBarView(viewModel: viewModel.quickLinksTabBarViewModel)
        
        // Create collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.cellSpacing
        layout.minimumLineSpacing = Constants.cellSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 16,
            left: Constants.horizontalPadding,
            bottom: 16,
            right: Constants.horizontalPadding
        )
        
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
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        setupNavigationView()
        setupQuickLinksTabBar()
        setupCollectionView()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    
    private func setupNavigationView() {
        view.addSubview(navigationView)
        navigationView.addSubview(navigationTitleLabel)
        navigationView.addSubview(backButton)
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
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
        
        // Register cells
        collectionView.register(CasinoGameCardCollectionViewCell.self, forCellWithReuseIdentifier: "GameCardCell")
        collectionView.register(SeeMoreButtonCollectionViewCell.self, forCellWithReuseIdentifier: "SeeMoreButtonCell")
        
        // Set delegates
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicatorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // QuickLinks Tab Bar (now at top of content)
            quickLinksTabBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLinksTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickLinksTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Navigation View (following PhoneVerification pattern)
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 40),
            
            // Navigation Title (centered with padding for back button)
            navigationTitleLabel.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 50),
            navigationTitleLabel.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -50),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            
            // Back Button (left side)
            backButton.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
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
        viewModel.$loadingState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadingState in
                let showFullScreenLoader = (loadingState == .initialLoading)
                self?.loadingIndicatorView.isHidden = !showFullScreenLoader
            }
            .store(in: &cancellables)
        
        // Category title
        viewModel.$categoryTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.navigationTitleLabel.text = title
            }
            .store(in: &cancellables)
        
        // Games
        viewModel.$games
            .receive(on: DispatchQueue.main)
            .sink { [weak self] games in
                self?.games = games
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
        
        // HasMoreGames state (triggers collection view updates)
        viewModel.$hasMoreGames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
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
            self?.viewModel.reloadGames()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        viewModel.navigateBack()
    }
}

// MARK: - Collection View Data Source
extension CasinoCategoryGamesListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Section 0: Games, Section 1: See More Button
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return games.count // Game cards
        case 1: return viewModel.hasMoreGames ? 1 : 0 // See More button
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: // Game cards section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCardCell", for: indexPath) as! CasinoGameCardCollectionViewCell
            
            let gameViewModel = games[indexPath.item]
            cell.configure(with: gameViewModel)
            
            // Set callback for game selection
            cell.onGameSelected = { [weak self] gameId in
                self?.viewModel.gameSelected(gameId)
            }
            
            return cell
            
        case 1: // See More button section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeeMoreButtonCell", for: indexPath) as! SeeMoreButtonCollectionViewCell
            
            // Configure See More button
            let buttonData = SeeMoreButtonData(
                id: "load-more-\(viewModel.categoryTitle)",
                title: "Load More Games",
                remainingCount: nil
            )
            
            cell.configure(
                with: buttonData,
                isLoading: viewModel.isLoadingMore,
                isEnabled: !viewModel.isLoadingMore
            )
            
            // Set callback for see more button tap
            cell.onSeeMoreTapped = { [weak self] in
                self?.viewModel.loadMoreGames()
            }
            
            return cell
            
        default:
            fatalError("Unexpected section: \(indexPath.section)")
        }
    }
}

// MARK: - Collection View Delegate
extension CasinoCategoryGamesListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Game cards section
            let gameViewModel = games[indexPath.item]
            viewModel.gameSelected(gameViewModel.gameId)
        case 1: // See More button section
            viewModel.loadMoreGames()
        default:
            break
        }
    }
}

// MARK: - Collection View Flow Layout Delegate
extension CasinoCategoryGamesListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0: // Game cards - use existing 2-column grid logic
            let availableWidth = collectionView.bounds.width
            let totalHorizontalPadding = Constants.horizontalPadding * 2
            let totalSpacing = Constants.cellSpacing * CGFloat(Constants.itemsPerRow - 1)
            let itemWidth = (availableWidth - totalHorizontalPadding - totalSpacing) / CGFloat(Constants.itemsPerRow)
            let itemHeight = itemWidth / Constants.itemAspectRatio
            
            return CGSize(width: itemWidth, height: itemHeight)
            
        case 1: // See More button - full width, fixed height
            let availableWidth = collectionView.bounds.width
            let totalHorizontalPadding = Constants.horizontalPadding * 2
            let buttonWidth = availableWidth - totalHorizontalPadding
            let buttonHeight: CGFloat = 60 // 44pt button + 16pt padding
            
            return CGSize(width: buttonWidth, height: buttonHeight)
            
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0: return Constants.cellSpacing // Normal spacing for game cards
        case 1: return 0 // No inter-item spacing for See More button (single item)
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0: return Constants.cellSpacing // Normal spacing for game cards
        case 1: return 8 // Small spacing above See More button
        default: return 0
        }
    }
}
