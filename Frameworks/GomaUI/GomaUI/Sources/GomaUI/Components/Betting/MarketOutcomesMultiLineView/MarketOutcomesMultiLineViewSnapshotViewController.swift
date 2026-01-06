import UIKit

// MARK: - Snapshot Category
enum MarketOutcomesMultiLineViewSnapshotCategory: String, CaseIterable {
    case marketGroupVariants = "Market Group Variants"
    case specialStates = "Special States"
}

final class MarketOutcomesMultiLineViewSnapshotViewController: UIViewController {

    private let category: MarketOutcomesMultiLineViewSnapshotCategory

    init(category: MarketOutcomesMultiLineViewSnapshotCategory) {
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
        titleLabel.text = "MarketOutcomesMultiLineView - \(category.rawValue)"
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
        case .marketGroupVariants:
            addMarketGroupVariants(to: stackView)
        case .specialStates:
            addSpecialStates(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addMarketGroupVariants(to stackView: UIStackView) {
        // Over/Under Market Group (2-column)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Over/Under Market Group",
            view: createMarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup)
        ))

        // Home/Draw/Away Market Group (3-column)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Home/Draw/Away Market Group",
            view: createMarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.homeDrawAwayMarketGroup)
        ))

        // Mixed Layout Market Group
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Mixed Layout (2 and 3-column)",
            view: createMarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.mixedLayoutMarketGroup)
        ))
    }

    private func addSpecialStates(to stackView: UIStackView) {
        // With Suspended Line
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Suspended Line",
            view: createMarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.overUnderWithSuspendedLine)
        ))

        // With Odds Changes
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Odds Changes",
            view: createMarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.marketGroupWithOddsChanges)
        ))

        // Empty State With Title
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty State With Title",
            view: createMarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.emptyMarketGroupWithTitle)
        ))

        // Empty State
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty State",
            view: createMarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.emptyMarketGroup)
        ))
    }

    // MARK: - Helper Methods

    private func createMarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel) -> MarketOutcomesMultiLineView {
        let marketView = MarketOutcomesMultiLineView(viewModel: viewModel)
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
#Preview("Market Group Variants") {
    MarketOutcomesMultiLineViewSnapshotViewController(category: .marketGroupVariants)
}

#Preview("Special States") {
    MarketOutcomesMultiLineViewSnapshotViewController(category: .specialStates)
}
#endif
