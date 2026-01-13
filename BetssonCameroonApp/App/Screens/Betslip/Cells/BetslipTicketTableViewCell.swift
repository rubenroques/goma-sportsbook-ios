import Foundation
import UIKit
import GomaUI
import GomaLogger

/// A table view cell for displaying betting tickets in the betslip
public final class BetslipTicketTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    public static let reuseIdentifier = "BetslipTicketTableViewCell"
    
    // Stored view model for callback access
    private var currentViewModel: BetslipTicketViewModelProtocol?
    
    // Callback for ticket removal
    public var onTicketRemoved: (() -> Void)?
    
    // MARK: - UI Components
    
    // Ticket view
    lazy var ticketView: BetslipTicketView = {
        let placeholderViewModel = MockBetslipTicketViewModel.skeletonMock()
        let ticketView = BetslipTicketView(viewModel: placeholderViewModel)
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
//            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            ticketView.topAnchor.constraint(equalTo: contentView.topAnchor),
            ticketView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ticketView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ticketView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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
        let cellAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
        let configureTime = CFAbsoluteTimeGetCurrent()
        let data = viewModel.currentData

        GomaLogger.debug(.ui, category: "BETSLIP_RACE", "[\(cellAddress)] configure() START - homeTeam: '\(data.homeTeam)', awayTeam: '\(data.awayTeam)', odds: \(data.oddsValue)")

        currentViewModel = viewModel

        currentViewModel?.onCloseTapped = { [weak self] in
            self?.onTicketRemoved?()
        }

        GomaLogger.debug(.ui, category: "BETSLIP_RACE", "[\(cellAddress)] configure() assigning viewModel to ticketView...")
        ticketView.viewModel = viewModel

        ticketView.setNeedsLayout()
        ticketView.layoutIfNeeded()

        // Invalidate intrinsic content size to force recalculation
        invalidateIntrinsicContentSize()

        let elapsed = (CFAbsoluteTimeGetCurrent() - configureTime) * 1000
        GomaLogger.debug(.ui, category: "BETSLIP_RACE", "[\(cellAddress)] configure() END - elapsed: \(String(format: "%.2f", elapsed))ms")
    }
    
    // MARK: - View Model Access
    public var viewModel: BetslipTicketViewModelProtocol? {
        return currentViewModel
    }
    
    // MARK: - Reuse
    public override func prepareForReuse() {
        let cellAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
        GomaLogger.debug(.ui, category: "BETSLIP_RACE", "[\(cellAddress)] prepareForReuse() START")

        super.prepareForReuse()

        // Clear the stored view model reference
        currentViewModel = nil

        // Reset to skeleton state with a fresh placeholder view model
        let skeletonViewModel = MockBetslipTicketViewModel.skeletonMock()
        GomaLogger.debug(.ui, category: "BETSLIP_RACE", "[\(cellAddress)] prepareForReuse() assigning skeleton VM - homeTeam: '\(skeletonViewModel.currentData.homeTeam)'")
        ticketView.viewModel = skeletonViewModel

        // Clear any existing callbacks
        skeletonViewModel.onCloseTapped = nil

        GomaLogger.debug(.ui, category: "BETSLIP_RACE", "[\(cellAddress)] prepareForReuse() END")
    }
    
    // MARK: - Intrinsic Content Size
    public override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        // Force layout update when intrinsic size changes
        setNeedsLayout()
        layoutIfNeeded()
    }
} 
