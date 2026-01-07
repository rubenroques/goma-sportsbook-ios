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
    
    // Will be called when there's a content update at the `TicketBetInfoView`
    public var updateLayout: (() -> Void)? {
        didSet {
            self.ticketBetInfoView?.onBottomContentChanged = self.updateLayout
        }
    }
    
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

    // MARK: - Setup
    
    private func setupCell() {
        contentView.backgroundColor = UIColor.App.backgroundPrimary
        backgroundColor = UIColor.App.backgroundPrimary
        selectionStyle = .none
    }
    
    // MARK: - Configuration
    
    func configure(with viewModel: TicketBetInfoViewModel) {
        if let existingView = ticketBetInfoView {
            // Reuse existing view - more efficient for scrolling
            reconfigureExistingView(existingView, with: viewModel)
        } else {
            // Create new view only if one doesn't exist
            createAndSetupTicketView(with: viewModel)
        }
    }
    
    // Configure cell position for proper corner radius styling
    func configureCellPosition(isFirst: Bool, isLast: Bool, isOnlyCell: Bool = false) {
        guard ticketBetInfoView != nil else { return }
        
        let cornerRadiusStyle: CornerRadiusStyle
        
        if isOnlyCell {
            // Single cell in list - all corners rounded
            cornerRadiusStyle = .all
        } else if isFirst {
            // First cell - top corners only
            cornerRadiusStyle = .topOnly
        } else if isLast {
            // Last cell - bottom corners only
            cornerRadiusStyle = .bottomOnly
        } else {
            // Middle cells - no rounded corners
            cornerRadiusStyle = .all
        }
        
        // Apply corner radius style at cell level
        applyCornerRadiusToContentView(cornerRadiusStyle)
    }
    
    // MARK: - Private Setup Methods
    
    private func createAndSetupTicketView(with viewModel: TicketBetInfoViewModel) {
        let ticketView = TicketBetInfoView(
            viewModel: viewModel,
            cornerRadiusStyle: .all
        )
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to content view
        contentView.addSubview(ticketView)
        
        NSLayoutConstraint.activate([
            ticketView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalInset),
            ticketView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            ticketView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            ticketView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalInset)
        ])
        
        // Store reference
        self.ticketBetInfoView = ticketView
    }
    
    private func reconfigureExistingView(_ ticketView: TicketBetInfoView, with viewModel: TicketBetInfoViewModel) {
        // Clear existing subscriptions
        cancellables.removeAll()
        
        // Use the configure method to update the view with new data
        ticketView.configure(with: viewModel)
    }
    
    private func applyCornerRadiusToContentView(_ cornerRadiusStyle: CornerRadiusStyle) {
        let radius: CGFloat = 8.0
        switch cornerRadiusStyle {
        case .all:
            contentView.layer.cornerRadius = radius
            contentView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
            
        case .topOnly:
            contentView.layer.cornerRadius = radius
            contentView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
            
        case .bottomOnly:
            contentView.layer.cornerRadius = radius
            contentView.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        
        contentView.layer.masksToBounds = true
    }
}
