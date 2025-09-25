import UIKit
import Combine
import GomaUI

// MARK: - MarketGroupCardsViewController
class MarketGroupCardsViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: MarketGroupCardsViewModel

    private let collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, CollectionViewItem>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Scroll Tracking
    weak var scrollDelegate: MarketGroupCardsScrollDelegate?
    weak var scrollSyncDelegate: ScrollSyncDelegate?

    // MARK: - Card Tap Callback
    var onCardTapped: ((Match) -> Void)?

    // MARK: - ComplexScroll Properties
    private var isReceivingSync = false

    enum Section: String, CaseIterable {
        case matchCards
    }

    enum CollectionViewItem: Hashable {
        case matchCard(MatchCardData)
    }

    // MARK: - Initialization
    init(viewModel: MarketGroupCardsViewModel) {
        self.viewModel = viewModel

        // Create collection view with list-like layout
        let layout = Self.createCollectionViewLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.configureDataSource()
        self.setupScrollDelegate()
        self.bindToViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Force collection view to recalculate layout
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Setup
    private func setupViews() {
        
        let appliedColor = UIColor.clear // UIColor.App.backgroundPrimary
        
        view.backgroundColor = appliedColor
        
        collectionView.backgroundColor = appliedColor
        collectionView.backgroundView?.backgroundColor = appliedColor
        
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private static func createCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section.allCases[sectionIndex]

            switch section {
            case .matchCards:
                // Dynamic height for match cards
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(180) // Estimated height - Auto Layout will determine actual size
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(180) // Estimated height - Auto Layout will determine actual size
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 1.5
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                return section
            }
        }
    }

    private func configureDataSource() {
        // Register the custom cells
        collectionView.register(
            TallOddsMatchCardCollectionViewCell.self,
            forCellWithReuseIdentifier: TallOddsMatchCardCollectionViewCell.identifier
        )

        // Registration for match card cells
        let matchCardCellRegistration = UICollectionView.CellRegistration<TallOddsMatchCardCollectionViewCell, MatchCardData> { [weak self] cell, indexPath, matchCardData in
            let tallOddsViewModel = matchCardData.tallOddsViewModel
            let match = matchCardData.filteredData.match

            cell.configure(
                with: tallOddsViewModel,
                onMatchHeaderTapped: {
                    // Handle match header tap
                },
                onFavoriteToggled: {
                    // Handle favorite toggle
                },
                onOutcomeSelected: { outcomeId in
                    // Handle outcome selection
                },
                onMarketInfoTapped: {
                    // Handle market info tap
                },
                onCardTapped: { [weak self] in
                    // Handle card tap - forward to parent controller
                    self?.onCardTapped?(matchCardData.filteredData.match)
                }
            )

            let sectionItemCount = self?.dataSource?.snapshot().numberOfItems(inSection: .matchCards) ?? 0
            let isFirst = indexPath.item == 0
            let isLast = indexPath.item == sectionItemCount - 1
            cell.configureCellPosition(isFirst: isFirst, isLast: isLast)
        }

        self.dataSource = UICollectionViewDiffableDataSource<Section, CollectionViewItem>(collectionView: collectionView)
          { collectionView, indexPath, item in
            switch item {
            case .matchCard(let matchCardData):
                return collectionView.dequeueConfiguredReusableCell(
                    using: matchCardCellRegistration,
                    for: indexPath,
                    item: matchCardData
                )
            }
        }
    }

    private func setupScrollDelegate() {
        collectionView.delegate = self
    }

    // MARK: - ViewModel Binding
    private func bindToViewModel() {
        // Bind to match card data from ViewModel
        viewModel.$matchCardsData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchCardsData in
                print("[MarketGroupCardsVC] 📥 VIEWMODEL UPDATE RECEIVED at - \(matchCardsData.count) matches with relevantMarkets")
                self?.updateCollectionView(with: matchCardsData)
            }
            .store(in: &cancellables)

    }

    // MARK: - UI Update Methods
    private func updateCollectionView(with matchCardsData: [MatchCardData]) {
        guard let dataSource = dataSource else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionViewItem>()

        // Add all sections
        snapshot.appendSections(Section.allCases)

        // Match cards section - always show
        let matchCardsItems = matchCardsData.map { CollectionViewItem.matchCard($0) }
        snapshot.appendItems(matchCardsItems, toSection: .matchCards)

        dataSource.apply(snapshot, animatingDifferences: false, completion: { [weak self] in
            self?.collectionView.layoutIfNeeded()
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })
    }

    func getCurrentScrollPosition() -> CGPoint {
        return collectionView.contentOffset
    }
    
    // MARK: - ComplexScroll Content Inset Management
    func updateContentInset(headerHeight: CGFloat) {
        // 1. Check if user is currently viewing headers
        let wasAtTop = collectionView.contentOffset.y <= -collectionView.contentInset.top + 10

        // 2. Update insets with new header height
        collectionView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 54, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: headerHeight, left: 0, bottom: 60, right: 0)

        collectionView.contentOffset = CGPoint(x: 0, y: -headerHeight)
                
        // 3. If they were viewing headers, maintain that view
        if wasAtTop {
            collectionView.contentOffset = CGPoint(x: 0, y: -headerHeight)
        }
        else {
            // 4. If they were scrolled into content, leave them there
        }
    }

    func setSyncedContentOffset(_ offset: CGPoint) {
        isReceivingSync = true
        collectionView.contentOffset = offset
        isReceivingSync = false
    }
}

// MARK: - UICollectionViewDelegate
extension MarketGroupCardsViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only propagate scroll events if we're not receiving a sync update
        if !isReceivingSync {
            scrollSyncDelegate?.didScroll(to: scrollView.contentOffset, from: self)
        }
    }
}
