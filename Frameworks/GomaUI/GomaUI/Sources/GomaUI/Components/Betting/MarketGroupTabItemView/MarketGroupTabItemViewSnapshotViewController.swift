import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum MarketGroupTabItemSnapshotCategory: String, CaseIterable {
    case visualStates = "Visual States"
    case iconVariants = "Icon Variants"
    case badgeVariants = "Badge Variants"
}

final class MarketGroupTabItemViewSnapshotViewController: UIViewController {

    private let category: MarketGroupTabItemSnapshotCategory

    init(category: MarketGroupTabItemSnapshotCategory) {
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
        titleLabel.text = "MarketGroupTabItemView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
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
        case .visualStates:
            addVisualStatesVariants(to: stackView)
        case .iconVariants:
            addIconVariants(to: stackView)
        case .badgeVariants:
            addBadgeVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addVisualStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Selected (1x2)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.oneXTwoTab)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Idle (Double Chance)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.doubleChanceTab)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Idle (Over/Under)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.overUnderTab)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Idle (Another Market)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.anotherMarketTab)
        ))
    }

    private func addIconVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Prefix Icon Only (Live)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.prefixOnlyTab)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Suffix Icon Only (Popular)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.suffixOnlyTab)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Both Icons (VIP)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.bothIconsTab)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "BetBuilder (Suffix + Badge)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.betBuilderTab)
        ))
    }

    private func addBadgeVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Badge (Popular - 12)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.popularTab)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Badge (Sets - 16)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.setsTab)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Badge (All)",
            view: createTabItemView(viewModel: MockMarketGroupTabItemViewModel.allTab)
        ))

        // Custom tab with large badge number
        let largeBadgeTab = MockMarketGroupTabItemViewModel.customTab(
            id: "large_badge",
            title: "Large Badge",
            selected: false,
            badgeCount: 99
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Large Badge (99)",
            view: createTabItemView(viewModel: largeBadgeTab)
        ))
    }

    // MARK: - Helper Methods

    private func createTabItemView(viewModel: MockMarketGroupTabItemViewModel) -> MarketGroupTabItemView {
        let view = MarketGroupTabItemView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Visual States") {
    MarketGroupTabItemViewSnapshotViewController(category: .visualStates)
}

#Preview("Icon Variants") {
    MarketGroupTabItemViewSnapshotViewController(category: .iconVariants)
}

#Preview("Badge Variants") {
    MarketGroupTabItemViewSnapshotViewController(category: .badgeVariants)
}
#endif
