import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum InlineMatchCardSnapshotCategory: String, CaseIterable {
    case preLiveMatches = "Pre-Live Matches"
    case liveMatches = "Live Matches"
    case selectionStates = "Selection States"
    case specialStates = "Special States"
}

final class InlineMatchCardViewSnapshotViewController: UIViewController {

    private let category: InlineMatchCardSnapshotCategory

    init(category: InlineMatchCardSnapshotCategory) {
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
        titleLabel.text = "InlineMatchCardView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
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
        case .preLiveMatches:
            addPreLiveMatchesVariants(to: stackView)
        case .liveMatches:
            addLiveMatchesVariants(to: stackView)
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .specialStates:
            addSpecialStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addPreLiveMatchesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Football 3-Way (Today)",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.preLiveFootball)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Football 3-Way (Future Date)",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.preLiveFutureDate)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Production Mode (No Icons)",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.productionMode)
        ))
    }

    private func addLiveMatchesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Football (3-Way with Score)",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.liveFootball)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Tennis (2-Way with Score)",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.liveTennis)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Basketball (2-Way with Score)",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.liveBasketball)
        ))
    }

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Selection (Default)",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.preLiveFootball)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Selected Outcome",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.withSelectedOutcome)
        ))
    }

    private func addSpecialStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Locked Market",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.lockedMarket)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Production Mode (No Icons)",
            view: createCardView(viewModel: MockInlineMatchCardViewModel.productionMode)
        ))
    }

    // MARK: - Helper Methods

    private func createCardView(viewModel: MockInlineMatchCardViewModel) -> InlineMatchCardView {
        let view = InlineMatchCardView(viewModel: viewModel)
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
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Pre-Live Matches") {
    InlineMatchCardViewSnapshotViewController(category: .preLiveMatches)
}

#Preview("Live Matches") {
    InlineMatchCardViewSnapshotViewController(category: .liveMatches)
}

#Preview("Selection States") {
    InlineMatchCardViewSnapshotViewController(category: .selectionStates)
}

#Preview("Special States") {
    InlineMatchCardViewSnapshotViewController(category: .specialStates)
}
#endif
