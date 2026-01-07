import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum BetslipHeaderSnapshotCategory: String, CaseIterable {
    case authStates = "Authentication States"
}

final class BetslipHeaderViewSnapshotViewController: UIViewController {

    private let category: BetslipHeaderSnapshotCategory

    init(category: BetslipHeaderSnapshotCategory) {
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
        titleLabel.text = "BetslipHeaderView - \(category.rawValue)"
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
        case .authStates:
            addAuthStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addAuthStatesVariants(to stackView: UIStackView) {
        // Not logged in
        let notLoggedInView = BetslipHeaderView(viewModel: MockBetslipHeaderViewModel.notLoggedInMock())
        notLoggedInView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Not Logged In",
            view: notLoggedInView
        ))

        // Logged in with balance
        let loggedInView = BetslipHeaderView(viewModel: MockBetslipHeaderViewModel.loggedInMock(balance: "XAF 25,000"))
        loggedInView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Logged In (Balance: XAF 25,000)",
            view: loggedInView
        ))

        // Logged in with large balance
        let largeBalanceView = BetslipHeaderView(viewModel: MockBetslipHeaderViewModel.loggedInMock(balance: "XAF 1,250,000"))
        largeBalanceView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Logged In (Large Balance)",
            view: largeBalanceView
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
#Preview("Authentication States") {
    BetslipHeaderViewSnapshotViewController(category: .authStates)
}
#endif
