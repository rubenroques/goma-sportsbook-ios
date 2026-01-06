import UIKit

// MARK: - Snapshot Category
enum UserLimitCardViewSnapshotCategory: String, CaseIterable {
    case limitVariants = "Limit Variants"
}

final class UserLimitCardViewSnapshotViewController: UIViewController {

    private let category: UserLimitCardViewSnapshotCategory

    init(category: UserLimitCardViewSnapshotCategory) {
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
        titleLabel.text = "UserLimitCardView - \(category.rawValue)"
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
        case .limitVariants:
            addLimitVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addLimitVariants(to stackView: UIStackView) {
        // Daily Limit (Removal)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Daily Limit (Removal)",
            view: createUserLimitCardView(viewModel: MockUserLimitCardViewModel.removalMock())
        ))

        // Weekly Limit (Disabled)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Weekly Limit (Disabled)",
            view: createUserLimitCardView(viewModel: MockUserLimitCardViewModel.disabledMock())
        ))

        // Custom - Monthly Limit
        let monthlyVM = MockUserLimitCardViewModel(
            limitId: "limit_monthly",
            typeText: "Monthly",
            valueText: "100.00 XAF",
            actionButtonTitle: "Remove",
            buttonStyle: .solidBackground
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Monthly Limit",
            view: createUserLimitCardView(viewModel: monthlyVM)
        ))

        // Custom - High Value
        let highValueVM = MockUserLimitCardViewModel(
            limitId: "limit_high",
            typeText: "Daily",
            valueText: "10,000.00 XAF",
            actionButtonTitle: "Remove",
            buttonStyle: .solidBackground
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "High Value Limit",
            view: createUserLimitCardView(viewModel: highValueVM)
        ))
    }

    // MARK: - Helper Methods

    private func createUserLimitCardView(viewModel: MockUserLimitCardViewModel) -> UserLimitCardView {
        let limitView = UserLimitCardView(viewModel: viewModel)
        limitView.translatesAutoresizingMaskIntoConstraints = false
        return limitView
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
#Preview("Limit Variants") {
    UserLimitCardViewSnapshotViewController(category: .limitVariants)
}
#endif
