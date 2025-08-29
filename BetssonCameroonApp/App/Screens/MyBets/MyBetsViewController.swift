
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
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.App.backgroundPrimary
        tableView.separatorStyle = .none
        
        // ⭐ KEY: Automatic dynamic height - no complex sizing needed!
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
    
    // MARK: - Data Source
    
    private var ticketViewModels: [TicketBetInfoViewModelProtocol] = []
    
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
        
        // Listen to ticket view models changes
        viewModel.ticketBetInfoViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModels in
                self?.ticketViewModels = viewModels
                self?.updateTableView()
                print("🎯 MyBetsViewController: Updated with \(viewModels.count) ticket view models")
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
            if bets.isEmpty {
                showEmptyState()
            } else {
                showTableViewState()
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
    
    private func updateTableView() {
        // ⭐ SIMPLE: UITableView handles dynamic sizing automatically!
        tableView.reloadData()
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
        
        return cell
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
