import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum BetslipOddsBoostHeaderSnapshotCategory: String, CaseIterable {
    case boostStates = "Boost States"
}

final class BetslipOddsBoostHeaderViewSnapshotViewController: UIViewController {

    private let category: BetslipOddsBoostHeaderSnapshotCategory

    init(category: BetslipOddsBoostHeaderSnapshotCategory) {
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
        titleLabel.text = "BetslipOddsBoostHeaderView - \(category.rawValue)"
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
        case .boostStates:
            addBoostStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBoostStatesVariants(to stackView: UIStackView) {
        // Active state (partial progress)
        let activeView = BetslipOddsBoostHeaderView(viewModel: MockBetslipOddsBoostHeaderViewModel.activeMock())
        activeView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Active (1/3 selections)",
            view: activeView
        ))

        // Max boost reached
        let maxBoostView = BetslipOddsBoostHeaderView(viewModel: MockBetslipOddsBoostHeaderViewModel.maxBoostMock())
        maxBoostView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Max Boost Reached",
            view: maxBoostView
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
#Preview("Boost States") {
    BetslipOddsBoostHeaderViewSnapshotViewController(category: .boostStates)
}
#endif
