//
//  SportsBetslipViewController.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import UIKit
import Combine
import GomaUI

class SportsBetslipViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: SportsBetslipViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
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
        button.isHidden = true 
        return button
    }()
    
    // Clear Betslip button
    private lazy var clearBetslipButton: ButtonIconView = {
        let button = ButtonIconView(viewModel: viewModel.clearBetslipButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    // Loading view overlay
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    private lazy var loadingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        return indicator
    }()
    
    // MARK: - Initialization
    init(viewModel: SportsBetslipViewModelProtocol) {
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
        view.addSubview(buttonBarView)
        view.addSubview(emptyStateView)
        view.addSubview(ticketsTableView)
        view.addSubview(betInfoSubmissionView)
        
        // Add loading view on top of everything
        view.addSubview(loadingView)
        loadingView.addSubview(loadingActivityIndicator)
        
        buttonBarView.addSubview(bookingCodeButton)
        buttonBarView.addSubview(clearBetslipButton)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            // Button bar view - top of the view with content inset
            buttonBarView.topAnchor.constraint(equalTo: view.topAnchor),
            buttonBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonBarView.heightAnchor.constraint(equalToConstant: 50),
            
            // Booking Code button
            bookingCodeButton.topAnchor.constraint(equalTo: buttonBarView.topAnchor, constant: 8),
            bookingCodeButton.leadingAnchor.constraint(equalTo: buttonBarView.leadingAnchor, constant: 16),
            bookingCodeButton.bottomAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: -8),
            
            // Clear Betslip button
            clearBetslipButton.topAnchor.constraint(equalTo: buttonBarView.topAnchor, constant: 8),
            clearBetslipButton.trailingAnchor.constraint(equalTo: buttonBarView.trailingAnchor, constant: -16),
            clearBetslipButton.bottomAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: -8),
            
            // Empty state view - fill remaining space above bet info submission
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Tickets table view - fill remaining space above bet info submission
            ticketsTableView.topAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: 8),
            ticketsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ticketsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ticketsTableView.bottomAnchor.constraint(equalTo: betInfoSubmissionView.topAnchor, constant: -8),
            
            // Bet info submission view - bottom of the view
            betInfoSubmissionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            betInfoSubmissionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            betInfoSubmissionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Loading view constraints - covers the entire view
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Center the activity indicator
            loadingActivityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingActivityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
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
        
        viewModel.betslipLoggedState = { [weak self] betslipLoggedState in
            switch betslipLoggedState {
            case .noTicketsLoggedOut:
                self?.betInfoSubmissionView.isHidden = true
            case .ticketsLoggedOut:
                self?.betInfoSubmissionView.isHidden = true
            case .noTicketsLoggedIn:
                self?.betInfoSubmissionView.isHidden = false
            case .ticketsLoggedIn:
                self?.betInfoSubmissionView.isHidden = false
                
            }
        }
        
        // Setup loading state callback
        viewModel.isLoadingSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        let hasTickets = !viewModel.currentTickets.isEmpty
        
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
    
    // MARK: - Loading State Management
    private func showLoading() {
        loadingView.isHidden = false
        loadingActivityIndicator.startAnimating()
    }
    
    private func hideLoading() {
        loadingView.isHidden = true
        loadingActivityIndicator.stopAnimating()
    }
}

// MARK: - UITableViewDataSource
extension SportsBetslipViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentTickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BetslipTicketCell", for: indexPath) as? BetslipTicketTableViewCell else {
            return UITableViewCell()
        }
        
        let ticket = viewModel.currentTickets[indexPath.row]
        
        // Create a proper mock view model with the actual ticket data
        let ticketViewModel = MockBetslipTicketViewModel(
            leagueName: ticket.competition ?? "Unknown League",
            startDate: ticket.date?.formatted() ?? "Unknown Date",
            homeTeam: ticket.homeParticipantName ?? "Home Team",
            awayTeam: ticket.awayParticipantName ?? "Away Team",
            selectedTeam: ticket.outcomeDescription,
            oddsValue: String(format: "%.2f", ticket.decimalOdd),
            oddsChangeState: .none
        )
        
        cell.configure(with: ticketViewModel)
        
        cell.onTicketRemoved = { [weak self] in
            self?.viewModel.removeTicket(ticket)
        }
        
        return cell
    }
}
