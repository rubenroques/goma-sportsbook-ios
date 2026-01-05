import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CompactOutcomesLineSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case specialStates = "Special States"
}

final class CompactOutcomesLineViewSnapshotViewController: UIViewController {

    private let category: CompactOutcomesLineSnapshotCategory

    init(category: CompactOutcomesLineSnapshotCategory) {
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
        titleLabel.text = "CompactOutcomesLineView - \(category.rawValue)"
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
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .specialStates:
            addSpecialStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // 3-way market
        stackView.addArrangedSubview(createLabeledVariant(
            label: "3-way Market (1X2)",
            view: CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.threeWayMarket)
        ))

        // 2-way market
        stackView.addArrangedSubview(createLabeledVariant(
            label: "2-way Market (Tennis)",
            view: CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.twoWayMarket)
        ))

        // Over/Under market
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Over/Under Market",
            view: CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.overUnderMarket)
        ))
    }

    private func addSpecialStatesVariants(to stackView: UIStackView) {
        // With selected outcome
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Selected Outcome",
            view: CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.withSelectedOutcome)
        ))

        // Locked market
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Locked Market",
            view: CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.lockedMarket)
        ))

        // With odds changes
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Odds Changes",
            view: CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.withOddsChanges)
        ))
    }

    // MARK: - Helper Methods

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
@available(iOS 17.0, *)
#Preview("Basic States") {
    CompactOutcomesLineViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Special States") {
    CompactOutcomesLineViewSnapshotViewController(category: .specialStates)
}
#endif
