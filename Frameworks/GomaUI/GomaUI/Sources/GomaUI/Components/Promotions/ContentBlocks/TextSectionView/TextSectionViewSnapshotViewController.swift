import UIKit

// MARK: - Snapshot Category
enum TextSectionViewSnapshotCategory: String, CaseIterable {
    case contentVariants = "Content Variants"
}

final class TextSectionViewSnapshotViewController: UIViewController {

    private let category: TextSectionViewSnapshotCategory

    init(category: TextSectionViewSnapshotCategory) {
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
        titleLabel.text = "TextSectionView - \(category.rawValue)"
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
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addContentVariants(to stackView: UIStackView) {
        // Default
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: createTextSectionView(viewModel: MockTextSectionViewModel.default)
        ))

        // Short content
        let shortViewModel = MockTextSectionViewModel.custom(
            title: "Quick Tip",
            description: "Bet responsibly."
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Content",
            view: createTextSectionView(viewModel: shortViewModel)
        ))

        // Custom colors
        let customColorViewModel = MockTextSectionViewModel.custom(
            title: "Special Offer",
            description: "Get 100% bonus on your first deposit up to $200!",
            titleColor: StyleProvider.Color.alertSuccess,
            descriptionColor: StyleProvider.Color.textSecondary
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Colors",
            view: createTextSectionView(viewModel: customColorViewModel)
        ))

        // Large spacing
        let largeSpacingViewModel = MockTextSectionViewModel.custom(
            title: "Terms & Conditions",
            description: "By using our services, you agree to our terms and conditions.",
            spacing: 16
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Large Spacing",
            view: createTextSectionView(viewModel: largeSpacingViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createTextSectionView(viewModel: MockTextSectionViewModel) -> TextSectionView {
        let sectionView = TextSectionView(viewModel: viewModel)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
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
#Preview("Content Variants") {
    TextSectionViewSnapshotViewController(category: .contentVariants)
}
#endif
