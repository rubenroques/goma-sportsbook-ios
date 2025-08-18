//
//  VirtualBetslipViewController.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import UIKit
import Combine

class VirtualBetslipViewController: UIViewController {
    
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
    
    // Button bar view (Booking Code + Clear Betslip)
    private lazy var buttonBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
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
    
    // Separator line
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundGradient2
        return view
    }()
    
    // Empty state view
    private lazy var emptyStateView: EmptyStateActionView = {
        let view = EmptyStateActionView(viewModel: viewModel.emptyStateViewModel)
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
        tableView.register(BetslipTicketTableViewCell.self, forCellReuseIdentifier: "BetslipTicketCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    // Bet info submission view
    private lazy var betInfoSubmissionView: BetInfoSubmissionView = {
        let view = BetInfoSubmissionView(viewModel: viewModel.betInfoSubmissionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    init(viewModel: BetslipViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        setupBindings()
        updateUI()
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        view.addSubview(containerView)
        
        containerView.addSubview(buttonBarView)
        containerView.addSubview(emptyStateView)
        containerView.addSubview(ticketsTableView)
        containerView.addSubview(betInfoSubmissionView)
        
        buttonBarView.addSubview(bookingCodeButton)
        buttonBarView.addSubview(clearBetslipButton)
        buttonBarView.addSubview(separatorLine)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Button bar view
            buttonBarView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
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
            
            // Separator line
            separatorLine.topAnchor.constraint(equalTo: buttonBarView.topAnchor, constant: 8),
            separatorLine.bottomAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: -8),
            separatorLine.leadingAnchor.constraint(equalTo: bookingCodeButton.trailingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: clearBetslipButton.leadingAnchor, constant: -16),
            separatorLine.widthAnchor.constraint(equalToConstant: 1),
            
            // Empty state view (initially hidden)
            emptyStateView.topAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: 8),
            emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: betInfoSubmissionView.topAnchor),
            
            // Tickets table view
            ticketsTableView.topAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: 8),
            ticketsTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            ticketsTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ticketsTableView.bottomAnchor.constraint(equalTo: betInfoSubmissionView.topAnchor),
            
            // Bet info submission view
            betInfoSubmissionView.topAnchor.constraint(greaterThanOrEqualTo: ticketsTableView.bottomAnchor, constant: 50),
            betInfoSubmissionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            betInfoSubmissionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            betInfoSubmissionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // Subscribe to tickets updates
        viewModel.ticketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.updateUI()
            }
            .store(in: &cancellables)
        
        // Setup button callbacks
        viewModel.clearBetslipButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleClearBetslipTapped()
        }
        
        viewModel.bookingCodeButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleBookingCodeTapped()
        }
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        let hasTickets = !viewModel.currentData.tickets.isEmpty
        
        // Show/hide appropriate views
        emptyStateView.isHidden = hasTickets
        ticketsTableView.isHidden = !hasTickets
        
        // Reload table if needed
        if hasTickets {
            ticketsTableView.reloadData()
        }
    }
    
    private func handleClearBetslipTapped() {
        viewModel.clearAllTickets()
    }
    
    private func handleBookingCodeTapped() {
        // TODO: Implement booking code functionality
        print("Booking code button tapped - functionality to be implemented")
    }
}

// MARK: - UITableViewDataSource
extension VirtualBetslipViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentData.tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BetslipTicketCell", for: indexPath) as? BetslipTicketTableViewCell else {
            return UITableViewCell()
        }
        
        let ticket = viewModel.currentData.tickets[indexPath.row]
        let ticketViewModel = MockBetslipTicketViewModel.skeletonMock()
        
        cell.configure(with: ticketViewModel, ticket: ticket)
        cell.onTicketRemoved = { [weak self] in
            self?.viewModel.removeTicket(ticket)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension VirtualBetslipViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let ticketCell = cell as? BetslipTicketTableViewCell {
            ticketCell.willDisplay()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let ticketCell = cell as? BetslipTicketTableViewCell {
            ticketCell.didEndDisplaying()
        }
    }
} 