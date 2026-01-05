import UIKit

// MARK: - Snapshot Category
enum CustomNavigationSnapshotCategory: String, CaseIterable {
    case basicStyles = "Basic Styles"
}

final class CustomNavigationViewSnapshotViewController: UIViewController {

    private let category: CustomNavigationSnapshotCategory

    init(category: CustomNavigationSnapshotCategory) {
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
        titleLabel.text = "CustomNavigationView - \(category.rawValue)"
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
        case .basicStyles:
            addBasicStylesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStylesVariants(to stackView: UIStackView) {
        // Default style
        let defaultNav = createNavigationView(viewModel: MockCustomNavigationViewModel.defaultMock)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default Style",
            view: defaultNav
        ))

        // Blue style
        let blueNav = createNavigationView(viewModel: MockCustomNavigationViewModel.blueMock)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Blue Style",
            view: blueNav
        ))

        // Custom green style
        let greenData = CustomNavigationData(
            logoImage: nil,
            closeIcon: nil,
            backgroundColor: UIColor.systemGreen,
            closeButtonBackgroundColor: .clear,
            closeIconTintColor: .white
        )
        let greenNav = createNavigationView(viewModel: MockCustomNavigationViewModel(data: greenData))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Green Style (No Logo)",
            view: greenNav
        ))

        // Dark style
        let darkData = CustomNavigationData(
            logoImage: nil,
            closeIcon: nil,
            backgroundColor: UIColor.black,
            closeButtonBackgroundColor: UIColor.darkGray,
            closeIconTintColor: .white
        )
        let darkNav = createNavigationView(viewModel: MockCustomNavigationViewModel(data: darkData))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Dark Style",
            view: darkNav
        ))
    }

    // MARK: - Helper Methods

    private func createNavigationView(viewModel: MockCustomNavigationViewModel) -> CustomNavigationView {
        let navView = CustomNavigationView(viewModel: viewModel)
        navView.translatesAutoresizingMaskIntoConstraints = false
        return navView
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
#Preview("Basic Styles") {
    CustomNavigationViewSnapshotViewController(category: .basicStyles)
}
#endif
