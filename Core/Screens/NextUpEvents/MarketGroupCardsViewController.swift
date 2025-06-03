import UIKit
import Combine

// MARK: - FilteredMatchData
struct FilteredMatchData: Hashable {
    let match: Match
    let relevantMarkets: [Market]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(match.id)
    }
    
    static func == (lhs: FilteredMatchData, rhs: FilteredMatchData) -> Bool {
        return lhs.match.id == rhs.match.id
    }
}

// MARK: - MarketGroupCardsViewController
class MarketGroupCardsViewController: UIViewController {
    
    // MARK: - Properties
    private let marketTypeId: String
    private var allMatches: [Match] = []
    private var filteredData: [FilteredMatchData] = []
    private let collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, FilteredMatchData>?
    
    enum Section {
        case main
    }
    
    // MARK: - Initialization
    init(marketTypeId: String) {
        self.marketTypeId = marketTypeId
        
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
        // Apply any pending data updates
        updateSnapshot()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
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
            heightDimension: .estimated(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, FilteredMatchData> { cell, indexPath, filteredData in
            var content = cell.defaultContentConfiguration()
            
            let match = filteredData.match
            let markets = filteredData.relevantMarkets
            
            // Primary text: match participants
            content.text = "\(match.homeParticipant.name) vs \(match.awayParticipant.name)"
            
            // Secondary text: market info for this type
            if let firstMarket = markets.first {
                content.secondaryText = "\(firstMarket.name) - \(markets.count) market(s)"
            } else {
                content.secondaryText = "No markets available"
            }
            
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, FilteredMatchData>(
            collectionView: collectionView
        ) { collectionView, indexPath, filteredData in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: filteredData
            )
        }
    }
    
    // MARK: - Public Methods
    func updateMatches(_ matches: [Match]) {
        allMatches = matches
        filteredData = filterMatches()
        updateSnapshot()
    }
    
    // MARK: - Private Methods
    private func filterMatches() -> [FilteredMatchData] {
        return allMatches.compactMap { match in
            let relevantMarkets = match.markets.filter { $0.marketTypeId == marketTypeId }
            guard !relevantMarkets.isEmpty else { return nil }
            return FilteredMatchData(match: match, relevantMarkets: relevantMarkets)
        }
    }
    
    private func updateSnapshot() {
        // Only update snapshot if dataSource is configured
        guard let dataSource = dataSource else {
            print("DataSource not yet configured, deferring snapshot update")
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, FilteredMatchData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filteredData)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
} 