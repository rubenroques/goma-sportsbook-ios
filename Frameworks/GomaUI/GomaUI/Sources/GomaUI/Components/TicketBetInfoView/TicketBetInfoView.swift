import UIKit
import Combine
import SwiftUI


public enum CornerRadiusStyle {
    case all
    case topOnly
    case bottomOnly
}

public class TicketBetInfoView: UIView {
    
    // MARK: - Properties
    private var viewModel: TicketBetInfoViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private let cornerRadiusStyle: CornerRadiusStyle
    
    // Dynamic constraints
    private var financialSummaryBottomConstraint: NSLayoutConstraint?
    private var bottomComponentsTopConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    private let wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return view
    }()
    
    // Main stack view containing containerView and betTicketStatusView
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true 
        return stackView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        // view.layer.cornerRadius = 8
        return view
    }()
    
    // Dedicated bet status view (sibling of containerView)
    private var betTicketStatusView: BetTicketStatusView!
    
    private func createBetStatusView() -> BetTicketStatusView {
        let statusViewModel = MockBetTicketStatusViewModel.customMock(status: .won)
        let statusView = BetTicketStatusView(viewModel: statusViewModel)
        statusView.translatesAutoresizingMaskIntoConstraints = false
        statusView.isHidden = true
        return statusView
    }
    
    // Header section
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let betDetailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 10)
        label.textColor = StyleProvider.Color.textSecondary
        return label
    }()
    
    private let navigationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = StyleProvider.Color.highlightPrimary
        return button
    }()
    
    // Action buttons section
    private let actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var rebetButton: ButtonIconView = {
        let button = ButtonIconView(viewModel: viewModel.rebetButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 12
        button.backgroundColor = StyleProvider.Color.backgroundSecondary
        return button
    }()
    
    private lazy var cashoutButton: ButtonIconView = {
        let button = ButtonIconView(viewModel: viewModel.cashoutButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 12
        button.backgroundColor = StyleProvider.Color.backgroundSecondary
        return button
    }()
    
    // Ticket selection views container
    private let ticketsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    // Bottom separator
    private let bottomSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        return view
    }()
    
    // Financial summary section
    private let financialSummaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Bottom components stack view
    private let bottomComponentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    // Horizontal stack view for labels
    private let labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 8
        return stackView
    }()
    
    private let totalOddsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.text = LocalizationProvider.string("total_odds")
        label.textAlignment = .left
        return label
    }()
    
    private let totalOddsValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let betAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.text = LocalizationProvider.string("bet_amount")
        label.textAlignment = .center
        return label
    }()
    
    private let betAmountValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let possibleWinningsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.text = LocalizationProvider.string("possible_winnings")
        label.textAlignment = .right
        return label
    }()
    
    private let possibleWinningsValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    // MARK: - Initialization
    public init(viewModel: TicketBetInfoViewModelProtocol,
                cornerRadiusStyle: CornerRadiusStyle = .all) {
        self.viewModel = viewModel
        self.cornerRadiusStyle = cornerRadiusStyle
        
        super.init(frame: .zero)
        
        setupView()
        setupConstraints()
        setupCornerRadius()
        
        configure(with: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Reconfiguration
    /// Configures the view with a new view model for efficient reuse
    public func configure(with newViewModel: TicketBetInfoViewModelProtocol) {
        // Clear previous bindings
        cancellables.removeAll()
        
        // Update view model reference
        self.viewModel = newViewModel
        
        // Update buttons with new viewModels
        updateButtons(with: newViewModel)

        updateUI(with: newViewModel.currentBetInfo)
        
        bindViewModel()
    }
    
    /// Prepares the view for reuse by clearing reactive bindings and resetting state
    public func prepareForReuse() {
        // Cancel all active publishers
        cancellables.removeAll()
        
        // Clear ticket selections
        ticketsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Clear bottom components
        bottomComponentsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Reset labels to empty state
        titleLabel.text = ""
        betDetailsLabel.text = ""
        totalOddsValueLabel.text = ""
        betAmountValueLabel.text = ""
        possibleWinningsValueLabel.text = ""
    }
    
    // MARK: - Button Management
    private func updateButtons(with newViewModel: TicketBetInfoViewModelProtocol) {
        // Update button viewModels using their configure method
        rebetButton.configure(with: newViewModel.rebetButtonViewModel)
        cashoutButton.configure(with: newViewModel.cashoutButtonViewModel)
    }
    
    // MARK: - Setup
    private func setupView() {
        // Initialize bet status view
        betTicketStatusView = createBetStatusView()
        
        // Wrapper setup (outer container with corner radius)
        addSubview(wrapperView)
        wrapperView.addSubview(mainStackView)
        
        // Main stack setup - contains containerView and betTicketStatusView
        mainStackView.addArrangedSubview(containerView)
        mainStackView.addArrangedSubview(betTicketStatusView)
        
        // Header setup
        containerView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(betDetailsLabel)
        headerView.addSubview(navigationButton)
        
        // Action buttons setup
        containerView.addSubview(actionButtonsStackView)
        
        actionButtonsStackView.addArrangedSubview(rebetButton)
        
        actionButtonsStackView.addArrangedSubview(cashoutButton)
        
        // Tickets setup
        containerView.addSubview(ticketsStackView)
        
        // Bottom separator setup
        containerView.addSubview(bottomSeparatorView)
        
        // Financial summary setup
        containerView.addSubview(financialSummaryView)
        financialSummaryView.addSubview(labelsStackView)
        financialSummaryView.addSubview(totalOddsValueLabel)
        financialSummaryView.addSubview(betAmountValueLabel)
        financialSummaryView.addSubview(possibleWinningsValueLabel)
        
        // Bottom components setup
        containerView.addSubview(bottomComponentsStackView)
        
        // Add labels to stack view
        labelsStackView.addArrangedSubview(totalOddsLabel)
        labelsStackView.addArrangedSubview(betAmountLabel)
        labelsStackView.addArrangedSubview(possibleWinningsLabel)
        
        // Add tap gesture to navigation button
        navigationButton.addTarget(self, action: #selector(navigationButtonTapped), for: .primaryActionTriggered)
        
        // Add tap gesture to entire view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        
        containerView.addGestureRecognizer(tapGesture)
        
    }
    
    private func setupConstraints() {
        // Create the financial summary bottom constraint (will be activated/deactivated dynamically)
        financialSummaryBottomConstraint = financialSummaryView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        bottomComponentsTopConstraint = bottomComponentsStackView.topAnchor.constraint(equalTo: financialSummaryView.bottomAnchor, constant: 8)
        
        NSLayoutConstraint.activate([
            // Wrapper constraints (outer container with corner radius)
            wrapperView.topAnchor.constraint(equalTo: topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Main stack view constraints (8px padding from wrapper)
            mainStackView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 8),
            mainStackView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -8),
            mainStackView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -8),
            
            // Header constraints
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            
            betDetailsLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            betDetailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            betDetailsLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            navigationButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            navigationButton.topAnchor.constraint(equalTo: headerView.topAnchor),
            navigationButton.widthAnchor.constraint(equalToConstant: 24),
            navigationButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Action buttons constraints
            actionButtonsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            actionButtonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            actionButtonsStackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -8),
            actionButtonsStackView.heightAnchor.constraint(equalToConstant: 24),
            
            // Tickets stack view constraints
            ticketsStackView.topAnchor.constraint(equalTo: actionButtonsStackView.bottomAnchor, constant: 10),
            ticketsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            ticketsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            // Financial summary constraints
            financialSummaryView.topAnchor.constraint(equalTo: ticketsStackView.bottomAnchor, constant: 10),
            financialSummaryView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            financialSummaryView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Labels stack view constraints
            labelsStackView.leadingAnchor.constraint(equalTo: financialSummaryView.leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: financialSummaryView.trailingAnchor),
            labelsStackView.topAnchor.constraint(equalTo: financialSummaryView.topAnchor),
            
            // Separator line between labels and values
            bottomSeparatorView.leadingAnchor.constraint(equalTo: financialSummaryView.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: financialSummaryView.trailingAnchor),
            bottomSeparatorView.topAnchor.constraint(equalTo: labelsStackView.bottomAnchor, constant: 8),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            // Value labels constraints
            totalOddsValueLabel.centerXAnchor.constraint(equalTo: totalOddsLabel.centerXAnchor),
            totalOddsValueLabel.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: 8),
            totalOddsValueLabel.bottomAnchor.constraint(equalTo: financialSummaryView.bottomAnchor),
            
            betAmountValueLabel.centerXAnchor.constraint(equalTo: betAmountLabel.centerXAnchor),
            betAmountValueLabel.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: 8),
            
            possibleWinningsValueLabel.centerXAnchor.constraint(equalTo: possibleWinningsLabel.centerXAnchor),
            possibleWinningsValueLabel.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: 8),
            
            // Bottom components stack view constraints (horizontal only, vertical will be dynamic)
            bottomComponentsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            bottomComponentsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            bottomComponentsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        // Initially activate the financial summary bottom constraint (empty state)
        financialSummaryBottomConstraint?.isActive = true
    }
    
    private func setupCornerRadius() {
        switch cornerRadiusStyle {
        case .all:
            wrapperView.layer.cornerRadius = 8
            wrapperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
        case .topOnly:
            wrapperView.layer.cornerRadius = 8
            wrapperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
        case .bottomOnly:
            wrapperView.layer.cornerRadius = 8
            wrapperView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    private func bindViewModel() {
        viewModel.betInfoPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] betInfo in
                self?.updateUI(with: betInfo)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    private func updateUI(with betInfo: TicketBetInfoData) {
        titleLabel.text = betInfo.title
        betDetailsLabel.text = betInfo.betDetails
        
        totalOddsValueLabel.text = betInfo.totalOdds
        betAmountValueLabel.text = betInfo.betAmount
        possibleWinningsValueLabel.text = betInfo.possibleWinnings
        
        updateTickets(with: betInfo)
        updateBottomComponents(with: betInfo)
        updateBetStatus(with: betInfo)
    }
    
    private func updateTickets(with betInfo: TicketBetInfoData) {
        // Remove existing ticket views
        ticketsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new ticket views
        for ticketData in betInfo.tickets {
            let mockViewModel = MockTicketSelectionViewModel.preLiveMock
            mockViewModel.updateTicketData(ticketData)
            
            let ticketView = TicketSelectionView(viewModel: mockViewModel)
            
            if let status = betInfo.betStatus {
                ticketView.updateResultTag(with: status)
            }
            
            ticketsStackView.addArrangedSubview(ticketView)
        }
        
        UIView.performWithoutAnimation {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    private func updateBottomComponents(with betInfo: TicketBetInfoData) {
        // Remove existing components
        bottomComponentsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Deactivate current constraints
        financialSummaryBottomConstraint?.isActive = false
        bottomComponentsTopConstraint?.isActive = false
        
        var hasComponents = false
        
        // Handle cashout components for open bets only (not settled bets)
        if !betInfo.isSettled {
            // Add CashoutAmountView if partialCashoutValue is provided
            if let partialCashoutValue = betInfo.partialCashoutValue {
                let cashoutAmountViewModel = MockCashoutAmountViewModel.customMock(
                    title: "Partial Cashout",
                    currency: "XAF",
                    amount: partialCashoutValue
                )
                let cashoutAmountView = CashoutAmountView(viewModel: cashoutAmountViewModel)
                bottomComponentsStackView.addArrangedSubview(cashoutAmountView)
                hasComponents = true
            }
            
            // Add CashoutSliderView if cashoutTotalAmount is provided
            if let cashoutTotalAmount = betInfo.cashoutTotalAmount {
                let cashoutSliderViewModel = MockCashoutSliderViewModel.customMock(
                    title: "Cash out amount",
                    minimumValue: 0.1,
                    maximumValue: Float(cashoutTotalAmount) ?? 200.0,
                    currentValue: Float(cashoutTotalAmount) ?? 200.0,
                    currency: "XAF"
                )
                let cashoutSliderView = CashoutSliderView(viewModel: cashoutSliderViewModel)
                bottomComponentsStackView.addArrangedSubview(cashoutSliderView)
                hasComponents = true
            }
        }
        
        // Activate appropriate constraints based on whether components are present
        if hasComponents {
            bottomComponentsTopConstraint?.isActive = true
        } else {
            financialSummaryBottomConstraint?.isActive = true
        }
    }
    
    private func updateBetStatus(with betInfo: TicketBetInfoData) {
        // Show/hide bet status view based on settled state and status data
        if betInfo.isSettled, let betStatus = betInfo.betStatus {
            // Remove and recreate bet status view with new data
            mainStackView.removeArrangedSubview(betTicketStatusView)
            betTicketStatusView.removeFromSuperview()
            
            // Create new status view with correct data
            let betTicketStatusData = BetTicketStatusData(status: betStatus.status)
            let viewModel = MockBetTicketStatusViewModel(betTicketStatusData: betTicketStatusData)
            
            betTicketStatusView = BetTicketStatusView(viewModel: viewModel)
            betTicketStatusView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add back to stack view
            mainStackView.addArrangedSubview(betTicketStatusView)
            betTicketStatusView.isHidden = false
        } else {
            betTicketStatusView.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc private func navigationButtonTapped() {
        viewModel.handleNavigationTap()
    }
    
    @objc private func viewTapped() {
        viewModel.handleNavigationTap()
    }
    
    @objc private func rebetButtonTapped() {
        viewModel.handleRebetTap()
    }
    
    @objc private func cashoutButtonTapped() {
        viewModel.handleCashoutTap()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("With Cashout Amount") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketBetInfoViewModel.pendingMockWithCashout()
        let ticketBetInfoView = TicketBetInfoView(viewModel: mockViewModel, cornerRadiusStyle: .all)
        ticketBetInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(ticketBetInfoView)
        
        NSLayoutConstraint.activate([
            ticketBetInfoView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketBetInfoView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketBetInfoView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("With Cashout Slider") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketBetInfoViewModel.pendingMockWithSlider()
        let ticketBetInfoView = TicketBetInfoView(viewModel: mockViewModel, cornerRadiusStyle: .all)
        ticketBetInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(ticketBetInfoView)
        
        NSLayoutConstraint.activate([
            ticketBetInfoView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketBetInfoView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketBetInfoView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("With Both Components") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketBetInfoViewModel.pendingMockWithBoth()
        let ticketBetInfoView = TicketBetInfoView(viewModel: mockViewModel, cornerRadiusStyle: .all)
        ticketBetInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(ticketBetInfoView)
        
        NSLayoutConstraint.activate([
            ticketBetInfoView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketBetInfoView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketBetInfoView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Default Empty") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketBetInfoViewModel.pendingMock()
        let ticketBetInfoView = TicketBetInfoView(viewModel: mockViewModel, cornerRadiusStyle: .all)
        ticketBetInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(ticketBetInfoView)
        
        NSLayoutConstraint.activate([
            ticketBetInfoView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketBetInfoView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketBetInfoView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Top Corners Only") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketBetInfoViewModel.pendingMock()
        let ticketBetInfoView = TicketBetInfoView(viewModel: mockViewModel, cornerRadiusStyle: .topOnly)
        ticketBetInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(ticketBetInfoView)
        
        NSLayoutConstraint.activate([
            ticketBetInfoView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketBetInfoView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketBetInfoView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Bottom Corners Only") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketBetInfoViewModel.pendingMock()
        let ticketBetInfoView = TicketBetInfoView(viewModel: mockViewModel, cornerRadiusStyle: .bottomOnly)
        ticketBetInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(ticketBetInfoView)
        
        NSLayoutConstraint.activate([
            ticketBetInfoView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketBetInfoView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketBetInfoView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Lost bet") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketBetInfoViewModel.lostBetMock()
        let ticketBetInfoView = TicketBetInfoView(viewModel: mockViewModel, cornerRadiusStyle: .all)
        ticketBetInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(ticketBetInfoView)
        
        NSLayoutConstraint.activate([
            ticketBetInfoView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketBetInfoView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketBetInfoView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#endif
