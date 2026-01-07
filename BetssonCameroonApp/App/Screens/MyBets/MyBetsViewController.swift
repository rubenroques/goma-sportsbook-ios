
import UIKit
import Combine
import GomaUI

class MyBetsViewController: UIViewController {
    
    // MARK: - Properties

    private let viewModel: MyBetsViewModel
    private var cancellables = Set<AnyCancellable>()
    private let tabBarHeight: CGFloat = 56 // Matches MainTabBarViewController.swift:940
    
    // MARK: - UI Components
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        return contentView
    }()
    
    private lazy var pillSelectorBarView: PillSelectorBarView = {
        let view = PillSelectorBarView(viewModel: viewModel.myBetsStatusBarViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - DISABLED: Sports/Virtuals Tab Bar (Virtuals Not Supported at Launch)
    // TODO: Re-enable when Virtuals support is implemented
    // Uncomment lines below and update pillSelectorBarView.topAnchor constraint
    /*
    private lazy var marketGroupSelectorTabView: MarketGroupSelectorTabView = {
        let view = MarketGroupSelectorTabView(
            viewModel: viewModel.myBetsTabBarViewModel,
            layoutMode: .stretch,
            imageResolver: MyBetsTabsImageResolver()
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    */
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.App.backgroundPrimary
        tableView.separatorStyle = .none
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 320
        
        // Register cell
        tableView.register(
            TicketBetInfoTableViewCell.self,
            forCellReuseIdentifier: TicketBetInfoTableViewCell.identifier
        )
        
        // Add pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        return tableView
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("mybets_loading_message")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        
        view.addSubview(spinner)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16)
        ])
        
        return view
    }()
    
    private lazy var errorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("mybets_error_load_failed")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemRed
        label.numberOfLines = 0

        let retryButton = UIButton(type: .system)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle(localized("retry"), for: .normal)
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        retryButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        
        view.addSubview(label)
        view.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16)
        ])
        
        return view
    }()
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("mybets_empty_state")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel

        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    // MARK: - Data Source
    
    private var ticketViewModels: [TicketBetInfoViewModel] = []
    
    // MARK: - Navigation Closures
    
    var onLoginRequested: (() -> Void)?
    
    // MARK: - Initialization
    
    init(viewModel: MyBetsViewModel) {
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
        setupTheme()
        setupBindings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewInsets()
    }

    // MARK: - Public Methods
    
    func refreshData() {
        self.handleRefresh()
    }
    
    // MARK: - Private Methods
    
    @objc private func handleRefresh() {
        viewModel.refreshBets()
    }
    
    @objc private func handleRetry() {
        viewModel.refreshBets()
    }

    private func updateTableViewInsets() {
        let safeAreaBottom = view.safeAreaInsets.bottom
        let bottomContentInset = tabBarHeight + safeAreaBottom
        let bottomIndicatorInset = bottomContentInset + 6 // +6pt for better visibility

        tableView.contentInset.bottom = bottomContentInset
        tableView.scrollIndicatorInsets.bottom = bottomIndicatorInset
    }

    private func setupTheme() {
        
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary
    }
    
    private func setupUI() {
        view.addSubview(contentView)

        // DISABLED: Sports/Virtuals tab bar (Virtuals not supported at launch)
        // contentView.addSubview(marketGroupSelectorTabView)
        contentView.addSubview(pillSelectorBarView)
        contentView.addSubview(tableView)
        contentView.addSubview(loadingView)
        contentView.addSubview(errorView)
        contentView.addSubview(emptyView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // DISABLED: Sports/Virtuals tab bar constraints (re-enable when Virtuals supported)
            /*
            marketGroupSelectorTabView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            marketGroupSelectorTabView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            marketGroupSelectorTabView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            marketGroupSelectorTabView.heightAnchor.constraint(equalToConstant: 42),
            */

            // PillSelectorBarView now snapped to top (was: marketGroupSelectorTabView.bottomAnchor)
            pillSelectorBarView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            pillSelectorBarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pillSelectorBarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pillSelectorBarView.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            errorView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emptyView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Initially show loading
        showLoadingState()
    }
    
    private func setupBindings() {
        // Listen to data state changes - this now handles everything
        viewModel.betsStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleBetsStateChange(state)
            }
            .store(in: &cancellables)

        // DISABLED: Sports/Virtuals tab selection binding (Virtuals not supported at launch)
        /*
        // Listen to tab changes
        viewModel.selectedTabTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedTab in
                print("🎯 MyBets: Selected tab changed to \(selectedTab.title)")
            }
            .store(in: &cancellables)
        */

        // Listen to status changes  
        viewModel.selectedStatusTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedStatus in
                print("🎯 MyBets: Selected status changed to \(selectedStatus.title)")
            }
            .store(in: &cancellables)
        
        // Setup rebet confirmation
        viewModel.onRequestRebetConfirmation = { [weak self] completion in
            self?.showRebetConfirmationAlert(completion: completion)
        }
        
        // Setup rebet all failed error
        viewModel.onShowRebetAllFailedError = { [weak self] in
            self?.showRebetAllFailedAlert()
        }

        // Setup cashout error handling
        viewModel.onShowCashoutError = { [weak self] message, retryAction, cancelAction in
            self?.showCashoutErrorAlert(message: message, retryAction: retryAction, cancelAction: cancelAction)
        }

        // Setup cashout confirmation
        viewModel.onShowCashoutConfirmation = { [weak self] isFullCashout, stake, value, remaining, currency, onConfirm in
            self?.showCashoutConfirmationAlert(
                isFullCashout: isFullCashout,
                stakeToCashOut: stake,
                cashoutValue: value,
                remainingStake: remaining,
                currency: currency,
                onConfirm: onConfirm
            )
        }
    }
    
    private func handleBetsStateChange(_ state: MyBetsState) {
        // End refresh control for all non-loading states
        if case .loading = state {
            // Keep refresh control spinning for loading
        } else {
            tableView.refreshControl?.endRefreshing()
        }
        
        switch state {
        case .loading:
            showLoadingState()
        case .loaded(let viewModels):
            // Update the data source and UI
            self.ticketViewModels = viewModels
            updateTableView()
            
            if viewModels.isEmpty {
                showEmptyState()
            } else {
                showTableViewState()
            }
            print("🎯 MyBetsViewController: Updated with \(viewModels.count) ticket view models")
        case .error(let message):
            showErrorState(message: message)
        }
    }
    
    private func showLoadingState() {
        tableView.isHidden = true
        loadingView.isHidden = false
        errorView.isHidden = true
        emptyView.isHidden = true
    }
    
    private func showTableViewState() {
        tableView.isHidden = false
        loadingView.isHidden = true
        errorView.isHidden = true
        emptyView.isHidden = true
    }
    
    private func showErrorState(message: String) {
        if let errorLabel = errorView.subviews.compactMap({ $0 as? UILabel }).first {
            errorLabel.text = message
        }
        tableView.isHidden = true
        loadingView.isHidden = true
        errorView.isHidden = false
        emptyView.isHidden = true
    }
    
    private func showEmptyState() {
        tableView.isHidden = true
        loadingView.isHidden = true
        errorView.isHidden = true
        emptyView.isHidden = false
    }
    
    private func updateTableView() {
        
        UIView.performWithoutAnimation {
            tableView.reloadData()
            tableView.layoutIfNeeded()
            tableView.setContentOffset(.zero, animated: false)
        }

    }
    
    private func updateTableViewCellLayout() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Alert Methods
    private func showRebetConfirmationAlert(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: localized("mybets_replace_betslip_title"),
            message: localized("mybets_replace_betslip_message"),
            preferredStyle: .alert
        )

        // Cancel action
        let cancelAction = UIAlertAction(title: localized("cancel"), style: .cancel) { _ in
            completion(false)
        }

        // Continue action
        let continueAction = UIAlertAction(title: localized("continue"), style: .default) { _ in
            completion(true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        
        present(alert, animated: true)
    }
    
    private func showRebetAllFailedAlert() {
        let alert = UIAlertController(
            title: localized("rebet_failed"),
            message: localized("rebet_failed_description"),
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: localized("ok"), style: .default)
        alert.addAction(okAction)

        present(alert, animated: true)
    }

    private func showCashoutErrorAlert(
        message: String,
        retryAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: localized("cashout_error"),
            message: message,
            preferredStyle: .alert
        )

        let cancel = UIAlertAction(title: localized("cancel"), style: .cancel) { _ in
            cancelAction()
        }

        let retry = UIAlertAction(title: localized("retry"), style: .default) { _ in
            retryAction()
        }

        alert.addAction(cancel)
        alert.addAction(retry)

        present(alert, animated: true)
    }

    private func showCashoutConfirmationAlert(
        isFullCashout: Bool,
        stakeToCashOut: Double,
        cashoutValue: Double,
        remainingStake: Double?,
        currency: String,
        onConfirm: @escaping () -> Void
    ) {
        let title = isFullCashout
            ? localized("confirm_full_cashout")
            : localized("confirm_partial_cashout")

        let description = isFullCashout
            ? localized("you_are_about_to_cash_out_your_entire_bet")
            : localized("you_are_about_to_cash_out_part_of_your_bet")

        let stakeLabel = localized("stake_to_cash_out")
        let receiveLabel = localized("you_will_receive")
        let stakeFormatted = CurrencyHelper.formatAmountWithCurrency(stakeToCashOut, currency: currency)
        let valueFormatted = CurrencyHelper.formatAmountWithCurrency(cashoutValue, currency: currency)

        var message = "\(description)\n\n\(stakeLabel): \(stakeFormatted)\n\(receiveLabel): \(valueFormatted)"

        if !isFullCashout, let remaining = remainingStake {
            let remainingLabel = localized("remaining_stake")
            let remainingFormatted = CurrencyHelper.formatAmountWithCurrency(remaining, currency: currency)
            message += "\n\(remainingLabel): \(remainingFormatted)"
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: localized("confirm"), style: .default) { _ in
            onConfirm()
        })

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MyBetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TicketBetInfoTableViewCell.identifier,
            for: indexPath
        ) as! TicketBetInfoTableViewCell
        
        let viewModel = ticketViewModels[indexPath.row]
        
        // Configure cell position for corner radius
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == ticketViewModels.count - 1
        let isOnlyCell = ticketViewModels.count == 1
        
        cell.configure(with: viewModel)
        cell.configureCellPosition(isFirst: isFirst, isLast: isLast, isOnlyCell: isOnlyCell)
        
        cell.updateLayout = { [weak self] in
            self?.updateTableViewCellLayout()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate

extension MyBetsViewController: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load more data when approaching the end
        if indexPath.row == ticketViewModels.count - 3 {
            self.viewModel.loadMoreBets()
        }
    }
}
