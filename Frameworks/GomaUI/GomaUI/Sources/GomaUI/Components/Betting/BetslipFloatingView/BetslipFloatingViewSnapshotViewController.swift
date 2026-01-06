import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum BetslipFloatingSnapshotCategory: String, CaseIterable {
    case states = "Component States"
}

final class BetslipFloatingViewSnapshotViewController: UIViewController {

    private let category: BetslipFloatingSnapshotCategory

    init(category: BetslipFloatingSnapshotCategory) {
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
        titleLabel.text = "BetslipFloatingView - \(category.rawValue)"
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
        case .states:
            addStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addStatesVariants(to stackView: UIStackView) {
        // Tall View - With tickets state
        let tallView = BetslipFloatingTallView(viewModel: MockBetslipFloatingViewModel.withTicketsMock())
        tallView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tall View (With Tickets)",
            view: tallView
        ))

        // Thin View - With tickets state
        let thinView = BetslipFloatingThinView(viewModel: MockBetslipFloatingViewModel.withTicketsMock())
        thinView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Thin View (With Tickets)",
            view: thinView
        ))

        // Tall View - Many tickets
        let tallManyView = BetslipFloatingTallView(viewModel: MockBetslipFloatingViewModel.withTicketsMock(
            selectionCount: 5,
            odds: "12.50",
            winBoostPercentage: "20%",
            totalEligibleCount: 6,
            nextTierPercentage: nil
        ))
        tallManyView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tall View (Max Boost)",
            view: tallManyView
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
#Preview("Component States") {
    BetslipFloatingViewSnapshotViewController(category: .states)
}
#endif
