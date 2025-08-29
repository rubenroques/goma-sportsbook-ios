import UIKit
import GomaUI
import Combine

final class TicketBetInfoTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    struct Constants {
        static let horizontalInset: CGFloat = 0
        static let verticalInset: CGFloat = 0
    }
    
    // MARK: - Properties
    
    private var ticketBetInfoView: TicketBetInfoView?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Cell Identifier
    
    static let identifier = "TicketBetInfoTableViewCell"
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - Cell Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Prepare the ticket view for reuse
        ticketBetInfoView?.prepareForReuse()
        
        // Clear all subscriptions
        cancellables.removeAll()
    }
    
    // ⭐ NOTE: No preferredLayoutAttributesFitting needed!
    // UITableView handles dynamic sizing automatically with automaticDimension
    
    // MARK: - Setup
    
    private func setupCell() {
        contentView.backgroundColor = UIColor.App.backgroundPrimary
        backgroundColor = UIColor.App.backgroundPrimary
        selectionStyle = .none
    }
    
    // MARK: - Configuration
    
    func configure(with viewModel: TicketBetInfoViewModelProtocol) {
        if let existingView = ticketBetInfoView {
            // Reuse existing view - more efficient for scrolling
            reconfigureExistingView(existingView, with: viewModel)
        } else {
            // Create new view only if one doesn't exist
            createAndSetupTicketView(with: viewModel)
        }
        
        setupViewActions(with: viewModel)
    }
    
    // Configure cell position for proper corner radius styling
    func configureCellPosition(isFirst: Bool, isLast: Bool, isOnlyCell: Bool = false) {
        guard let ticketView = ticketBetInfoView else { return }
        
        let cornerRadiusStyle: CornerRadiusStyle
        
        if isOnlyCell {
            // Single cell in list - all corners rounded
            cornerRadiusStyle = .all(radius: 8)
        } else if isFirst {
            // First cell - top corners only
            cornerRadiusStyle = .topOnly(radius: 8)
        } else if isLast {
            // Last cell - bottom corners only
            cornerRadiusStyle = .bottomOnly(radius: 8)
        } else {
            // Middle cells - no rounded corners
            cornerRadiusStyle = .all(radius: 0)
        }
        
        // Apply corner radius style at cell level
        applyCornerRadiusToContentView(cornerRadiusStyle)
    }
    
    // MARK: - Private Setup Methods
    
    private func createAndSetupTicketView(with viewModel: TicketBetInfoViewModelProtocol) {
        let ticketView = TicketBetInfoView(
            viewModel: viewModel,
            cornerRadiusStyle: .all(radius: 8)
        )
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to content view
        contentView.addSubview(ticketView)
        
        // ⭐ KEY: Edge constraints enable automatic sizing in UITableView
        NSLayoutConstraint.activate([
            ticketView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalInset),
            ticketView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            ticketView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            ticketView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalInset)
        ])
        
        // Store reference
        self.ticketBetInfoView = ticketView
    }
    
    private func reconfigureExistingView(_ ticketView: TicketBetInfoView, with viewModel: TicketBetInfoViewModelProtocol) {
        // Clear existing subscriptions
        cancellables.removeAll()
        
        // Use the configure method to update the view with new data
        ticketView.configure(with: viewModel)
    }
    
    private func setupViewActions(with viewModel: TicketBetInfoViewModelProtocol) {
        guard let ticketView = ticketBetInfoView else { return }
        
        // Note: TicketBetInfoView handles actions internally through its viewModel
        // The actions are already wired up in TicketBetInfoViewModel
        // No additional action setup needed here
        
        // Optional: Subscribe to viewModel changes if needed
        viewModel.betInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] betInfo in
                // Handle any UI updates if necessary
                // The TicketBetInfoView will update itself through its bindings
            }
            .store(in: &cancellables)
    }
    
    private func applyCornerRadiusToContentView(_ cornerRadiusStyle: CornerRadiusStyle) {
        switch cornerRadiusStyle {
        case .all(let radius):
            contentView.layer.cornerRadius = radius
            contentView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
            
        case .topOnly(let radius):
            contentView.layer.cornerRadius = radius
            contentView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
            
        case .bottomOnly(let radius):
            contentView.layer.cornerRadius = radius
            contentView.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        
        contentView.layer.masksToBounds = true
    }
}

// MARK: - Alternative Configuration Method

extension TicketBetInfoTableViewCell {
    
    /// Configure with action handlers
    func configure(
        with viewModel: TicketBetInfoViewModelProtocol,
        onNavigationTap: @escaping () -> Void = {},
        onRebetTap: @escaping () -> Void = {},
        onCashoutTap: @escaping () -> Void = {}
    ) {
        // First configure with the view model
        configure(with: viewModel)
        
        // Then set up action handlers if the viewModel is our custom implementation
        if let ticketBetInfoViewModel = viewModel as? TicketBetInfoViewModel {
            ticketBetInfoViewModel.onNavigationTap = { _ in onNavigationTap() }
            ticketBetInfoViewModel.onRebetTap = { _ in onRebetTap() }
            ticketBetInfoViewModel.onCashoutTap = { _ in onCashoutTap() }
        }
    }
}