import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum MarketNamePillLabelSnapshotCategory: String, CaseIterable {
    case styles = "Styles"
    case contentVariants = "Content Variants"
    case interactiveStates = "Interactive States"
}

final class MarketNamePillLabelViewSnapshotViewController: UIViewController {

    private let category: MarketNamePillLabelSnapshotCategory

    init(category: MarketNamePillLabelSnapshotCategory) {
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
        titleLabel.text = "MarketNamePillLabelView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
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
        case .styles:
            addStylesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        case .interactiveStates:
            addInteractiveStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addStylesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Standard",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.standardPill)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Highlighted",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.highlightedPill)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.disabledPill)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom (Purple)",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.customStyledPill)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Text (FT)",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.shortTextPill)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Medium Text (1X2)",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.winDrawWinMarket)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Text",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.longTextPill)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Over/Under 2.5",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.overUnderMarket)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Asian Handicap",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.handicapMarket)
        ))
    }

    private func addInteractiveStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Non-Interactive",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.standardPill)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Interactive",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.interactivePill)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Interactive Highlighted",
            view: createPillView(viewModel: MockMarketNamePillLabelViewModel.winDrawWinMarket)
        ))
    }

    // MARK: - Helper Methods

    private func createPillView(viewModel: MockMarketNamePillLabelViewModel) -> MarketNamePillLabelView {
        let view = MarketNamePillLabelView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 22)
        ])

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
#Preview("Styles") {
    MarketNamePillLabelViewSnapshotViewController(category: .styles)
}

#Preview("Content Variants") {
    MarketNamePillLabelViewSnapshotViewController(category: .contentVariants)
}

#Preview("Interactive States") {
    MarketNamePillLabelViewSnapshotViewController(category: .interactiveStates)
}
#endif
