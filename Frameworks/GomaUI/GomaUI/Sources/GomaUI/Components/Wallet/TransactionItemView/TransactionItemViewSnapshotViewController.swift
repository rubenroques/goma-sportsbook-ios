import UIKit

// MARK: - Snapshot Category
enum TransactionItemViewSnapshotCategory: String, CaseIterable {
    case transactionTypes = "Transaction Types"
}

final class TransactionItemViewSnapshotViewController: UIViewController {

    private let category: TransactionItemViewSnapshotCategory

    init(category: TransactionItemViewSnapshotCategory) {
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
        titleLabel.text = "TransactionItemView - \(category.rawValue)"
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
        case .transactionTypes:
            addTransactionTypesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addTransactionTypesVariants(to stackView: UIStackView) {
        // Deposit
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Deposit",
            view: createTransactionItemView(viewModel: MockTransactionItemViewModel.depositMock)
        ))

        // Withdrawal
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Withdrawal",
            view: createTransactionItemView(viewModel: MockTransactionItemViewModel.withdrawalMock)
        ))

        // Bet Placed
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Bet Placed",
            view: createTransactionItemView(viewModel: MockTransactionItemViewModel.betPlacedMock)
        ))

        // Bet Won
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Bet Won",
            view: createTransactionItemView(viewModel: MockTransactionItemViewModel.betWonMock)
        ))

        // Tax
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tax",
            view: createTransactionItemView(viewModel: MockTransactionItemViewModel.taxMock)
        ))
    }

    // MARK: - Helper Methods

    private func createTransactionItemView(viewModel: MockTransactionItemViewModel) -> TransactionItemView {
        let transactionView = TransactionItemView(viewModel: viewModel)
        transactionView.translatesAutoresizingMaskIntoConstraints = false
        return transactionView
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
#Preview("Transaction Types") {
    TransactionItemViewSnapshotViewController(category: .transactionTypes)
}
#endif
