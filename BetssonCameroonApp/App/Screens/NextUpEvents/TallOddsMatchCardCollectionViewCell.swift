import UIKit
import GomaUI
import Combine

// MARK: - TallOddsMatchCardCollectionViewCell
final class TallOddsMatchCardCollectionViewCell: UICollectionViewCell {

    struct Constants {
        static let verticalSpacing: CGFloat = 9  // Vertical spacing handled by collection view
        static let horizontalSpacing: CGFloat = 16  // Horizontal spacing handled by collection view
    }

    // MARK: - Properties
    private var tallOddsMatchCardView: TallOddsMatchCardView?
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Cell Identifier
    static let identifier = "TallOddsMatchCardCollectionViewCell"

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    // MARK: - Cell Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()

        // Prepare the card view for reuse instead of removing it
        tallOddsMatchCardView?.prepareForReuse()
        
        cancellables.removeAll()
    }

    // MARK: - Setup
    private func setupCell() {
        // Debug colors to identify layout issues
        contentView.backgroundColor = UIColor.App.backgroundCards
        backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: - Configuration
    func configure(with viewModel: TallOddsMatchCardViewModelProtocol) {

        if let existingCardView = tallOddsMatchCardView {
            // Reuse existing card view - much more efficient for scrolling
            existingCardView.configure(with: viewModel)
        } else {
            // Create new card view only if one doesn't exist
            createAndSetupCardView(with: viewModel)
        }

        // Set up action callbacks
        self.setupCardViewActions()
        
        Publishers.CombineLatest(Env.betslipManager.bettingTicketsPublisher, viewModel.marketOutcomesViewModelPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tickets, marketOutcomes in
                
                // Check each line view model for all outcomes
                for lineViewModel in marketOutcomes.lineViewModels {
                    // Check left outcome
                    if let leftOutcome = lineViewModel.marketStateSubject.value.leftOutcome {
                        let shouldBeSelected = tickets.contains { $0.outcomeId == leftOutcome.id }
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .left)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .left)
                        }
                    }
                    
                    // Check middle outcome
                    if let middleOutcome = lineViewModel.marketStateSubject.value.middleOutcome {
                        let shouldBeSelected = tickets.contains { $0.outcomeId == middleOutcome.id }
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .middle)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .middle)
                        }
                    }
                    
                    // Check right outcome
                    if let rightOutcome = lineViewModel.marketStateSubject.value.rightOutcome {
                        let shouldBeSelected = tickets.contains { $0.outcomeId == rightOutcome.id }
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .right)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .right)
                        }
                    }
                }
            })
            .store(in: &cancellables)
        
    }

    // Configure cell position for proper styling
    func configureCellPosition(isFirst: Bool, isLast: Bool) {
        // Configure rounded corners
        if isFirst && isLast {
            // Single cell - all corners rounded
            contentView.layer.cornerRadius = 12
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            // First cell - top corners rounded
            contentView.layer.cornerRadius = 12
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            // Last cell - bottom corners rounded
            contentView.layer.cornerRadius = 12
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            // Middle cells - no rounded corners
            contentView.layer.cornerRadius = 0
        }

        contentView.layer.masksToBounds = true
    }

    // MARK: - Private Setup Methods
    private func createAndSetupCardView(with viewModel: TallOddsMatchCardViewModelProtocol) {
        let imageResolver = AppMatchHeaderImageResolver()
        let cardView = TallOddsMatchCardView(viewModel: viewModel, imageResolver: imageResolver)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        cardView.backgroundColor = UIColor.App.backgroundCards
        // Add to content view (make sure it's added before separator)
        contentView.addSubview(cardView)

        // Set up constraints for full content view coverage
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalSpacing),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalSpacing),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalSpacing),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalSpacing)
        ])

        // Store reference
        self.tallOddsMatchCardView = cardView
    }

    // MARK: - Actions Setup
    private func setupCardViewActions() {
        guard let cardView = tallOddsMatchCardView else { return }

        // Set up action callbacks - these could be forwarded to delegates or closures
        cardView.onMatchHeaderTapped = { [weak self] in
            // Handle match header tap
            // This could be forwarded to a delegate or closure passed in configuration
            print("Match header tapped in cell")
        }

        cardView.onFavoriteToggled = { [weak self] in
            // Handle favorite toggle
            print("Favorite toggled in cell")
        }

        cardView.onOutcomeSelected = { [weak self] outcomeId in
            // Handle outcome selection
            print("Outcome selected in cell: \(outcomeId)")
        }

        cardView.onMarketInfoTapped = { [weak self] in
            // Handle market info tap
            print("Market info tapped in cell")
        }
    }
 
    // Alternative configuration method that accepts action handlers
    func configure(
        with viewModel: TallOddsMatchCardViewModelProtocol,
        onMatchHeaderTapped: @escaping () -> Void = {},
        onFavoriteToggled: @escaping () -> Void = {},
        onOutcomeSelected: @escaping (String) -> Void = { _ in },
        onMarketInfoTapped: @escaping () -> Void = {},
        onCardTapped: @escaping () -> Void = {}
    ) {
        // Configure the cell with the view model
        configure(with: viewModel)

        // Override the default action handlers
        tallOddsMatchCardView?.onMatchHeaderTapped = onMatchHeaderTapped
        tallOddsMatchCardView?.onFavoriteToggled = onFavoriteToggled
        tallOddsMatchCardView?.onOutcomeSelected = onOutcomeSelected
        tallOddsMatchCardView?.onMarketInfoTapped = onMarketInfoTapped
        tallOddsMatchCardView?.onCardTapped = onCardTapped
    }
}
