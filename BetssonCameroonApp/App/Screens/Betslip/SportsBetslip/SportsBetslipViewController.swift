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

    // Top section stack (button bar + odds boost header only)
    private lazy var topSectionStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = true  // Frame-based sizing for tableHeaderView
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    // Odds boost header container (with padding)
    private lazy var oddsBoostHeaderContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        container.isHidden = true // Initially hidden
        return container
    }()

    // Odds boost header view
    private lazy var betslipOddsBoostHeaderView: BetslipOddsBoostHeaderView = {
        let view = BetslipOddsBoostHeaderView(
            viewModel: viewModel.betslipOddsBoostHeaderViewModel
        )
        view.translatesAutoresizingMaskIntoConstraints = false
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
        tableView.register(OddsVariationTableViewCell.self, forCellReuseIdentifier: "OddsVariationCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.contentInset.bottom = 32
        tableView.verticalScrollIndicatorInsets.bottom = 32
        
        return tableView
    }()
    
    // Bet info submission view
    private lazy var betInfoSubmissionView: BetInfoSubmissionView = {
        let view = BetInfoSubmissionView(viewModel: viewModel.betInfoSubmissionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Suggested bets expanded view
    private lazy var suggestedBetsView: SuggestedBetsExpandedView = {
        let view = SuggestedBetsExpandedView(viewModel: viewModel.suggestedBetsViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Code input view
    private lazy var codeInputView: CodeInputView = {
        let view = CodeInputView(viewModel: viewModel.codeInputViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Toast view (hidden by default)
    private lazy var toasterView: ToasterView = {
        let view = ToasterView(viewModel: viewModel.toasterViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // Login button
    private lazy var loginButtonContainerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }()
    
    private lazy var loginButton: ButtonView = {
        let button = ButtonView(viewModel: viewModel.loginButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Bottom stack containing bet submission, code input and login button
    private lazy var bottomActionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
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
        setupTableHeaderView()
        setupConstraints()
        setupBindings()
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Recalculate header size when view bounds change (rotation, split screen, etc.)
        updateTableHeaderViewHeight()

        // Round top corners of suggested bets view
        suggestedBetsView.layer.cornerRadius = 6
        suggestedBetsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        suggestedBetsView.clipsToBounds = true

    }

    // MARK: - Setup Methods
    private func setupSubviews() {
        // Setup top section stack (will be assigned as tableHeaderView)
        // DO NOT add topSectionStackView to view - it will be the table header

        // Add only button bar and odds boost header to stack
        topSectionStackView.addArrangedSubview(oddsBoostHeaderContainer)
        topSectionStackView.addArrangedSubview(buttonBarView)
        
        // Add odds boost header to its container
        oddsBoostHeaderContainer.addSubview(betslipOddsBoostHeaderView)

        // Add other views directly to view (NOT in stack)
        view.addSubview(ticketsTableView)
        view.addSubview(suggestedBetsView)
        view.addSubview(bottomActionsStackView)
        view.addSubview(toasterView)
        
        // EmptyStateView overlays everything
        view.addSubview(emptyStateView)

        // Add arranged subviews to stack
        bottomActionsStackView.addArrangedSubview(betInfoSubmissionView)
        bottomActionsStackView.addArrangedSubview(codeInputView)
        bottomActionsStackView.addArrangedSubview(loginButtonContainerView)
        loginButtonContainerView.addSubview(loginButton)

        // Add loading view on top
        view.addSubview(loadingView)
        loadingView.addSubview(loadingActivityIndicator)

        // Button bar internal subviews
        buttonBarView.addSubview(bookingCodeButton)
        buttonBarView.addSubview(clearBetslipButton)
    }

    private func setupTableHeaderView() {
        // Use table view width for proper sizing (fallback to view width if not available yet)
        let headerWidth = ticketsTableView.bounds.width > 0 ? ticketsTableView.bounds.width : view.bounds.width

        // Set initial frame with estimated height
        topSectionStackView.frame = CGRect(x: 0, y: 0, width: headerWidth, height: 50)

        // Assign as table header
        ticketsTableView.tableHeaderView = topSectionStackView

        // Force layout and calculate actual required size
        topSectionStackView.setNeedsLayout()
        topSectionStackView.layoutIfNeeded()

        // Calculate compressed size with proper width constraint
        let fittingSize = topSectionStackView.systemLayoutSizeFitting(
            CGSize(width: headerWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        // Update frame with calculated height
        topSectionStackView.frame.size = CGSize(width: headerWidth, height: fittingSize.height)

        // Reassign to trigger table view layout update
        ticketsTableView.tableHeaderView = topSectionStackView
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            // No constraints for topSectionStackView - it's now the tableHeaderView

            // Button bar height (needed for stack height calculation)
            buttonBarView.heightAnchor.constraint(equalToConstant: 50),

            // Booking Code button (internal to button bar)
            bookingCodeButton.topAnchor.constraint(equalTo: buttonBarView.topAnchor, constant: 8),
            bookingCodeButton.leadingAnchor.constraint(equalTo: buttonBarView.leadingAnchor, constant: 16),
            bookingCodeButton.bottomAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: -8),

            // Clear Betslip button (internal to button bar)
            clearBetslipButton.topAnchor.constraint(equalTo: buttonBarView.topAnchor, constant: 8),
            clearBetslipButton.trailingAnchor.constraint(equalTo: buttonBarView.trailingAnchor, constant: -16),
            clearBetslipButton.bottomAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: -8),

            // Odds boost header inside container with padding
            betslipOddsBoostHeaderView.topAnchor.constraint(equalTo: oddsBoostHeaderContainer.topAnchor, constant: 0),
            betslipOddsBoostHeaderView.leadingAnchor.constraint(equalTo: oddsBoostHeaderContainer.leadingAnchor, constant: 0),
            betslipOddsBoostHeaderView.trailingAnchor.constraint(equalTo: oddsBoostHeaderContainer.trailingAnchor, constant: 0),
            betslipOddsBoostHeaderView.bottomAnchor.constraint(equalTo: oddsBoostHeaderContainer.bottomAnchor, constant: 0),

            // Tickets table view - starts at top, extends 30px behind suggested bets
            ticketsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            ticketsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ticketsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ticketsTableView.bottomAnchor.constraint(equalTo: suggestedBetsView.topAnchor, constant: 30),

            // Suggested bets view - positioned above bottom actions
            suggestedBetsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestedBetsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestedBetsView.bottomAnchor.constraint(equalTo: bottomActionsStackView.topAnchor),

            // Bottom actions stack - fixed at bottom
            bottomActionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomActionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomActionsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Empty state view - fill remaining space above bet info submission
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Toaster view at top
            toasterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toasterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toasterView.bottomAnchor.constraint(equalTo: suggestedBetsView.topAnchor, constant: -20)
        ])
        
        // Login button container internal padding
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: loginButtonContainerView.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: loginButtonContainerView.trailingAnchor, constant: -16),
            loginButton.topAnchor.constraint(equalTo: loginButtonContainerView.topAnchor, constant: 16),
            loginButton.bottomAnchor.constraint(equalTo: loginButtonContainerView.bottomAnchor, constant: -16)
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
                self?.codeInputView.isHidden = true
                self?.loginButtonContainerView.isHidden = true
            case .ticketsLoggedOut:
                self?.betInfoSubmissionView.isHidden = true
                self?.codeInputView.isHidden = true
                self?.loginButtonContainerView.isHidden = false
            case .noTicketsLoggedIn:
                self?.betInfoSubmissionView.isHidden = true
                self?.codeInputView.isHidden = false
                self?.loginButtonContainerView.isHidden = true
            case .ticketsLoggedIn:
                self?.betInfoSubmissionView.isHidden = false
                self?.codeInputView.isHidden = true
                self?.loginButtonContainerView.isHidden = true
                
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
        
        // Setup suggested bets updates
        viewModel.suggestedBetsViewModel.matchCardViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.toggleSuggestedBetsVisibility()
            }
            .store(in: &cancellables)

        // Subscribe to odds boost header visibility
        viewModel.oddsBoostHeaderVisibilityPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldShow in
                self?.updateOddsBoostHeaderVisibility(shouldShow)
            }
            .store(in: &cancellables)
        
        // Toast message callback
        viewModel.showToastMessage = { [weak self] _ in
            self?.showToast()
        }
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
    
    private func toggleSuggestedBetsVisibility() {
        let hasMatches = !viewModel.suggestedBetsViewModel.matchCardViewModels.isEmpty
        suggestedBetsView.isHidden = !hasMatches

    }

    private func updateOddsBoostHeaderVisibility(_ shouldShow: Bool) {
        guard oddsBoostHeaderContainer.isHidden != !shouldShow else { return }

        UIView.animate(withDuration: 0.3) {
            self.oddsBoostHeaderContainer.isHidden = !shouldShow
            self.oddsBoostHeaderContainer.alpha = shouldShow ? 1.0 : 0.0

            // Recalculate header height when visibility changes
            self.updateTableHeaderViewHeight()
        }
    }

    private func updateTableHeaderViewHeight() {
        guard let headerView = ticketsTableView.tableHeaderView else { return }

        let width = ticketsTableView.bounds.width
        guard width > 0 else { return }  // Skip if table view hasn't been laid out yet

        // Set width on frame first (critical for proper sizing)
        headerView.frame.size.width = width

        // Force layout with new width
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        // Calculate proper height with width constraint
        let fittingSize = headerView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        // Only update if size actually changed (prevents layout loops)
        if headerView.frame.size != fittingSize {
            headerView.frame.size = fittingSize
            ticketsTableView.tableHeaderView = headerView  // Reassign to trigger table view layout
        }
    }

    private func handleClearBetslipTapped() {
        viewModel.clearAllTickets()
    }
    
    private func handleBookingCodeTapped() {
        // TODO: Implement booking code functionality
        print("Booking code button tapped - functionality to be implemented")
    }
    
    private func handleLoginTapped() {
        // TODO: Implement login functionality
        print("Login button tapped - functionality to be implemented")
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
        let ticketCount = viewModel.currentTickets.count
        // Add 1 for the odds variation cell if there are tickets
        return ticketCount > 0 ? ticketCount + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ticketCount = viewModel.currentTickets.count
        
        // Check if this is the odds variation cell (last row when there are tickets)
        if indexPath.row == ticketCount {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OddsVariationCell", for: indexPath) as? OddsVariationTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: viewModel.oddsAcceptanceViewModel)
            return cell
        }
        
        // Regular ticket cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BetslipTicketCell", for: indexPath) as? BetslipTicketTableViewCell else {
            return UITableViewCell()
        }
        
        let ticket = viewModel.currentTickets[indexPath.row]
        
        // Create a proper mock view model with the actual ticket data
        let ticketViewModel = MockBetslipTicketViewModel(
            leagueName: ticket.competition ?? "Unknown League",
            startDate: formatTicketDate(ticket.date) ?? "Unknown Date",
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

// MARK: - Helper Methods
extension SportsBetslipViewController {
    private func formatTicketDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, HH:mm"
        
        return formatter.string(from: date)
    }
}

// MARK: - Toast Handling
private extension SportsBetslipViewController {
    func showToast() {
        toasterView.alpha = 0
        toasterView.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            self.toasterView.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                UIView.animate(withDuration: 0.25, animations: {
                    self.toasterView.alpha = 0
                }) { _ in
                    self.toasterView.isHidden = true
                }
            }
        }
    }
}
