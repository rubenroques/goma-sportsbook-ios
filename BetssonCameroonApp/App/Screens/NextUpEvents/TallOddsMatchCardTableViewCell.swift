import UIKit
import GomaUI
import Combine

// MARK: - TallOddsMatchCardTableViewCell
final class TallOddsMatchCardTableViewCell: UITableViewCell {

    struct Constants {
        static let verticalSpacing: CGFloat = 9
        static let horizontalSpacing: CGFloat = 16
    }

    // MARK: - Properties
    private let tallOddsMatchCardView: TallOddsMatchCardView

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundCards
        return view
    }()

    private var cancellables = Set<AnyCancellable>()

    private var customBackgroundColor: UIColor?

    // MARK: - Cell Identifier
    static let identifier = "TallOddsMatchCardTableViewCell"

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let imageResolver = AppMatchHeaderImageResolver()
        self.tallOddsMatchCardView = TallOddsMatchCardView(viewModel: nil, imageResolver: imageResolver, customBackgroundColor: nil)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Cell Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()

        // Call prepareForReuse on card view (triggers cleanupForReuse on child views)
        tallOddsMatchCardView.prepareForReuse()
        cancellables.removeAll()
    }

    // MARK: - Setup
    private func setupCell() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.App.backgroundPrimary
        backgroundColor = UIColor.App.backgroundPrimary

        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 13),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -13),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ])

        tallOddsMatchCardView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tallOddsMatchCardView)

        NSLayoutConstraint.activate([
            tallOddsMatchCardView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.verticalSpacing),
            tallOddsMatchCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalSpacing),
            tallOddsMatchCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.horizontalSpacing),
            tallOddsMatchCardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.verticalSpacing)
        ])
    }

    // MARK: - Configuration
    func configure(with viewModel: TallOddsMatchCardViewModelProtocol, backgroundColor: UIColor? = nil) {

        if let backgroundColor {
            self.customBackgroundColor = backgroundColor
            self.containerView.backgroundColor = backgroundColor
        }

        tallOddsMatchCardView.configure(with: viewModel)
        self.setupCardViewActions()

        Publishers.CombineLatest(Env.betslipManager.bettingTicketsPublisher, viewModel.marketOutcomesViewModelPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tickets, marketOutcomes in

                for lineViewModel in marketOutcomes.lineViewModels {
                    if let leftOutcome = lineViewModel.marketStateSubject.value.leftOutcome {
                        let shouldBeSelected = tickets.contains { $0.outcomeId == leftOutcome.id }
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .left)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .left)
                        }
                    }

                    if let middleOutcome = lineViewModel.marketStateSubject.value.middleOutcome {
                        let shouldBeSelected = tickets.contains { $0.outcomeId == middleOutcome.id }
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .middle)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .middle)
                        }
                    }

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
        if isFirst && isLast {
            containerView.layer.cornerRadius = 12
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            containerView.layer.cornerRadius = 12
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            containerView.layer.cornerRadius = 12
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            containerView.layer.cornerRadius = 0
        }

        containerView.layer.masksToBounds = true
    }

    // MARK: - Actions Setup
    private func setupCardViewActions() {
        tallOddsMatchCardView.onMatchHeaderTapped = { [weak self] in
            print("Match header tapped in cell")
        }

        tallOddsMatchCardView.onFavoriteToggled = { [weak self] in
            print("Favorite toggled in cell")
        }

        tallOddsMatchCardView.onOutcomeSelected = { [weak self] outcomeId in
            print("Outcome selected in cell: \(outcomeId)")
        }

        tallOddsMatchCardView.onMarketInfoTapped = { [weak self] in
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
        configure(with: viewModel)

        tallOddsMatchCardView.onMatchHeaderTapped = onMatchHeaderTapped
        tallOddsMatchCardView.onFavoriteToggled = onFavoriteToggled
        tallOddsMatchCardView.onOutcomeSelected = onOutcomeSelected
        tallOddsMatchCardView.onMarketInfoTapped = onMarketInfoTapped
        tallOddsMatchCardView.onCardTapped = onCardTapped
    }
}
