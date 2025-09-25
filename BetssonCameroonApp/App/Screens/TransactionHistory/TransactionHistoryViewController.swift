//
//  TransactionHistoryViewController.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
//

import UIKit
import Combine
import GomaUI
import ServicesProvider

final class TransactionHistoryViewController: UIViewController {

    // MARK: - Private Properties

    private let viewModel: TransactionHistoryViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var customNavigationView: UIView = Self.createCustomNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()

    private lazy var pillSelectorBarView: PillSelectorBarView = {
        let view = PillSelectorBarView(viewModel: viewModel.transactionTypePillSelectorViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var timeFilterHeaderView: UIView = Self.createTimeFilterHeaderView()
    private lazy var timeFilterButtons: [UIButton] = Self.createTimeFilterButtons()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.App.backgroundPrimary
        tableView.separatorStyle = .none

        tableView.dataSource = self
        tableView.delegate = self

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

    init(viewModel: TransactionHistoryViewModel) {
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
        setupActions()

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
        view.backgroundColor = UIColor.App.backgroundPrimary

        setupViewHierarchy()
        setupConstraints()
    }

    private func setupViewHierarchy() {
        view.addSubview(customNavigationView)
        view.addSubview(pillSelectorBarView)
        view.addSubview(timeFilterHeaderView)
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(errorView)

        customNavigationView.addSubview(titleLabel)
        customNavigationView.addSubview(backButton)

        // Add time filter buttons to header
        for button in timeFilterButtons {
            timeFilterHeaderView.addSubview(button)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Custom Navigation View
            customNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationView.heightAnchor.constraint(equalToConstant: 56),

            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: customNavigationView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),

            // Back Button
            backButton.leadingAnchor.constraint(equalTo: customNavigationView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            backButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            // Pill Selector Bar
            pillSelectorBarView.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor, constant: 16),
            pillSelectorBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pillSelectorBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pillSelectorBarView.heightAnchor.constraint(equalToConstant: 44),

            // Time Filter Header
            timeFilterHeaderView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor, constant: 16),
            timeFilterHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeFilterHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timeFilterHeaderView.heightAnchor.constraint(equalToConstant: 44),

            // Table View
            tableView.topAnchor.constraint(equalTo: timeFilterHeaderView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Loading View
            loadingView.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Error View
            errorView.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Time filter buttons constraints - create a horizontal stack
        let buttonSpacing: CGFloat = 16
        let buttonWidth: CGFloat = 60

        if timeFilterButtons.count > 0 {
            // Center the first button
            let centerButton = timeFilterButtons[2] // "1W" is in the middle (index 2 of 5)
            NSLayoutConstraint.activate([
                centerButton.centerXAnchor.constraint(equalTo: timeFilterHeaderView.centerXAnchor),
                centerButton.centerYAnchor.constraint(equalTo: timeFilterHeaderView.centerYAnchor),
                centerButton.widthAnchor.constraint(equalToConstant: buttonWidth),
                centerButton.heightAnchor.constraint(equalToConstant: 32)
            ])

            // Position remaining buttons relative to center
            for (index, button) in timeFilterButtons.enumerated() {
                if index != 2 { // Skip the center button
                    let offsetFromCenter = (index - 2) // -2, -1, 0, 1, 2 becomes -2, -1, skip, 1, 2
                    NSLayoutConstraint.activate([
                        button.centerXAnchor.constraint(equalTo: centerButton.centerXAnchor, constant: CGFloat(offsetFromCenter) * (buttonWidth + buttonSpacing)),
                        button.centerYAnchor.constraint(equalTo: timeFilterHeaderView.centerYAnchor),
                        button.widthAnchor.constraint(equalToConstant: buttonWidth),
                        button.heightAnchor.constraint(equalToConstant: 32)
                    ])
                }
            }
        }
    }

    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(displayState: displayState)
            }
            .store(in: &cancellables)
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        // Time filter buttons actions
        timeFilterButtons[0].addTarget(self, action: #selector(didTapAllTimeFilter), for: .touchUpInside)
        timeFilterButtons[1].addTarget(self, action: #selector(didTapOneDayFilter), for: .touchUpInside)
        timeFilterButtons[2].addTarget(self, action: #selector(didTapOneWeekFilter), for: .touchUpInside)
        timeFilterButtons[3].addTarget(self, action: #selector(didTapOneMonthFilter), for: .touchUpInside)
        timeFilterButtons[4].addTarget(self, action: #selector(didTapThreeMonthsFilter), for: .touchUpInside)
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
        customNavigationView.isHidden = hasError  // Keep navigation visible during loading
        pillSelectorBarView.isHidden = displayState.isLoading || hasError
        timeFilterHeaderView.isHidden = displayState.isLoading || hasError
        tableView.isHidden = displayState.isLoading || hasError

        // Update transactions and table
        currentTransactions = displayState.filteredTransactions
        tableView.reloadData()

        // Update time filter button states
        updateTimeFilterButtons(selectedFilter: displayState.selectedDateFilter)

        // Update error message if present
        if let error = displayState.error {
            updateErrorView(with: error)
        }
    }

    private func updateTimeFilterButtons(selectedFilter: TransactionDateFilter) {
        let filters: [TransactionDateFilter] = [.all, .oneDay, .oneWeek, .oneMonth, .threeMonths]

        for (index, button) in timeFilterButtons.enumerated() {
            let isSelected = filters[index] == selectedFilter
            button.backgroundColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.buttonBackgroundSecondary
            button.setTitleColor(isSelected ? UIColor.white : StyleProvider.Color.textPrimary, for: .normal)
        }
    }

    private func updateErrorView(with errorMessage: String) {
        if let label = errorView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.text = errorMessage
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        viewModel.didTapBack()
    }

    @objc private func handleRefresh() {
        viewModel.refreshData()
    }

    @objc private func didTapAllTimeFilter() {
        viewModel.selectDateFilter(.all)
    }

    @objc private func didTapOneDayFilter() {
        viewModel.selectDateFilter(.oneDay)
    }

    @objc private func didTapOneWeekFilter() {
        viewModel.selectDateFilter(.oneWeek)
    }

    @objc private func didTapOneMonthFilter() {
        viewModel.selectDateFilter(.oneMonth)
    }

    @objc private func didTapThreeMonthsFilter() {
        viewModel.selectDateFilter(.threeMonths)
    }

    @objc private func didTapRetry() {
        viewModel.refreshData()
    }
}

// MARK: - UITableViewDataSource

extension TransactionHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTransactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionItemTableViewCell.identifier, for: indexPath) as? TransactionItemTableViewCell else {
            return UITableViewCell()
        }

        let transaction = currentTransactions[indexPath.row]
        let viewModel = TransactionItemViewModel.from(transactionHistoryItem: transaction, balance: getBalanceForTransaction(transaction))

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

    private func getBalanceForTransaction(_ transaction: TransactionHistoryItem) -> Double {
        // For now, return a placeholder balance. In the future, this could be calculated
        // based on the actual balance at the time of the transaction
        return 18.29 // Placeholder based on the design
    }
}

// MARK: - UITableViewDelegate

extension TransactionHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Handle transaction selection
    }
}

// MARK: - Factory Methods

extension TransactionHistoryViewController {

    private static func createCustomNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary

        // Add bottom separator line
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = StyleProvider.Color.separatorLine

        view.addSubview(separatorView)

        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])

        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Transaction History"
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        // Use standard iOS back arrow icon
        let backImage = UIImage(systemName: "chevron.left")
        button.setImage(backImage, for: .normal)
        button.tintColor = StyleProvider.Color.highlightPrimary

        return button
    }

    private static func createTimeFilterHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundSecondary

        // Add top and bottom separator lines
        let topSeparator = UIView()
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        topSeparator.backgroundColor = StyleProvider.Color.separatorLine

        let bottomSeparator = UIView()
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.backgroundColor = StyleProvider.Color.separatorLine

        view.addSubview(topSeparator)
        view.addSubview(bottomSeparator)

        NSLayoutConstraint.activate([
            topSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSeparator.topAnchor.constraint(equalTo: view.topAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 1),

            bottomSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSeparator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])

        return view
    }

    private static func createTimeFilterButtons() -> [UIButton] {
        let titles = ["All", "1D", "1W", "1M", "3M"]

        return titles.map { title in
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 14)
            button.backgroundColor = StyleProvider.Color.buttonBackgroundSecondary
            button.layer.cornerRadius = 16
            button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
            return button
        }
    }

    private static func createLoadingView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        view.isHidden = true

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.color = StyleProvider.Color.textSecondary

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading transactions..."
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
        label.text = "Failed to load transactions"
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0

        let retryButton = UIButton(type: .system)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Try Again", for: .normal)
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
