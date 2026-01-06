import UIKit

// MARK: - Snapshot Category
enum PromotionalHeaderViewSnapshotCategory: String, CaseIterable {
    case headerVariants = "Header Variants"
}

final class PromotionalHeaderViewSnapshotViewController: UIViewController {

    private let category: PromotionalHeaderViewSnapshotCategory

    init(category: PromotionalHeaderViewSnapshotCategory) {
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
        titleLabel.text = "PromotionalHeaderView - \(category.rawValue)"
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
        case .headerVariants:
            addHeaderVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addHeaderVariants(to stackView: UIStackView) {
        // Default
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: createPromotionalHeaderView(viewModel: MockPromotionalHeaderViewModel.defaultMock)
        ))

        // No subtitle
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Welcome Bonus",
            view: createPromotionalHeaderView(viewModel: MockPromotionalHeaderViewModel.noSubtitleMock)
        ))
    }

    // MARK: - Helper Methods

    private func createPromotionalHeaderView(viewModel: MockPromotionalHeaderViewModel) -> PromotionalHeaderView {
        let headerView = PromotionalHeaderView(viewModel: viewModel)
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
#Preview("Header Variants") {
    PromotionalHeaderViewSnapshotViewController(category: .headerVariants)
}
#endif
