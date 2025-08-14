import Foundation
import UIKit
import Combine
import GomaUI

/// A view controller for the betslip screen with header and bet submission
public final class BetslipViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: BetslipViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        return view
    }()
    
    // Header view
    private lazy var headerView: BetslipHeaderView = {
        let headerView = BetslipHeaderView(viewModel: viewModel.headerViewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    // Button bar view (Booking Code + Clear Betslip)
    private lazy var buttonBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        return view
    }()
    
    // Booking Code button
    private lazy var bookingCodeButton: ButtonIconView = {
        let button = ButtonIconView(viewModel: viewModel.bookingCodeButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Hidden for now as requested
        return button
    }()
    
    // Clear Betslip button
    private lazy var clearBetslipButton: ButtonIconView = {
        let button = ButtonIconView(viewModel: viewModel.clearBetslipButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.addSubview(containerView)
        
        containerView.addSubview(headerView)
        containerView.addSubview(buttonBarView)
        containerView.addSubview(emptyStateView)
        containerView.addSubview(ticketsTableView)
        containerView.addSubview(betInfoSubmissionView)
        
        // Add buttons to button bar
        buttonBarView.addSubview(bookingCodeButton)
        buttonBarView.addSubview(clearBetslipButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Header view
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),
            
            // Button bar view
            buttonBarView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            buttonBarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonBarView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            buttonBarView.heightAnchor.constraint(equalToConstant: 50),
            
            // Booking Code button
            bookingCodeButton.topAnchor.constraint(equalTo: buttonBarView.topAnchor, constant: 8),
            bookingCodeButton.leadingAnchor.constraint(equalTo: buttonBarView.leadingAnchor, constant: 16),
            bookingCodeButton.bottomAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: -8),
            
            // Clear Betslip button
            clearBetslipButton.topAnchor.constraint(equalTo: buttonBarView.topAnchor, constant: 8),
            clearBetslipButton.trailingAnchor.constraint(equalTo: buttonBarView.trailingAnchor, constant: -16),
            clearBetslipButton.bottomAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: -8),
            
            // Empty state view (initially hidden)
            emptyStateView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: betInfoSubmissionView.topAnchor),
            
            // Tickets table view
            ticketsTableView.topAnchor.constraint(equalTo: buttonBarView.bottomAnchor),
            ticketsTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            ticketsTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ticketsTableView.bottomAnchor.constraint(equalTo: betInfoSubmissionView.topAnchor),
            
            // Bet info submission view
            betInfoSubmissionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            betInfoSubmissionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            betInfoSubmissionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // Bind to view model data
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
        
        // Wire up button actions from view models
        viewModel.clearBetslipButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleClearBetslipTapped()
        }
        
        viewModel.bookingCodeButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleBookingCodeTapped()
        }
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
            
            // Update existing cells if possible, only reload if necessary
            let currentCount = ticketsTableView.numberOfRows(inSection: 0)
            if currentCount == data.tickets.count {
                // Update existing cells
                for (index, ticket) in data.tickets.enumerated() {
                    let indexPath = IndexPath(row: index, section: 0)
                    updateTicketCell(at: indexPath, with: ticket)
                }
            } else {
                // Reload only if count changed
                ticketsTableView.reloadData()
            }
        }
        
        // betInfoSubmissionView is always visible
    }
    
    private func removeTicket(_ ticket: BettingTicket) {
        viewModel.removeTicket(ticket)
    }
    
    private func handleClearBetslipTapped() {
        // Clear all tickets from the betslip
        viewModel.clearAllTickets()
    }
    
    private func handleBookingCodeTapped() {
        // TODO: Implement booking code functionality
        print("Booking code button tapped - functionality to be implemented")
    }
    
    private func updateTicketCell(at indexPath: IndexPath, with ticket: BettingTicket) {
        guard let cell = ticketsTableView.cellForRow(at: indexPath) as? BetslipTicketTableViewCell else { return }
        
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
        
        // Configure the cell with the new view model and ticket
        cell.onTicketRemoved = { [weak self] removedTicket in
            self?.removeTicket(removedTicket)
        }
        cell.configure(with: ticketViewModel, ticket: ticket)
    }
    
    private func setupTableView() {
        ticketsTableView.delegate = self
        ticketsTableView.dataSource = self
        ticketsTableView.register(BetslipTicketTableViewCell.self, forCellReuseIdentifier: BetslipTicketTableViewCell.reuseIdentifier)
        
        // Configure table view for dynamic heights
        ticketsTableView.rowHeight = UITableView.automaticDimension
        ticketsTableView.estimatedRowHeight = 120
        
        // Ensure proper content sizing
        ticketsTableView.setContentHuggingPriority(.required, for: .vertical)
        ticketsTableView.setContentCompressionResistancePriority(.required, for: .vertical)
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
        
        // Configure the cell with the new view model and ticket
        cell.onTicketRemoved = { [weak self] removedTicket in
            self?.removeTicket(removedTicket)
        }
        
        cell.configure(with: ticketViewModel, ticket: ticket)
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
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        // Force the cell to maintain its height
        if let ticketCell = cell as? BetslipTicketTableViewCell {
            ticketCell.invalidateIntrinsicContentSize()
        }
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
