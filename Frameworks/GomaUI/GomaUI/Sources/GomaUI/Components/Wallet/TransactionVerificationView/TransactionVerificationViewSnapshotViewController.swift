import UIKit

// MARK: - Snapshot Category
enum TransactionVerificationViewSnapshotCategory: String, CaseIterable {
    case verificationVariants = "Verification Variants"
}

final class TransactionVerificationViewSnapshotViewController: UIViewController {

    private let category: TransactionVerificationViewSnapshotCategory

    init(category: TransactionVerificationViewSnapshotCategory) {
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
        titleLabel.text = "TransactionVerificationView - \(category.rawValue)"
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
        case .verificationVariants:
            addVerificationVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addVerificationVariants(to stackView: UIStackView) {
        // Default (USSD Push with spinner)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "USSD Push (with spinner)",
            view: createTransactionVerificationView(viewModel: MockTransactionVerificationViewModel.defaultMock)
        ))

        // Simple (Received prompt)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Simple (Received)",
            view: createTransactionVerificationView(viewModel: MockTransactionVerificationViewModel.simpleMock)
        ))
    }

    // MARK: - Helper Methods

    private func createTransactionVerificationView(viewModel: MockTransactionVerificationViewModel) -> TransactionVerificationView {
        let verificationView = TransactionVerificationView(viewModel: viewModel)
        verificationView.translatesAutoresizingMaskIntoConstraints = false
        verificationView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        return verificationView
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
#Preview("Verification Variants") {
    TransactionVerificationViewSnapshotViewController(category: .verificationVariants)
}
#endif
