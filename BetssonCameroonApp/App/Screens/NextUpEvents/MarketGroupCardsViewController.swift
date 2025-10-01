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

    // MARK: - Load More Callback (NEW)
    var onLoadMoreTapped: (() -> Void)?

    // MARK: - ComplexScroll Properties
    private var isReceivingSync = false

    enum Section: String, CaseIterable {
        case matchCards
        case loadMoreButton
        case footer
    }

    enum CollectionViewItem: Hashable {
        case matchCard(MatchCardData)
        case loadMoreButton
        case footer
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

            case .loadMoreButton:
                // Full width button, fixed height
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(60)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(60)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                return section

            case .footer:
                // Full width footer, fixed height
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
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
        collectionView.register(
            SeeMoreButtonCollectionViewCell.self,
            forCellWithReuseIdentifier: "SeeMoreButtonCell"
        )
        collectionView.register(
            FooterCollectionViewCell.self,
            forCellWithReuseIdentifier: "FooterCell"
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

        // Registration for load more button cell
        let loadMoreButtonRegistration = UICollectionView.CellRegistration<SeeMoreButtonCollectionViewCell, Void> { [weak self] cell, indexPath, _ in
            let buttonData = SeeMoreButtonData(
                id: "load-more-matches",
                title: "Load More Events",
                remainingCount: nil
            )

            cell.configure(
                with: buttonData,
                isLoading: self?.viewModel.isLoadingMore ?? false,
                isEnabled: !(self?.viewModel.isLoadingMore ?? false)
            )

            cell.onSeeMoreTapped = { [weak self] in
                print("[MarketGroupCardsVC] Load more button tapped")
                self?.onLoadMoreTapped?()
            }
        }

        // Registration for footer cell
        let footerRegistration = UICollectionView.CellRegistration<FooterCollectionViewCell, Void> { cell, indexPath, _ in
            // Footer is already configured in cell
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
            case .loadMoreButton:
                return collectionView.dequeueConfiguredReusableCell(
                    using: loadMoreButtonRegistration,
                    for: indexPath,
                    item: ()
                )
            case .footer:
                return collectionView.dequeueConfiguredReusableCell(
                    using: footerRegistration,
                    for: indexPath,
                    item: ()
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

        // Bind to hasMoreEvents to show/hide load more button
        viewModel.$hasMoreEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasMore in
                print("[MarketGroupCardsVC] 📥 hasMoreEvents changed: \(hasMore)")
                // Trigger collection view update to show/hide button
                if let matchCardsData = self?.viewModel.matchCardsData {
                    self?.updateCollectionView(with: matchCardsData)
                }
            }
            .store(in: &cancellables)

        // Bind to isLoadingMore to update button state
        viewModel.$isLoadingMore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                print("[MarketGroupCardsVC] 📥 isLoadingMore changed: \(isLoading)")
                // Reload load more section to update loading state
                if let matchCardsData = self?.viewModel.matchCardsData {
                    self?.updateCollectionView(with: matchCardsData)
                }
            }
            .store(in: &cancellables)

    }

    // MARK: - UI Update Methods
    private func updateCollectionView(with matchCardsData: [MatchCardData]) {
        guard let dataSource = dataSource else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionViewItem>()

        // Add all sections
        snapshot.appendSections(Section.allCases)

        // Section 0: Match cards - always show
        let matchCardsItems = matchCardsData.map { CollectionViewItem.matchCard($0) }
        snapshot.appendItems(matchCardsItems, toSection: .matchCards)

        // Section 1: Load More Button - conditionally show based on hasMoreEvents
        if viewModel.hasMoreEvents && !matchCardsData.isEmpty {
            snapshot.appendItems([.loadMoreButton], toSection: .loadMoreButton)
        }

        // Section 2: Footer - always show
        snapshot.appendItems([.footer], toSection: .footer)

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
