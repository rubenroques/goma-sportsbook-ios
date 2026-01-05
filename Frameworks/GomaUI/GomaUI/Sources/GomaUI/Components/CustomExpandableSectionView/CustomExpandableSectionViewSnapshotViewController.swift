import UIKit

// MARK: - Snapshot Category
enum CustomExpandableSectionSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case contentVariants = "Content Variants"
}

final class CustomExpandableSectionViewSnapshotViewController: UIViewController {

    private let category: CustomExpandableSectionSnapshotCategory

    init(category: CustomExpandableSectionSnapshotCategory) {
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
        titleLabel.text = "CustomExpandableSectionView - \(category.rawValue)"
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
        // Collapsed state
        let collapsedSection = createSectionView(
            viewModel: MockCustomExpandableSectionViewModel.defaultCollapsed
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Collapsed",
            view: collapsedSection
        ))

        // Expanded state
        let expandedSection = createSectionView(
            viewModel: MockCustomExpandableSectionViewModel.defaultExpanded,
            contentText: "This is the expanded content that appears when the section is open."
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Expanded",
            view: expandedSection
        ))

        // Custom icon collapsed
        let customCollapsed = createSectionView(
            viewModel: MockCustomExpandableSectionViewModel.custom(
                title: "Payment Methods",
                icon: "creditcard",
                isExpanded: false
            )
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Icon (Collapsed)",
            view: customCollapsed
        ))

        // Custom icon expanded
        let customExpanded = createSectionView(
            viewModel: MockCustomExpandableSectionViewModel.custom(
                title: "Notifications",
                icon: "bell.fill",
                isExpanded: true
            ),
            contentText: "Manage your notification preferences here."
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Icon (Expanded)",
            view: customExpanded
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Long title
        let longTitleSection = createSectionView(
            viewModel: MockCustomExpandableSectionViewModel.custom(
                title: "This is a very long section title that might wrap",
                icon: "doc.text",
                isExpanded: false
            )
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title",
            view: longTitleSection
        ))

        // Multi-line content
        let multiLineSection = createSectionView(
            viewModel: MockCustomExpandableSectionViewModel.custom(
                title: "Help & Support",
                icon: "questionmark.circle",
                isExpanded: true
            ),
            contentText: "Contact us for assistance.\n\nEmail: support@example.com\nPhone: +1 234 567 890\n\nWe're available 24/7."
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multi-line Content",
            view: multiLineSection
        ))

        // No icon variant
        let noIconSection = createSectionView(
            viewModel: MockCustomExpandableSectionViewModel.custom(
                title: "No Icon Section",
                icon: nil,
                isExpanded: false
            )
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Leading Icon",
            view: noIconSection
        ))
    }

    // MARK: - Helper Methods

    private func createSectionView(
        viewModel: MockCustomExpandableSectionViewModel,
        contentText: String? = nil
    ) -> CustomExpandableSectionView {
        let sectionView = CustomExpandableSectionView(viewModel: viewModel)
        sectionView.translatesAutoresizingMaskIntoConstraints = false

        if let text = contentText {
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .regular, size: 13)
            label.textColor = StyleProvider.Color.textSecondary
            label.numberOfLines = 0
            sectionView.contentContainer.addArrangedSubview(label)
        }

        return sectionView
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
    CustomExpandableSectionViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Content Variants") {
    CustomExpandableSectionViewSnapshotViewController(category: .contentVariants)
}
#endif
