
import UIKit
import Combine
import GomaUI

class MyBetsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MyBetsViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentBets: [MyBet] = []
    
    // MARK: - UI Components
    
    private lazy var pillSelectorBarView: PillSelectorBarView = {
        let view = PillSelectorBarView(viewModel: viewModel.pillSelectorBarViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var marketGroupSelectorTabView: MarketGroupSelectorTabView = {
        let view = MarketGroupSelectorTabView(
            viewModel: viewModel.marketGroupSelectorTabViewModel,
            backgroundStyle: .light
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .systemBackground
        table.separatorStyle = .singleLine
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        table.register(BasicBetTableViewCell.self, forCellReuseIdentifier: "BasicBetCell")
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        table.refreshControl = refreshControl
        
        return table
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
        label.text = "Loading bets..."
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
        label.text = "Failed to load bets"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemRed
        label.numberOfLines = 0
        
        let retryButton = UIButton(type: .system)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Retry", for: .normal)
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
        label.text = "No bets found"
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
    
    // MARK: - Navigation Closures
    
    var onLoginRequested: (() -> Void)?
    
    // MARK: - Initialization
    
    init(viewModel: MyBetsViewModelProtocol) {
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
    }
    
    // MARK: - Public Methods
    
    func refreshData() {
        // Reserved for future implementation
    }
    
    // MARK: - Private Methods
    
    @objc private func handleRefresh() {
        viewModel.refreshBets()
    }
    
    @objc private func handleRetry() {
        viewModel.refreshBets()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(marketGroupSelectorTabView)
        view.addSubview(pillSelectorBarView)
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        view.addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            marketGroupSelectorTabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            marketGroupSelectorTabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            marketGroupSelectorTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            marketGroupSelectorTabView.heightAnchor.constraint(equalToConstant: 42),
            
            pillSelectorBarView.topAnchor.constraint(equalTo: marketGroupSelectorTabView.bottomAnchor),
            pillSelectorBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pillSelectorBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pillSelectorBarView.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            errorView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Initially show loading
        showLoadingState()
    }
    
    private func setupBindings() {
        // Listen to data state changes
        viewModel.betsStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleBetsStateChange(state)
            }
            .store(in: &cancellables)
        
        // Listen to loading changes
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        // Listen to tab changes
        viewModel.selectedTabTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedTab in
                print("🎯 MyBets: Selected tab changed to \(selectedTab.title)")
            }
            .store(in: &cancellables)
        
        // Listen to status changes  
        viewModel.selectedStatusTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedStatus in
                print("🎯 MyBets: Selected status changed to \(selectedStatus.title)")
            }
            .store(in: &cancellables)
    }
    
    private func handleBetsStateChange(_ state: MyBetsState) {
        switch state {
        case .loading:
            showLoadingState()
        case .loaded(let bets):
            currentBets = bets
            if bets.isEmpty {
                showEmptyState()
            } else {
                showTableViewState()
                tableView.reloadData()
            }
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
}

// MARK: - UITableViewDataSource

extension MyBetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentBets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicBetCell", for: indexPath) as! BasicBetTableViewCell
        let bet = currentBets[indexPath.row]
        cell.configure(with: bet)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MyBetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load more data when approaching the end
        if indexPath.row == currentBets.count - 3 {
            viewModel.loadMoreBets()
        }
    }
}

// MARK: - Basic Bet Table View Cell

class BasicBetTableViewCell: UITableViewCell {
    
    private let betIdLabel = UILabel()
    private let statusLabel = UILabel()
    private let stakeLabel = UILabel()
    private let potentialWinLabel = UILabel()
    private let dateLabel = UILabel()
    private let selectionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        [betIdLabel, statusLabel, stakeLabel, potentialWinLabel, dateLabel, selectionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Configure labels
        betIdLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        betIdLabel.textColor = .label
        
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        statusLabel.textAlignment = .right
        statusLabel.layer.cornerRadius = 4
        statusLabel.layer.masksToBounds = true
        statusLabel.textAlignment = .center
        
        stakeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        stakeLabel.textColor = .label
        
        potentialWinLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        potentialWinLabel.textColor = .systemGreen
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        
        selectionLabel.font = UIFont.systemFont(ofSize: 13)
        selectionLabel.textColor = .secondaryLabel
        selectionLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            betIdLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            betIdLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),
            
            stakeLabel.topAnchor.constraint(equalTo: betIdLabel.bottomAnchor, constant: 8),
            stakeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            potentialWinLabel.topAnchor.constraint(equalTo: betIdLabel.bottomAnchor, constant: 8),
            potentialWinLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: stakeLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            selectionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            selectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            selectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            selectionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with bet: MyBet) {
        betIdLabel.text = "Bet #\(bet.identifier)"
        
        // Configure status badge
        statusLabel.text = bet.state.displayName.uppercased()
        
        let statusColor = colorFor(betState: bet.state)
        statusLabel.backgroundColor = statusColor.withAlphaComponent(0.1)
        statusLabel.textColor = statusColor
        
        // Configure amounts using helper classes
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = bet.currency
        
        let formattedStake = currencyFormatter.string(from: NSNumber(value: bet.stake)) ?? "\(bet.stake) \(bet.currency)"
        stakeLabel.text = "Stake: \(formattedStake)"
        
        if let potentialReturn = bet.potentialReturn {
            let formattedReturn = currencyFormatter.string(from: NSNumber(value: potentialReturn)) ?? "\(potentialReturn) \(bet.currency)"
            potentialWinLabel.text = "Win: \(formattedReturn)"
        } else {
            potentialWinLabel.text = ""
        }
        
        // Configure date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateLabel.text = "Placed: \(formatter.string(from: bet.date))"
        
        // Configure selections using MyBet's convenience property
        selectionLabel.text = bet.selectionsDescription
    }
    
    private func colorFor(betState: MyBetState) -> UIColor {
        switch betState {
        case .opened:
            return .systemBlue
        case .won:
            return .systemGreen
        case .lost:
            return .systemRed
        case .cancelled:
            return .systemOrange
        case .cashedOut:
            return .systemTeal
        case .settled:
            return .systemGreen
        case .closed:
            return .systemGray
        case .attempted:
            return .systemYellow
        case .void:
            return .systemOrange
        case .undefined:
            return .systemGray
        }
    }
}
