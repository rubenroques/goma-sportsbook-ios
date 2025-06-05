import UIKit
import Combine
import GomaUI

// MARK: - MarketGroupCardsViewController
class MarketGroupCardsViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: MarketGroupCardsViewModel

    private let collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, MatchCardData>?
    private var cancellables = Set<AnyCancellable>()

    enum Section {
        case main
    }

    // MARK: - Initialization
    init(viewModel: MarketGroupCardsViewModel) {
        self.viewModel = viewModel

        // Create collection view with list-like layout
        let layout = Self.createLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureDataSource()
        setupScrollDelegate()
        bindToViewModel()
    }
    
    // Solution 2: Override viewWillAppear/viewDidAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Force collection view to recalculate layout
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        collectionView.backgroundColor = UIColor.App.backgroundPrimary
        collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private static func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180) // Estimated height for TallOddsMatchCardView - Auto Layout will determine actual size
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180) // Estimated height for TallOddsMatchCardView - Auto Layout will determine actual size
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1.5
        section.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 8, bottom: 24, trailing: 8)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureDataSource() {
        // Register the custom cell
        collectionView.register(
            TallOddsMatchCardCollectionViewCell.self,
            forCellWithReuseIdentifier: TallOddsMatchCardCollectionViewCell.identifier
        )

        let cellRegistration = UICollectionView.CellRegistration<TallOddsMatchCardCollectionViewCell, MatchCardData> { [weak self] cell, indexPath, matchCardData in
            print("[MarketGroupCardsVC] Configuring cell at indexPath: \(indexPath) for match: \(matchCardData.filteredData.match.id)")
            
            // Use the view model from the MatchCardData provided by the ViewModel
            let tallOddsViewModel = matchCardData.tallOddsViewModel
            let match = matchCardData.filteredData.match

            cell.configure(
                with: tallOddsViewModel,
                onMatchHeaderTapped: {
                    print("Match header tapped for: \(match.homeParticipant.name) vs \(match.awayParticipant.name)")
                },
                onFavoriteToggled: {
                    print("Favorite toggled for: \(match.homeParticipant.name) vs \(match.awayParticipant.name)")
                },
                onOutcomeSelected: { outcomeId in
                    print("Outcome selected: \(outcomeId) for: \(match.homeParticipant.name) vs \(match.awayParticipant.name)")
                },
                onMarketInfoTapped: {
                    print("Market info tapped for: \(match.homeParticipant.name) vs \(match.awayParticipant.name)")
                }
            )

            // Configure cell position
            let itemCount = self?.dataSource?.snapshot().numberOfItems ?? 0
            let isFirst = indexPath.item == 0
            let isLast = indexPath.item == itemCount - 1
            cell.configureCellPosition(isFirst: isFirst, isLast: isLast)
            
            print("[MarketGroupCardsVC] Cell configuration completed for indexPath: \(indexPath)")
        }

        dataSource = UICollectionViewDiffableDataSource<Section, MatchCardData>(
            collectionView: collectionView
        ) { collectionView, indexPath, matchCardData in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: matchCardData
            )
        }
    }

    private func setupScrollDelegate() {
        collectionView.delegate = self
    }

    // MARK: - ViewModel Binding
    private func bindToViewModel() {
        // Bind to match card data from ViewModel
        viewModel.$matchCardData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchCardData in
                let timestamp = CFAbsoluteTimeGetCurrent()
                print("[MarketGroupCardsVC] 📥 VIEWMODEL UPDATE RECEIVED at \(String(format: "%.3f", timestamp)) - \(matchCardData.count) items")
                self?.updateCollectionView(with: matchCardData)
            }
            .store(in: &cancellables)

        // Bind to scroll position from ViewModel
        viewModel.$scrollPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] position in
                // self?.applyScrollPosition(position)
            }
            .store(in: &cancellables)
    }

    // MARK: - UI Update Methods
    private func updateCollectionView(with matchCardData: [MatchCardData]) {
        guard let dataSource = dataSource else {
            print("[MarketGroupCardsVC] DataSource not yet configured, deferring snapshot update")
            return
        }

        let currentSnapshot = dataSource.snapshot()
        let currentItemCount = currentSnapshot.numberOfItems
        let newItemCount = matchCardData.count
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, MatchCardData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(matchCardData)
        
        // Log if this is a full reload vs incremental update
        if currentItemCount == 0 {
            print("[MarketGroupCardsVC] 🆕 INITIAL LOAD - Loading collection view for first time")
        } else if currentItemCount != newItemCount {
            print("[MarketGroupCardsVC] 📊 COUNT CHANGE - Item count changed from \(currentItemCount) to \(newItemCount)")
        } else {
            print("[MarketGroupCardsVC] ⚡ SAME COUNT RELOAD - Reloading \(newItemCount) items (possible data update)")
        }
        
        dataSource.apply(snapshot, animatingDifferences: false, completion: { [weak self] in
            self?.collectionView.layoutIfNeeded()
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })

    }

    private func applyScrollPosition(_ position: CGPoint) {
        // Ensure the collection view is laid out before setting offset
        collectionView.layoutIfNeeded()

        // If content size is zero, defer the scroll position update
        if collectionView.contentSize == .zero {
            DispatchQueue.main.async { [weak self] in
                self?.applyScrollPosition(position)
            }
            return
        }

        // Clamp the offset to valid bounds
        let maxOffset = max(0, collectionView.contentSize.height - collectionView.bounds.height + collectionView.contentInset.top + collectionView.contentInset.bottom)
        let clampedY = max(0, min(position.y, maxOffset))
        let clampedOffset = CGPoint(x: position.x, y: clampedY)

        collectionView.setContentOffset(clampedOffset, animated: false)
    }

    // MARK: - Public Interface (for backward compatibility)
    func updateMatches(_ matches: [Match]) {
        viewModel.updateMatches(matches)
    }

    func setScrollPosition(_ offset: CGPoint, animated: Bool) {
        viewModel.setScrollPosition(offset)
    }

    func getCurrentScrollPosition() -> CGPoint {
        return collectionView.contentOffset
    }
}

// MARK: - UICollectionViewDelegate
extension MarketGroupCardsViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Notify ViewModel about scroll changes
        viewModel.updateScrollPosition(scrollView.contentOffset)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Ensure final position is synced via ViewModel
        viewModel.updateScrollPosition(scrollView.contentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // If not decelerating, sync the final position via ViewModel
        if !decelerate {
            viewModel.updateScrollPosition(scrollView.contentOffset)
        }
    }
}
