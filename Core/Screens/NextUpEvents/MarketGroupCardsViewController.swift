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

    // MARK: - Section Visibility Control
    private var showBannerSection = false
    private var showPillSelectorSection = false

    enum Section: String, CaseIterable {
        case banner
        case pillSelector
        case matchCards
    }

    enum CollectionViewItem: Hashable {
        case banner(id: String)
        case pillSelector(id: String)
        case matchCard(MatchCardData)
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

        collectionView.contentInset = .init(top: 0, left: 0, bottom: 54, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 4, left: 0, bottom: 60, right: 0)
        
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
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section.allCases[sectionIndex]

            switch section {
            case .banner:
                // Static height for banner
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(136) // Fixed height for banner
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(136) // Fixed height for banner
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets.zero
                return section

            case .pillSelector:
                // Static height for pill selector
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(56) // Fixed height for pill selector
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(56) // Fixed height for pill selector
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets.zero
                return section

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

        collectionView.register(
            TopBannerSliderCollectionViewCell.self,
            forCellWithReuseIdentifier: TopBannerSliderCollectionViewCell.identifier
        )

        collectionView.register(
            PillSelectorBarCollectionViewCell.self,
            forCellWithReuseIdentifier: PillSelectorBarCollectionViewCell.identifier
        )

        // Registration for banner cell
        let bannerCellRegistration = UICollectionView.CellRegistration<TopBannerSliderCollectionViewCell, String> { [weak self] cell, indexPath, _ in
            let mockViewModel = MockTopBannerSliderViewModelForNextUp()

            cell.configure(
                with: mockViewModel,
                onBannerTapped: { bannerIndex in
                    // Handle banner tap actions here
                },
                onPageChanged: { pageIndex in
                    // Handle page change events here
                }
            )

        }

        // Registration for pill selector cell
        let pillSelectorCellRegistration = UICollectionView.CellRegistration<PillSelectorBarCollectionViewCell, String> { [weak self] cell, indexPath, _ in
            let mockViewModel = MockPillSelectorBarViewModel.footballPopularLeagues

            cell.configure(
                with: mockViewModel,
                onPillSelected: { pillId in
                    // Handle pill selection actions here
                }
            )
        }

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
                }
            )

            let sectionItemCount = self?.dataSource?.snapshot().numberOfItems(inSection: .matchCards) ?? 0
            let isFirst = indexPath.item == 0
            let isLast = indexPath.item == sectionItemCount - 1
            cell.configureCellPosition(isFirst: isFirst, isLast: isLast)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, CollectionViewItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .banner(let id):
                return collectionView.dequeueConfiguredReusableCell(
                    using: bannerCellRegistration,
                    for: indexPath,
                    item: id
                )
            case .pillSelector(let id):
                return collectionView.dequeueConfiguredReusableCell(
                    using: pillSelectorCellRegistration,
                    for: indexPath,
                    item: id
                )
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
        guard let dataSource = dataSource else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionViewItem>()

        // Add all sections
        snapshot.appendSections(Section.allCases)

        // Banner section - controlled by showBannerSection flag
        if showBannerSection {
            snapshot.appendItems([.banner(id: "banner")], toSection: .banner)
        }

        // Pill selector section - controlled by showPillSelectorSection flag
        if showPillSelectorSection {
            snapshot.appendItems([.pillSelector(id: "pillSelector")], toSection: .pillSelector)
        }

        // Match cards section - always show
        let matchCardItems = matchCardData.map { CollectionViewItem.matchCard($0) }
        snapshot.appendItems(matchCardItems, toSection: .matchCards)

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

    func setBannerSectionVisible(_ visible: Bool) {
        showBannerSection = visible
        // Trigger a refresh with current data
        if let currentMatchCardData = getCurrentMatchCardData() {
            updateCollectionView(with: currentMatchCardData)
        }
    }

    func setPillSelectorSectionVisible(_ visible: Bool) {
        showPillSelectorSection = visible
        // Trigger a refresh with current data
        if let currentMatchCardData = getCurrentMatchCardData() {
            updateCollectionView(with: currentMatchCardData)
        }
    }

    private func getCurrentMatchCardData() -> [MatchCardData]? {
        // Get current match card data from the snapshot
        let snapshot = dataSource?.snapshot()
        return snapshot?.itemIdentifiers(inSection: .matchCards).compactMap { item in
            if case .matchCard(let data) = item {
                return data
            }
            return nil
        }
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
