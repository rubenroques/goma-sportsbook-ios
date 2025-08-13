import Foundation
import UIKit
import Combine
import GomaUI

/// A view controller for the betslip screen with header and bet submission
public final class BetslipViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: BetslipViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return view
    }()
    
    // Header view
    private lazy var headerView: BetslipHeaderView = {
        let headerView = BetslipHeaderView(viewModel: viewModel.headerViewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    // Empty state wrapper view
    private lazy var emptyStateView: EmptyStateView = {
        let emptyStateView = EmptyStateView(viewModel: viewModel.emptyStateViewModel)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        return emptyStateView
    }()
    
    // Bet info submission view
    private lazy var betInfoSubmissionView: BetInfoSubmissionView = {
        let view = BetInfoSubmissionView(viewModel: viewModel.betInfoSubmissionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Tickets table view
    private lazy var ticketsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BetslipTicketTableViewCell.self, forCellReuseIdentifier: BetslipTicketTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    // MARK: - Initialization
    public init(viewModel: BetslipViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        view.addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(emptyStateView)
        containerView.addSubview(betInfoSubmissionView)
        containerView.addSubview(ticketsTableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Header view
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Empty state view (initially hidden)
            emptyStateView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: betInfoSubmissionView.topAnchor),
            
            // Tickets table view
            ticketsTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            ticketsTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            ticketsTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ticketsTableView.bottomAnchor.constraint(equalTo: betInfoSubmissionView.topAnchor),
            
            // Bet info submission view
            betInfoSubmissionView.topAnchor.constraint(greaterThanOrEqualTo: headerView.bottomAnchor, constant: 50),
            betInfoSubmissionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            betInfoSubmissionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            betInfoSubmissionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(data: BetslipData) {
        // Update view state
        view.alpha = data.isEnabled ? 1.0 : 0.5
        
        // Show/hide views based on ticket state
        if data.tickets.isEmpty {
            // Show empty state, hide tickets table
            emptyStateView.isHidden = false
            ticketsTableView.isHidden = true
        } else {
            // Show tickets table, hide empty state
            emptyStateView.isHidden = true
            ticketsTableView.isHidden = false
        }
        
        ticketsTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension BetslipViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentData.tickets.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BetslipTicketTableViewCell.reuseIdentifier, for: indexPath) as? BetslipTicketTableViewCell else {
            return UITableViewCell()
        }
        
        // Get the actual ticket data from the view model
        let tickets = viewModel.currentData.tickets
        guard indexPath.row < tickets.count else {
            return cell
        }
        
        let ticket = tickets[indexPath.row]
        
        // Create a new view model with the actual ticket data
        let ticketViewModel = MockBetslipTicketViewModel(
            leagueName: ticket.competition ?? "Unknown League",
            startDate: ticket.date?.formatted() ?? "Unknown Date",
            homeTeam: ticket.homeParticipantName ?? "Home Team",
            awayTeam: ticket.awayParticipantName ?? "Away Team",
            selectedTeam: ticket.outcomeDescription,
            oddsValue: String(format: "%.2f", ticket.decimalOdd),
            oddsChangeState: .none
        )
        
        // Configure the cell with the new view model
        cell.configure(with: ticketViewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BetslipViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - EmptyStateView Wrapper
private final class EmptyStateView: UIView {
    
    // MARK: - Properties
    private let viewModel: EmptyStateActionViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        return view
    }()
    
    // Empty state action view
    private lazy var emptyStateActionView: EmptyStateActionView = {
        let emptyStateView = EmptyStateActionView(viewModel: viewModel)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        return emptyStateView
    }()
    
    // MARK: - Initialization
    init(viewModel: EmptyStateActionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(emptyStateActionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Empty state action view
            emptyStateActionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            emptyStateActionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emptyStateActionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(data: EmptyStateActionData) {
        // The EmptyStateActionView handles its own rendering
        // This wrapper just provides the container and layout
    }
} 
