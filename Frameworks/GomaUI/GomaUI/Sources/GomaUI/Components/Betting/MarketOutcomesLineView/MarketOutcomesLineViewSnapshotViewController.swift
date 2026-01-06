import UIKit

// MARK: - Snapshot Category
enum MarketOutcomesLineViewSnapshotCategory: String, CaseIterable {
    case marketVariants = "Market Variants"
    case stateVariants = "State Variants"
}

final class MarketOutcomesLineViewSnapshotViewController: UIViewController {

    private let category: MarketOutcomesLineViewSnapshotCategory

    init(category: MarketOutcomesLineViewSnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "MarketOutcomesLineView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .marketVariants:
            addMarketVariants(to: stackView)
        case .stateVariants:
            addStateVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addMarketVariants(to stackView: UIStackView) {
        // Three-Way Market (1X2)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Three-Way Market (1X2)",
            view: createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.threeWayMarket)
        ))

        // Two-Way Market (Over/Under)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Two-Way Market (Over/Under)",
            view: createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.twoWayMarket)
        ))

        // Double Chance Market
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Double Chance Market",
            view: createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.doubleChanceMarket)
        ))

        // Asian Handicap Market
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Asian Handicap Market",
            view: createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.asianHandicapMarket)
        ))
    }

    private func addStateVariants(to stackView: UIStackView) {
        // Selected Outcome
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Selected Outcome",
            view: createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.selectedOutcome)
        ))

        // Odds Changes
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Odds Changes (Up/Down)",
            view: createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.oddsChanges)
        ))

        // Disabled Outcome
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled Outcome",
            view: createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.disabledOutcome)
        ))

        // Suspended Market
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Suspended Market",
            view: createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.suspendedMarket)
        ))

        // See All Markets
        stackView.addArrangedSubview(createLabeledVariant(
            label: "See All Markets",
            view: createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.seeAllMarket)
        ))
    }

    // MARK: - Helper Methods

    private func createMarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel) -> MarketOutcomesLineView {
        let marketView = MarketOutcomesLineView(viewModel: viewModel)
        marketView.translatesAutoresizingMaskIntoConstraints = false
        return marketView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])

        let stack = UIStackView(arrangedSubviews: [labelView, containerView])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Market Variants") {
    MarketOutcomesLineViewSnapshotViewController(category: .marketVariants)
}

#Preview("State Variants") {
    MarketOutcomesLineViewSnapshotViewController(category: .stateVariants)
}
#endif
