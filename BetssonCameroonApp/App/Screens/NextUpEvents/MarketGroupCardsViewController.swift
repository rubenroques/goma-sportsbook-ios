import UIKit
import Combine
import GomaUI
import GomaPerformanceKit

// MARK: - MarketGroupCardsViewController
class MarketGroupCardsViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: MarketGroupCardsViewModel

    private let tableView: UITableView
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Performance Tracking
    private var hasTrackedFirstUpdate = false
    private var hasTrackedFirstCell = false

    // MARK: - Footer Properties (BetssonFrance pattern)
    private let footerInnerView = UIView(frame: .zero)
    private var footerView: ExtendedListFooterView?
    private var enableStickyFooter: Bool = false  // Toggle for sticky behavior (default: off)

    // MARK: - Scroll Tracking
    weak var scrollDelegate: MarketGroupCardsScrollDelegate?
    weak var scrollSyncDelegate: ScrollSyncDelegate?

    // MARK: - Card Tap Callback
    var onCardTapped: ((Match) -> Void)?

    // MARK: - Load More Callback
    var onLoadMoreTapped: (() -> Void)?

    // MARK: - ComplexScroll Properties
    private var isReceivingSync = false

    enum Section: Int, CaseIterable {
        case matchCards = 0
        case loadMoreButton = 1
        // Footer moved to tableFooterView (BetssonFrance pattern)
    }

    // MARK: - Initialization
    init(viewModel: MarketGroupCardsViewModel) {
        self.viewModel = viewModel

        self.tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false

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
        self.bindToViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Dynamically update tableFooterView height based on footerInnerView
        // (BetssonFrance pattern - required because tableFooterView uses frame-based layout)
        guard let footerView = tableView.tableFooterView else { return }
        
        // Update width to match tableView width
        let tableViewWidth = tableView.bounds.width
        if footerView.frame.width != tableViewWidth {
            footerView.frame.size.width = tableViewWidth
        }
        
        // Force layout pass to get accurate size measurements
        footerInnerView.setNeedsLayout()
        footerInnerView.layoutIfNeeded()
        
        // Use systemLayoutSizeFitting for accurate height calculation
        let targetSize = CGSize(width: tableViewWidth, height: UIView.layoutFittingCompressedSize.height)
        let calculatedSize = footerInnerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        let calculatedHeight = calculatedSize.height
        
        // Only update if height has changed
        if abs(footerView.frame.height - calculatedHeight) > 1.0 {
            footerView.frame.size.height = calculatedHeight
            tableView.tableFooterView = footerView  // Reassign to trigger update
        }
    }

    // MARK: - Setup
    private func setupViews() {

        let appliedColor = UIColor.clear

        view.backgroundColor = appliedColor

        tableView.backgroundColor = appliedColor
        tableView.backgroundView?.backgroundColor = appliedColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180

        view.addSubview(tableView)

        // Setup sticky footer (BetssonFrance pattern)
        setupStickyFooter()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Sticky Footer Setup (BetssonFrance pattern)
    private func setupStickyFooter() {
        // Configure footer inner view
        footerInnerView.translatesAutoresizingMaskIntoConstraints = false
        footerInnerView.backgroundColor = .clear

        // Create table footer view with arbitrary height (will be adjusted by Auto Layout)
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 800))
        tableFooterView.backgroundColor = .clear

        // Set as table footer
        tableView.tableFooterView = tableFooterView
        tableFooterView.addSubview(footerInnerView)

        // Get footer ViewModel from parent ViewModel (MVVM-C pattern)
        guard let footerViewModel = viewModel.footerViewModel else {
            print("⚠️ [MarketGroupCardsVC] No footer ViewModel available")
            return
        }

        // Create actual footer content (ExtendedListFooterView directly, not cell wrapper)
        let extendedFooterView = ExtendedListFooterView(viewModel: footerViewModel)
        extendedFooterView.translatesAutoresizingMaskIntoConstraints = false
        self.footerView = extendedFooterView
        footerInnerView.addSubview(extendedFooterView)

        // Build constraints list
        var constraints: [NSLayoutConstraint] = [
            // Pin footerInnerView to tableFooterView edges
            footerInnerView.topAnchor.constraint(equalTo: tableFooterView.topAnchor),
            footerInnerView.rightAnchor.constraint(equalTo: tableFooterView.rightAnchor),
            footerInnerView.leftAnchor.constraint(equalTo: tableFooterView.leftAnchor),
            footerInnerView.bottomAnchor.constraint(equalTo: tableFooterView.bottomAnchor),

            // Footer content constraints - ExtendedListFooterView with proper intrinsic height
            extendedFooterView.leadingAnchor.constraint(equalTo: footerInnerView.leadingAnchor),
            extendedFooterView.trailingAnchor.constraint(equalTo: footerInnerView.trailingAnchor),
            extendedFooterView.topAnchor.constraint(equalTo: footerInnerView.topAnchor),
            extendedFooterView.bottomAnchor.constraint(equalTo: footerInnerView.bottomAnchor)
        ]

        // Pin to tableView's superview bottom
        // This makes footer stick to bottom when content is short
        // Only add if sticky footer is enabled
        if enableStickyFooter {
            constraints.append(
                footerInnerView.bottomAnchor.constraint(greaterThanOrEqualTo: tableView.superview!.bottomAnchor)
            )
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func configureDataSource() {
        tableView.register(
            TallOddsMatchCardTableViewCell.self,
            forCellReuseIdentifier: TallOddsMatchCardTableViewCell.identifier
        )
        tableView.register(
            SeeMoreButtonTableViewCell.self,
            forCellReuseIdentifier: SeeMoreButtonTableViewCell.identifier
        )
        // FooterTableViewCell no longer registered - used in tableFooterView instead

        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - ViewModel Binding
    private func bindToViewModel() {
        viewModel.$matchCardsData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchCardsData in
                guard let self = self else { return }
                print("[MarketGroupCardsVC] 📥 VIEWMODEL UPDATE RECEIVED - \(matchCardsData.count) matches")

                // Track first UI update
                if !self.hasTrackedFirstUpdate && !matchCardsData.isEmpty {
                    self.hasTrackedFirstUpdate = true

                    PerformanceTracker.shared.start(
                        feature: .homeScreen,
                        layer: .app,
                        metadata: [
                            "operation": "table_reload",
                            "match_count": "\(matchCardsData.count)"
                        ]
                    )
                }

                self.tableView.reloadData()

                // Track completion
                if !matchCardsData.isEmpty {
                    PerformanceTracker.shared.end(
                        feature: .homeScreen,
                        layer: .app,
                        metadata: [
                            "operation": "table_reload",
                            "status": "complete"
                        ]
                    )
                }
            }
            .store(in: &cancellables)

        viewModel.$hasMoreEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasMore in
                print("[MarketGroupCardsVC] 📥 hasMoreEvents changed: \(hasMore)")
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$isLoadingMore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                print("[MarketGroupCardsVC] 📥 isLoadingMore changed: \(isLoading)")
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    func getCurrentScrollPosition() -> CGPoint {
        return tableView.contentOffset
    }

    // MARK: - ComplexScroll Content Inset Management
    func updateContentInset(headerHeight: CGFloat) {
        let wasAtTop = tableView.contentOffset.y <= -tableView.contentInset.top + 10

        // Bottom inset accounts for: betslip floating view (100pt from bottom) + betslip max height (~60pt) = 160pt
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 160, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: headerHeight, left: 0, bottom: 166, right: 0)

        tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)

        if wasAtTop {
            tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
        }
    }

    func setSyncedContentOffset(_ offset: CGPoint) {
        isReceivingSync = true
        tableView.contentOffset = offset
        isReceivingSync = false
    }
}

// MARK: - UITableViewDataSource
extension MarketGroupCardsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = Section(rawValue: section)

        switch sectionType {
        case .matchCards:
            return viewModel.matchCardsData.count
        case .loadMoreButton:
            return (viewModel.hasMoreEvents && !viewModel.matchCardsData.isEmpty) ? 1 : 0
        case .none:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = Section(rawValue: indexPath.section)

        switch sectionType {
        case .matchCards:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TallOddsMatchCardTableViewCell.identifier,
                for: indexPath
            ) as? TallOddsMatchCardTableViewCell else {
                return UITableViewCell()
            }

            let matchCardData = viewModel.matchCardsData[indexPath.row]
            let tallOddsViewModel = matchCardData.tallOddsViewModel

            cell.configure(
                with: tallOddsViewModel,
                onMatchHeaderTapped: {},
                onFavoriteToggled: {},
                onOutcomeSelected: { _ in },
                onMarketInfoTapped: {},
                onCardTapped: { [weak self] in
                    self?.onCardTapped?(matchCardData.filteredData.match)
                }
            )

            let totalMatchCards = viewModel.matchCardsData.count
            let isFirst = indexPath.row == 0
            let isLast = indexPath.row == totalMatchCards - 1
            cell.configureCellPosition(isFirst: isFirst, isLast: isLast)

            // Track first cell creation (only once)
            if indexPath.row == 0 && !hasTrackedFirstCell {
                hasTrackedFirstCell = true

                PerformanceTracker.shared.end(
                    feature: .homeScreen,
                    layer: .app,
                    metadata: [
                        "operation": "first_cell_rendered",
                        "status": "complete"
                    ]
                )
            }

            return cell

        case .loadMoreButton:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SeeMoreButtonTableViewCell.identifier,
                for: indexPath
            ) as? SeeMoreButtonTableViewCell else {
                return UITableViewCell()
            }

            let buttonData = SeeMoreButtonData(
                id: "load-more-matches",
                title: localized("load_more_events"),
                remainingCount: nil
            )

            cell.configure(
                with: buttonData,
                isLoading: viewModel.isLoadingMore,
                isEnabled: !viewModel.isLoadingMore
            )

            cell.onSeeMoreTapped = { [weak self] in
                print("[MarketGroupCardsVC] Load more button tapped")
                self?.onLoadMoreTapped?()
            }

            return cell

        case .none:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate
extension MarketGroupCardsViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isReceivingSync {
            scrollSyncDelegate?.didScroll(to: scrollView.contentOffset, from: self)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = Section(rawValue: indexPath.section)

        switch section {
        case .matchCards:
            return UITableView.automaticDimension
        case .loadMoreButton:
            return 60
        case .none:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionType = Section(rawValue: section)

        switch sectionType {
        case .matchCards:
            return 8
        case .loadMoreButton:
            return 0
        case .none:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionType = Section(rawValue: section)

        switch sectionType {
        case .matchCards:
            return 8
        case .loadMoreButton:
            return 0
        case .none:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
}
