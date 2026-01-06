import UIKit

// MARK: - Snapshot Category
enum NavigationActionViewSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case contentVariants = "Content Variants"
}

final class NavigationActionViewSnapshotViewController: UIViewController {

    private let category: NavigationActionViewSnapshotCategory

    init(category: NavigationActionViewSnapshotCategory) {
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
        titleLabel.text = "NavigationActionView - \(category.rawValue)"
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
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // Enabled - Open Betslip Details
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Enabled (Open Betslip)",
            view: createNavigationActionView(viewModel: MockNavigationActionViewModel.openBetslipDetailsMock())
        ))

        // Enabled - Share Betslip
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Enabled (Share)",
            view: createNavigationActionView(viewModel: MockNavigationActionViewModel.shareBetslipMock())
        ))

        // Disabled
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createNavigationActionView(viewModel: MockNavigationActionViewModel.disabledMock())
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short title
        let shortViewModel = MockNavigationActionViewModel(
            title: "Back",
            icon: "chevron.left",
            isEnabled: true
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Title",
            view: createNavigationActionView(viewModel: shortViewModel)
        ))

        // Long title
        let longViewModel = MockNavigationActionViewModel(
            title: "View All Transaction History",
            icon: "list.bullet.rectangle",
            isEnabled: true
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title",
            view: createNavigationActionView(viewModel: longViewModel)
        ))

        // Different icons
        let settingsViewModel = MockNavigationActionViewModel(
            title: "Settings",
            icon: "gearshape",
            isEnabled: true
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Settings Icon",
            view: createNavigationActionView(viewModel: settingsViewModel)
        ))

        let profileViewModel = MockNavigationActionViewModel(
            title: "My Profile",
            icon: "person.circle",
            isEnabled: true
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Profile Icon",
            view: createNavigationActionView(viewModel: profileViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createNavigationActionView(viewModel: MockNavigationActionViewModel) -> NavigationActionView {
        let navigationActionView = NavigationActionView(viewModel: viewModel)
        navigationActionView.translatesAutoresizingMaskIntoConstraints = false
        return navigationActionView
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
#Preview("Basic States") {
    NavigationActionViewSnapshotViewController(category: .basicStates)
}

#Preview("Content Variants") {
    NavigationActionViewSnapshotViewController(category: .contentVariants)
}
#endif
