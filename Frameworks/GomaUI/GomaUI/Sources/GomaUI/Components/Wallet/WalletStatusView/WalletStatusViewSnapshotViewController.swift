import UIKit

// MARK: - Snapshot Category
enum WalletStatusViewSnapshotCategory: String, CaseIterable {
    case balanceVariants = "Balance Variants"
}

final class WalletStatusViewSnapshotViewController: UIViewController {

    private let category: WalletStatusViewSnapshotCategory

    init(category: WalletStatusViewSnapshotCategory) {
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
        titleLabel.text = "WalletStatusView - \(category.rawValue)"
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
        case .balanceVariants:
            addBalanceVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBalanceVariants(to stackView: UIStackView) {
        // Default
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: createWalletStatusView(viewModel: MockWalletStatusViewModel.defaultMock)
        ))

        // Empty Balance
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty Balance",
            view: createWalletStatusView(viewModel: MockWalletStatusViewModel.emptyBalanceMock)
        ))

        // High Balance
        stackView.addArrangedSubview(createLabeledVariant(
            label: "High Balance",
            view: createWalletStatusView(viewModel: MockWalletStatusViewModel.highBalanceMock)
        ))

        // Bonus Only
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Bonus Only",
            view: createWalletStatusView(viewModel: MockWalletStatusViewModel.bonusOnlyMock)
        ))
    }

    // MARK: - Helper Methods

    private func createWalletStatusView(viewModel: MockWalletStatusViewModel) -> WalletStatusView {
        let statusView = WalletStatusView(viewModel: viewModel)
        statusView.translatesAutoresizingMaskIntoConstraints = false
        return statusView
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
@available(iOS 17.0, *)
#Preview("Balance Variants") {
    WalletStatusViewSnapshotViewController(category: .balanceVariants)
}
#endif
