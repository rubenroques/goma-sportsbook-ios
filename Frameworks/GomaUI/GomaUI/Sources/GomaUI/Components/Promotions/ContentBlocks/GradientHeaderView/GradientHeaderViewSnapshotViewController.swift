import UIKit

// MARK: - Snapshot Category
enum GradientHeaderViewSnapshotCategory: String, CaseIterable {
    case gradientVariants = "Gradient Variants"
}

final class GradientHeaderViewSnapshotViewController: UIViewController {

    private let category: GradientHeaderViewSnapshotCategory

    init(category: GradientHeaderViewSnapshotCategory) {
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
        titleLabel.text = "GradientHeaderView - \(category.rawValue)"
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
        case .gradientVariants:
            addGradientVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addGradientVariants(to stackView: UIStackView) {
        // Default (Orange/Red)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Orange/Red)",
            view: createGradientHeaderView(viewModel: MockGradientHeaderViewModel.defaultMock)
        ))

        // Blue Gradient
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Blue Gradient",
            view: createGradientHeaderView(viewModel: MockGradientHeaderViewModel.blueGradientMock)
        ))

        // Purple Gradient
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Purple Gradient",
            view: createGradientHeaderView(viewModel: MockGradientHeaderViewModel.purpleGradientMock)
        ))

        // Long Title
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title",
            view: createGradientHeaderView(viewModel: MockGradientHeaderViewModel.longTitleMock)
        ))
    }

    // MARK: - Helper Methods

    private func createGradientHeaderView(viewModel: MockGradientHeaderViewModel) -> GradientHeaderView {
        let headerView = GradientHeaderView(viewModel: viewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
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
#Preview("Gradient Variants") {
    GradientHeaderViewSnapshotViewController(category: .gradientVariants)
}
#endif
