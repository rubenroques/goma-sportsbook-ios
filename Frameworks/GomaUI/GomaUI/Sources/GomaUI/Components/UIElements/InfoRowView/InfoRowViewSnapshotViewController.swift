import UIKit

// MARK: - Snapshot Category
enum InfoRowViewSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case styleVariants = "Style Variants"
}

final class InfoRowViewSnapshotViewController: UIViewController {

    private let category: InfoRowViewSnapshotCategory

    init(category: InfoRowViewSnapshotCategory) {
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
        titleLabel.text = "InfoRowView - \(category.rawValue)"
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
        case .styleVariants:
            addStyleVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // Default - Your Deposit
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Deposit)",
            view: createInfoRowView(viewModel: MockInfoRowViewModel.defaultMock)
        ))

        // Balance
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Balance",
            view: createInfoRowView(viewModel: MockInfoRowViewModel.balanceMock)
        ))

        // Custom Background
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Background (Bonus)",
            view: createInfoRowView(viewModel: MockInfoRowViewModel.customBackgroundMock)
        ))
    }

    private func addStyleVariants(to stackView: UIStackView) {
        // Short values
        let shortData = InfoRowData(leftText: "Min", rightText: "XAF 100")
        let shortViewModel = MockInfoRowViewModel(data: shortData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Values",
            view: createInfoRowView(viewModel: shortViewModel)
        ))

        // Long values
        let longData = InfoRowData(
            leftText: "Maximum Withdrawal Amount Per Day",
            rightText: "XAF 1,000,000"
        )
        let longViewModel = MockInfoRowViewModel(data: longData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Values",
            view: createInfoRowView(viewModel: longViewModel)
        ))

        // Success styling
        let successData = InfoRowData(
            leftText: "Transaction Status",
            rightText: "Completed",
            leftTextColor: StyleProvider.Color.textPrimary,
            rightTextColor: StyleProvider.Color.highlightTertiary,
            backgroundColor: StyleProvider.Color.highlightTertiary.withAlphaComponent(0.1)
        )
        let successViewModel = MockInfoRowViewModel(data: successData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Success Styling",
            view: createInfoRowView(viewModel: successViewModel)
        ))

        // Warning styling
        let warningData = InfoRowData(
            leftText: "Pending Amount",
            rightText: "XAF 5,000",
            leftTextColor: StyleProvider.Color.textPrimary,
            rightTextColor: StyleProvider.Color.highlightSecondary,
            backgroundColor: StyleProvider.Color.highlightSecondary.withAlphaComponent(0.1)
        )
        let warningViewModel = MockInfoRowViewModel(data: warningData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Warning Styling",
            view: createInfoRowView(viewModel: warningViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createInfoRowView(viewModel: MockInfoRowViewModel) -> InfoRowView {
        let infoRowView = InfoRowView(viewModel: viewModel)
        infoRowView.translatesAutoresizingMaskIntoConstraints = false
        return infoRowView
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
#Preview("Basic States") {
    InfoRowViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Style Variants") {
    InfoRowViewSnapshotViewController(category: .styleVariants)
}
#endif
