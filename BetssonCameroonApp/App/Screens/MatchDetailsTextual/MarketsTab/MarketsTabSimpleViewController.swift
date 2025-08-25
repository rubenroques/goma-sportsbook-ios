//
//  MarketsTabSimpleViewController.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import UIKit
import Combine
import GomaUI

public class MarketsTabSimpleViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MarketsTabSimpleViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    public var marketGroupId: String { viewModel.marketGroupId }
    public var marketGroupTitle: String { viewModel.marketGroupTitle }
    
    // MARK: - UI Components
    
    private let collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, CollectionViewItem>?
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Collection View Types
    
    enum Section: String, CaseIterable {
        case marketTypeGroups
    }
    
    enum CollectionViewItem: Hashable {
        case marketTypeGroup(MarketGroupWithIcons)
    }
    
    // MARK: - Initialization
    
    public init(viewModel: MarketsTabSimpleViewModelProtocol) {
        
        self.viewModel = viewModel
        
        // Create collection view with layout
        let layout = Self.createCollectionViewLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureDataSource()
        setupConstraints()
        setupBindings()
        
    }
    
    // MARK: - Setup
    private func setupUI() {
        
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        // Configure collection view
        collectionView.backgroundColor = UIColor.App.backgroundPrimary
        collectionView.showsVerticalScrollIndicator = true
        collectionView.alwaysBounceVertical = true
        
        // Configure loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        
        // Add views to hierarchy
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        
        
    }
    
    // MARK: - Collection View Layout
    
    private static func createCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section.allCases[sectionIndex]
            
            switch section {
            case .marketTypeGroups:
                // Dynamic height for market type group cards
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(150) // Estimated height - Auto Layout will determine actual size
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(150) // Estimated height - Auto Layout will determine actual size
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 16,
                    leading: 0,
                    bottom: 16,
                    trailing: 0
                )
                return section
            }
        }
    }
    
    // MARK: - Data Source Configuration
    private func configureDataSource() {
        
        // Register the custom cells
        collectionView.register(
            MarketTypeGroupCollectionViewCell.self,
            forCellWithReuseIdentifier: MarketTypeGroupCollectionViewCell.reuseIdentifier
        )
        
        // Market type group cell registration
        let marketTypeGroupCellRegistration = UICollectionView.CellRegistration<MarketTypeGroupCollectionViewCell, MarketGroupWithIcons> { [weak self] cell, indexPath, marketGroupWithIcons in
            guard let self = self else { return }
            
            cell.configure(with: marketGroupWithIcons)
            
            // Set up outcome selection callbacks
            cell.onOutcomeSelected = { [weak self] lineId, outcomeType in
                guard let self = self else { return }
                self.viewModel.handleOutcomeSelection(
                    marketGroupId: marketGroupWithIcons.marketGroup.id,
                    lineId: lineId,
                    outcomeType: outcomeType,
                    isSelected: true
                )
            }
            
            cell.onOutcomeDeselected = { [weak self] lineId, outcomeType in
                guard let self = self else { return }
                self.viewModel.handleOutcomeSelection(
                    marketGroupId: marketGroupWithIcons.marketGroup.id,
                    lineId: lineId,
                    outcomeType: outcomeType,
                    isSelected: false
                )
            }
        }
        
        self.dataSource = UICollectionViewDiffableDataSource<Section, CollectionViewItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .marketTypeGroup(let marketGroupWithIcons):
                return collectionView.dequeueConfiguredReusableCell(
                    using: marketTypeGroupCellRegistration,
                    for: indexPath,
                    item: marketGroupWithIcons
                )
            }
        }
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Collection view
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        // Bind loading state
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // Bind error state
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.showError(error)
                }
            }
            .store(in: &cancellables)
        
        // Bind market groups data
        viewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                guard let self = self else { return }
                self.updateCollectionView(with: marketGroups)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Update Methods
    
    private func updateCollectionView(with marketGroups: [MarketGroupWithIcons]) {
        guard let dataSource = dataSource else {
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionViewItem>()
        
        // Add all sections
        snapshot.appendSections(Section.allCases)
        
        // Market type groups section
        let marketTypeGroupItems = marketGroups.map { CollectionViewItem.marketTypeGroup($0) }
        snapshot.appendItems(marketTypeGroupItems, toSection: .marketTypeGroups)
        
        dataSource.apply(snapshot, animatingDifferences: true, completion: { [weak self] in
            guard let self = self else { return }
            
            // Force layout recalculation after data update
            DispatchQueue.main.async {
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.layoutIfNeeded()
            }
        })
    }
    
    // MARK: - Helper Methods
    
    private func showError(_ message: String) {
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.loadMarkets()
        })
        present(alert, animated: true)
    }
}
