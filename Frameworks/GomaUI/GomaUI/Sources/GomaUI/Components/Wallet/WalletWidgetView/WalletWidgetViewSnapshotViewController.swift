import UIKit

// MARK: - Snapshot Category
enum WalletWidgetViewSnapshotCategory: String, CaseIterable {
    case widgetVariants = "Widget Variants"
}

final class WalletWidgetViewSnapshotViewController: UIViewController {

    private let category: WalletWidgetViewSnapshotCategory

    init(category: WalletWidgetViewSnapshotCategory) {
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
        titleLabel.text = "WalletWidgetView - \(category.rawValue)"
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
        case .widgetVariants:
            addWidgetVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addWidgetVariants(to stackView: UIStackView) {
        // Default
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: createWalletWidgetView(viewModel: MockWalletWidgetViewModel.defaultMock)
        ))

        // Low Balance
        let lowBalanceVM = MockWalletWidgetViewModel(walletData: WalletWidgetData(
            id: .wallet,
            balance: "50.00",
            depositButtonTitle: "DEPOSIT"
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Low Balance",
            view: createWalletWidgetView(viewModel: lowBalanceVM)
        ))

        // High Balance
        let highBalanceVM = MockWalletWidgetViewModel(walletData: WalletWidgetData(
            id: .wallet,
            balance: "125,000.00",
            depositButtonTitle: "DEPOSIT"
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "High Balance",
            view: createWalletWidgetView(viewModel: highBalanceVM)
        ))

        // Zero Balance
        let zeroBalanceVM = MockWalletWidgetViewModel(walletData: WalletWidgetData(
            id: .wallet,
            balance: "0.00",
            depositButtonTitle: "DEPOSIT"
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Zero Balance",
            view: createWalletWidgetView(viewModel: zeroBalanceVM)
        ))
    }

    // MARK: - Helper Methods

    private func createWalletWidgetView(viewModel: MockWalletWidgetViewModel) -> WalletWidgetView {
        let widgetView = WalletWidgetView(viewModel: viewModel)
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        return widgetView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])

        let stack = UIStackView(arrangedSubviews: [labelView, containerView])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Widget Variants") {
    WalletWidgetViewSnapshotViewController(category: .widgetVariants)
}
#endif
