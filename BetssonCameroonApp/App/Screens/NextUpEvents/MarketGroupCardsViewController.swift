import UIKit
import Combine
import GomaUI

// MARK: - MarketGroupCardsViewController
class MarketGroupCardsViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: MarketGroupCardsViewModel

    private let tableView: UITableView
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Footer Properties (BetssonFrance pattern)
    private let footerInnerView = UIView(frame: .zero)

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
        if let footerView = tableView.tableFooterView {
            let size = footerInnerView.frame.size
            if footerView.frame.size.height != size.height {
                footerView.frame.size.height = size.height
                tableView.tableFooterView = footerView  // Reassign to trigger update
            }
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

        // Create table footer view with arbitrary height
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 80))
        tableFooterView.backgroundColor = .clear

        // Set as table footer
        tableView.tableFooterView = tableFooterView
        tableFooterView.addSubview(footerInnerView)

        // Create actual footer content
        let footerCell = FooterTableViewCell()
        footerCell.translatesAutoresizingMaskIntoConstraints = false
        footerInnerView.addSubview(footerCell.contentView)

        NSLayoutConstraint.activate([
            // Pin footerInnerView to tableFooterView edges
            footerInnerView.rightAnchor.constraint(equalTo: tableFooterView.rightAnchor),
            footerInnerView.leftAnchor.constraint(equalTo: tableFooterView.leftAnchor),
            footerInnerView.bottomAnchor.constraint(equalTo: tableFooterView.bottomAnchor),

            // THE MAGIC CONSTRAINT: Pin to tableView's superview bottom
            // This makes footer stick to bottom when content is short
            footerInnerView.bottomAnchor.constraint(greaterThanOrEqualTo: tableView.superview!.bottomAnchor),

            // Footer content constraints
            footerCell.contentView.leadingAnchor.constraint(equalTo: footerInnerView.leadingAnchor),
            footerCell.contentView.trailingAnchor.constraint(equalTo: footerInnerView.trailingAnchor),
            footerCell.contentView.topAnchor.constraint(equalTo: footerInnerView.topAnchor),
            footerCell.contentView.bottomAnchor.constraint(equalTo: footerInnerView.bottomAnchor),
            footerCell.contentView.heightAnchor.constraint(equalToConstant: 80)
        ])
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
                print("[MarketGroupCardsVC] 📥 VIEWMODEL UPDATE RECEIVED - \(matchCardsData.count) matches")
                self?.tableView.reloadData()
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
                title: "Load More Events",
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

    /*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let section = Section(rawValue: indexPath.section)

        if section == .matchCards {
            let totalRows = tableView.numberOfRows(inSection: indexPath.section)

            if indexPath.row < totalRows - 1 {
                let separatorView = UIView()
                separatorView.backgroundColor = UIColor.App.backgroundPrimary
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                separatorView.tag = 9999

                cell.contentView.subviews.first(where: { $0.tag == 9999 })?.removeFromSuperview()

                cell.contentView.addSubview(separatorView)

                NSLayoutConstraint.activate([
                    separatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
                    separatorView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
                    separatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    separatorView.heightAnchor.constraint(equalToConstant: 1.5)
                ])
            }
        }
    }
    */
    
}
