import UIKit

// MARK: - Snapshot Category
enum QuickLinksTabBarSnapshotCategory: String, CaseIterable {
    case linkTypes = "Link Types"
}

final class QuickLinksTabBarSnapshotViewController: UIViewController {

    private let category: QuickLinksTabBarSnapshotCategory

    init(category: QuickLinksTabBarSnapshotCategory) {
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
        titleLabel.text = "QuickLinksTabBar - \(category.rawValue)"
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
        case .linkTypes:
            addLinkTypesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addLinkTypesVariants(to stackView: UIStackView) {
        // Gaming quick links (default)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Gaming Links (Default)",
            view: createQuickLinksTabBar(viewModel: MockQuickLinksTabBarViewModel.gamingMockViewModel)
        ))

        // Sports quick links
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sports Links",
            view: createQuickLinksTabBar(viewModel: MockQuickLinksTabBarViewModel.sportsMockViewModel)
        ))

        // Account quick links
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Account Links",
            view: createQuickLinksTabBar(viewModel: MockQuickLinksTabBarViewModel.accountMockViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createQuickLinksTabBar(viewModel: MockQuickLinksTabBarViewModel) -> QuickLinksTabBarView {
        let tabBarView = QuickLinksTabBarView(viewModel: viewModel)
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return tabBarView
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
#Preview("Link Types") {
    QuickLinksTabBarSnapshotViewController(category: .linkTypes)
}
#endif
