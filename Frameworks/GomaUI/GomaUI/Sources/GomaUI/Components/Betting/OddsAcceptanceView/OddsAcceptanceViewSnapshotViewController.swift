import UIKit

// MARK: - Snapshot Category
enum OddsAcceptanceViewSnapshotCategory: String, CaseIterable {
    case acceptanceStates = "Acceptance States"
    case linkStates = "Link States"
}

final class OddsAcceptanceViewSnapshotViewController: UIViewController {

    private let category: OddsAcceptanceViewSnapshotCategory

    init(category: OddsAcceptanceViewSnapshotCategory) {
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
        titleLabel.text = "OddsAcceptanceView - \(category.rawValue)"
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
        case .linkStates:
            addLinkStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addAcceptanceStatesVariants(to stackView: UIStackView) {
        // Not Accepted (default)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Not Accepted (Default)",
            view: createOddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.notAcceptedMock())
        ))

        // Accepted
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Accepted",
            view: createOddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.acceptedMock())
        ))

        // Disabled
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createOddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.disabledMock())
        ))
    }

    private func addLinkStatesVariants(to stackView: UIStackView) {
        // Non-tappable link (default behavior)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Link Not Tappable (Default)",
            view: createOddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel(state: .notAccepted, isLinkTappable: false))
        ))

        // Tappable link (with underline)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Link Tappable (Underlined)",
            view: createOddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel(state: .notAccepted, isLinkTappable: true))
        ))
    }

    // MARK: - Helper Methods

    private func createOddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel) -> OddsAcceptanceView {
        let oddsAcceptanceView = OddsAcceptanceView(viewModel: viewModel)
        oddsAcceptanceView.translatesAutoresizingMaskIntoConstraints = false
        return oddsAcceptanceView
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
    OddsAcceptanceViewSnapshotViewController(category: .acceptanceStates)
}

#Preview("Link States") {
    OddsAcceptanceViewSnapshotViewController(category: .linkStates)
}
#endif
