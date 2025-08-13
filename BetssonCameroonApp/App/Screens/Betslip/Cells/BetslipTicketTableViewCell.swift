import Foundation
import UIKit
import GomaUI

/// A table view cell for displaying betting tickets in the betslip
public final class BetslipTicketTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    public static let reuseIdentifier = "BetslipTicketTableViewCell"
    
    // MARK: - UI Components
    
    // Ticket view
    private lazy var ticketView: BetslipTicketView = {
        let ticketView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.skeletonMock())
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        return ticketView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupConstraints()
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        contentView.addSubview(ticketView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Ticket view fills the cell
            ticketView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            ticketView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ticketView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ticketView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupCell() {
        // Remove default cell styling
        backgroundColor = .clear
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Configuration
    public func configure(with viewModel: BetslipTicketViewModelProtocol) {
        // Set the new view model - the view will automatically re-bind and render
        ticketView.viewModel = viewModel
    }
    
    // MARK: - Reuse
    public override func prepareForReuse() {
        super.prepareForReuse()
        // Reset to skeleton state
        ticketView.viewModel = MockBetslipTicketViewModel.skeletonMock()
    }
} 
