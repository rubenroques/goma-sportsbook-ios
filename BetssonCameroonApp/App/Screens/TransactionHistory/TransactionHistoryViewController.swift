
import UIKit
import Combine
import GomaUI
import ServicesProvider

final class TransactionHistoryViewController: UIViewController {

    // MARK: - Private Properties

    private let viewModel: TransactionHistoryViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var navigationBarView: SimpleNavigationBarView = {
        let viewModel = BetssonCameroonNavigationBarViewModel(
            title: localized("transaction_history"),
            onBackTapped: { [weak self] in
                self?.viewModel.didTapBack()
            }
        )
        let navBar = SimpleNavigationBarView(viewModel: viewModel)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()

    private lazy var pillSelectorBarViewContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }()
    
    private lazy var pillSelectorBarView: PillSelectorBarView = {
        let view = PillSelectorBarView(viewModel: viewModel.transactionTypePillSelectorViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var gameTypeFilterBarContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }()
    
    private lazy var gameTypeFilterBar: MarketGroupSelectorTabView = {
        let view = MarketGroupSelectorTabView.init(viewModel: viewModel.gameTypeTabBarViewModel,
                                                   barBackgroundColor: UIColor.App.backgroundTertiary,
                                                   itemIdleBackgroundColor: UIColor.App.backgroundTertiary,
                                                   itemSelectedBackgroundColor: UIColor.App.backgroundTertiary)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    

    private lazy var filtersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var timeFilterBar: SimpleSquaredFilterBarView = {
        let timeFilters = SimpleSquaredFilterBarData(
            items: [
                ("all", localized("all")),
                ("1d", localized("time_filter_1d")),
                ("1w", localized("time_filter_1w")),
                ("1m", localized("time_filter_1m")),
                ("3m", localized("time_filter_3m"))
            ],
            selectedId: "all"
        )

        let filterBar = SimpleSquaredFilterBarView(data: timeFilters)
        filterBar.onFilterSelected = { [weak self] filterId in
            let filter = self?.mapToTransactionDateFilter(filterId) ?? .all
            self?.viewModel.selectDateFilter(filter)
        }
        filterBar.backgroundColor = .clear
        return filterBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.App.backgroundTertiary
        tableView.separatorStyle = .none

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.sectionHeaderTopPadding = 0
        tableView.contentInsetAdjustmentBehavior = .never
        
        // Register transaction cell
        tableView.register(TransactionItemTableViewCell.self, forCellReuseIdentifier: TransactionItemTableViewCell.identifier)

        // Add pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        return tableView
    }()

    private lazy var loadingView: UIView = Self.createLoadingView()
    private lazy var errorView: UIView = Self.createErrorView()

    private var currentTransactions: [TransactionHistoryItem] = []
    private var selectedDateFilter: TransactionDateFilter = .all

    // MARK: - Initialization

    init(viewModel: TransactionHistoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()

        // Load initial data
        viewModel.loadInitialData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - Status Bar

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundTertiary

        
        let pillCustomization = PillItemCustomization(
            selectedStyle: PillItemStyle(
                textColor: UIColor.App.highlightSecondaryContrast,
                backgroundColor: UIColor.App.highlightPrimary,
                borderColor: .clear,
                borderWidth: 0.0
            ),
            unselectedStyle: PillItemStyle(
                textColor: UIColor.App.textPrimary,
                backgroundColor: UIColor.App.backgroundSecondary,
                borderColor: .clear,
                borderWidth: 0.0
            )
        )
        pillSelectorBarView.setPillCustomization(pillCustomization)
        pillSelectorBarView.setCustomBackgroundColor( UIColor.App.backgroundTertiary )

        
        errorView.backgroundColor = UIColor.App.backgroundTertiary
        
        setupViewHierarchy()
        setupConstraints()
    }

    private func setupViewHierarchy() {
        view.addSubview(navigationBarView)
        view.addSubview(filtersStackView)
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(errorView)


        pillSelectorBarViewContainer.addSubview(pillSelectorBarView)
        
        gameTypeFilterBarContainer.addSubview(gameTypeFilterBar)

        // Add filters to stack view
        filtersStackView.addArrangedSubview(pillSelectorBarViewContainer)
        filtersStackView.addArrangedSubview(gameTypeFilterBarContainer)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Navigation Bar
            navigationBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Filters Stack View (contains pill selector and game type bar)
            filtersStackView.topAnchor.constraint(equalTo: navigationBarView.bottomAnchor, constant: 4),
            filtersStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            filtersStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),

            // Individual filter bar heights
            pillSelectorBarViewContainer.heightAnchor.constraint(equalToConstant: 62),
            pillSelectorBarView.heightAnchor.constraint(equalToConstant: 40),
            pillSelectorBarView.centerYAnchor.constraint(equalTo: pillSelectorBarViewContainer.centerYAnchor),
            pillSelectorBarView.leadingAnchor.constraint(equalTo: pillSelectorBarViewContainer.leadingAnchor),
            pillSelectorBarView.trailingAnchor.constraint(equalTo: pillSelectorBarViewContainer.trailingAnchor),
                        
            // Game type filter bar container with custom spacing
            gameTypeFilterBarContainer.heightAnchor.constraint(equalToConstant: 46),
            gameTypeFilterBar.leadingAnchor.constraint(equalTo: gameTypeFilterBarContainer.leadingAnchor, constant: 12),
            gameTypeFilterBar.trailingAnchor.constraint(equalTo: gameTypeFilterBarContainer.trailingAnchor, constant: -12),
            gameTypeFilterBar.bottomAnchor.constraint(equalTo: gameTypeFilterBarContainer.bottomAnchor),
            gameTypeFilterBar.heightAnchor.constraint(equalToConstant: 32),

            // Table View (now connected to filters stack)
            tableView.topAnchor.constraint(equalTo: filtersStackView.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Loading View (centered within tableView content area)
            loadingView.topAnchor.constraint(equalTo: tableView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),

            // Error View
            errorView.topAnchor.constraint(equalTo: navigationBarView.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(displayState: displayState)
            }
            .store(in: &cancellables)
    }

    // MARK: - Rendering

    private func render(displayState: TransactionHistoryDisplayState) {
        // Update loading state
        loadingView.isHidden = !displayState.isLoading
        tableView.refreshControl?.endRefreshing()

        // Update error state
        errorView.isHidden = displayState.error == nil

        // Update main content
        let hasError = displayState.error != nil
        navigationBarView.isHidden = hasError
        filtersStackView.isHidden = hasError  // Keep filters visible during loading
        tableView.isHidden = hasError  // Keep tableView visible during loading (shows header)

        // Show/hide game type bar based on selected category (Level 1 filter only visible when Games is selected)
        let shouldShowGameTypeBar = displayState.selectedCategory == .games
        gameTypeFilterBarContainer.isHidden = !shouldShowGameTypeBar

        // Update transactions and table
        currentTransactions = displayState.filteredTransactions
        tableView.reloadData()

        // Update time filter bar selection
        let selectedId = mapFromTransactionDateFilter(displayState.selectedDateFilter)
        timeFilterBar.setSelected(selectedId)

        // Update error message if present
        if let error = displayState.error {
            updateErrorView(with: error)
        }
    }

    private func updateErrorView(with errorMessage: String) {
        if let label = errorView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.text = errorMessage
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        viewModel.refreshData()
    }

    @objc private func didTapRetry() {
        viewModel.refreshData()
    }

    // MARK: - Filter Mapping

    private func mapToTransactionDateFilter(_ filterId: String) -> TransactionDateFilter {
        switch filterId {
        case "all": return .all
        case "1d": return .oneDay
        case "1w": return .oneWeek
        case "1m": return .oneMonth
        case "3m": return .threeMonths
        default: return .all
        }
    }

    private func mapFromTransactionDateFilter(_ filter: TransactionDateFilter) -> String {
        switch filter {
        case .all: return "all"
        case .oneDay: return "1d"
        case .oneWeek: return "1w"
        case .oneMonth: return "1m"
        case .threeMonths: return "3m"
        }
    }
}

// MARK: - UITableViewDataSource

extension TransactionHistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentTransactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionItemTableViewCell.identifier, for: indexPath) as? TransactionItemTableViewCell else {
            return UITableViewCell()
        }

        let transaction = currentTransactions[indexPath.row]
        let viewModel = TransactionItemViewModel.from(transactionHistoryItem: transaction)

        // Determine if it's first or last cell for corner radius
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == currentTransactions.count - 1

        if isFirstCell && isLastCell {
            cell.configure(with: viewModel, cornerRadiusStyle: .all)
        }
        else if isFirstCell {
            cell.configure(with: viewModel, cornerRadiusStyle: .topOnly)
        }
        else if isLastCell {
            cell.configure(with: viewModel, cornerRadiusStyle: .bottomOnly)
        }
        else {
            cell.configure(with: viewModel, cornerRadiusStyle: .none)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TransactionHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Handle transaction selection
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.App.backgroundPrimary
        containerView.addSubview(timeFilterBar)

        NSLayoutConstraint.activate([
            timeFilterBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            timeFilterBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            timeFilterBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
        ])
        
        containerView.layer.cornerRadius = 8
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.clipsToBounds = true
        
        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 62
    }
}

// MARK: - Factory Methods

extension TransactionHistoryViewController {

    private static func createLoadingView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.color = StyleProvider.Color.textSecondary

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("loading_transactions")
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.textColor = StyleProvider.Color.textSecondary

        view.addSubview(spinner)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16)
        ])

        return view
    }

    private static func createErrorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        view.isHidden = true

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("failed_load_transactions")
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0

        let retryButton = UIButton(type: .system)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle(localized("try_again"), for: .normal)
        retryButton.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        retryButton.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 16)
        retryButton.backgroundColor = StyleProvider.Color.buttonBackgroundSecondary
        retryButton.layer.cornerRadius = 8
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)

        view.addSubview(label)
        view.addSubview(retryButton)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),

            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 24)
        ])

        return view
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Transaction History - Populated") {
    PreviewUIViewController {
        let viewModel = MockTransactionHistoryViewModel.defaultMock
        return TransactionHistoryViewController(viewModel: viewModel)
    }
}

@available(iOS 17.0, *)
#Preview("Transaction History - Loading") {
    PreviewUIViewController {
        let viewModel = MockTransactionHistoryViewModel.loadingMock
        return TransactionHistoryViewController(viewModel: viewModel)
    }
}

@available(iOS 17.0, *)
#Preview("Transaction History - Error") {
    PreviewUIViewController {
        let viewModel = MockTransactionHistoryViewModel.errorMock
        return TransactionHistoryViewController(viewModel: viewModel)
    }
}

@available(iOS 17.0, *)
#Preview("Transaction History - Empty") {
    PreviewUIViewController {
        let viewModel = MockTransactionHistoryViewModel.emptyMock
        return TransactionHistoryViewController(viewModel: viewModel)
    }
}

#endif
