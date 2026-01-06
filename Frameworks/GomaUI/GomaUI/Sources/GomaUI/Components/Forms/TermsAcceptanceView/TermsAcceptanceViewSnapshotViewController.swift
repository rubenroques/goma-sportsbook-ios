import UIKit

// MARK: - Snapshot Category
enum TermsAcceptanceViewSnapshotCategory: String, CaseIterable {
    case acceptanceStates = "Acceptance States"
}

final class TermsAcceptanceViewSnapshotViewController: UIViewController {

    private let category: TermsAcceptanceViewSnapshotCategory

    init(category: TermsAcceptanceViewSnapshotCategory) {
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
        titleLabel.text = "TermsAcceptanceView - \(category.rawValue)"
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
        case .acceptanceStates:
            addAcceptanceStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addAcceptanceStatesVariants(to stackView: UIStackView) {
        // Default (not accepted)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Not Accepted)",
            view: createTermsAcceptanceView(viewModel: MockTermsAcceptanceViewModel.defaultMock)
        ))

        // Accepted
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Accepted",
            view: createTermsAcceptanceView(viewModel: MockTermsAcceptanceViewModel.acceptedMock)
        ))

        // Short text
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Text",
            view: createTermsAcceptanceView(viewModel: MockTermsAcceptanceViewModel.shortTextMock)
        ))
    }

    // MARK: - Helper Methods

    private func createTermsAcceptanceView(viewModel: MockTermsAcceptanceViewModel) -> TermsAcceptanceView {
        let termsView = TermsAcceptanceView(viewModel: viewModel)
        termsView.translatesAutoresizingMaskIntoConstraints = false
        return termsView
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
#Preview("Acceptance States") {
    TermsAcceptanceViewSnapshotViewController(category: .acceptanceStates)
}
#endif
