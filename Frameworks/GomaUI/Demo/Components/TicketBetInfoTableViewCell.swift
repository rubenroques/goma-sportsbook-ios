import UIKit
import GomaUI

class TicketBetInfoTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    private var ticketBetInfoView: TicketBetInfoView?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - Setup
    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        // Add margins for visual separation
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    // MARK: - Configuration
    func configure(with viewModel: TicketBetInfoViewModelProtocol, cornerStyle: CornerRadiusStyle = .all(radius: 8)) {
        // Remove existing ticket bet info view if any
        ticketBetInfoView?.removeFromSuperview()
        
        // Create new ticket bet info view
        ticketBetInfoView = TicketBetInfoView(viewModel: viewModel, cornerRadiusStyle: cornerStyle)
        
        guard let ticketBetInfoView = ticketBetInfoView else { return }
        
        ticketBetInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set content priorities to ensure proper layout
        ticketBetInfoView.setContentHuggingPriority(.required, for: .vertical)
        ticketBetInfoView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        contentView.addSubview(ticketBetInfoView)
        
        // Setup constraints for dynamic height
        NSLayoutConstraint.activate([
            ticketBetInfoView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            ticketBetInfoView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            ticketBetInfoView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            ticketBetInfoView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        // Force immediate layout to ensure proper height calculation
        ticketBetInfoView.layoutIfNeeded()
        contentView.layoutIfNeeded()
        
        // Invalidate intrinsic content size to trigger table view height recalculation
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Clean up the existing view properly
        if let ticketBetInfoView = ticketBetInfoView {
            ticketBetInfoView.removeFromSuperview()
            self.ticketBetInfoView = nil
        }
        
        // Reset content size
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure proper layout for dynamic height calculation
        contentView.layoutIfNeeded()
        
        // Update intrinsic content size after layout
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Size Calculation
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let ticketBetInfoView = ticketBetInfoView else {
            return CGSize(width: size.width, height: 280) // Realistic default height
        }
        
        // Ensure the view is properly configured before measuring
        ticketBetInfoView.layoutIfNeeded()
        
        // Calculate the size needed by the ticket bet info view
        let margins = contentView.layoutMargins
        let availableWidth = size.width - margins.left - margins.right
        let availableSize = CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let ticketSize = ticketBetInfoView.systemLayoutSizeFitting(
            availableSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        let totalHeight = ticketSize.height + margins.top + margins.bottom
        
        return CGSize(width: size.width, height: max(totalHeight, 280))
    }
    
    // MARK: - Intrinsic Content Size
    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
    }
}