import UIKit

// MARK: - Snapshot Category
enum ToasterViewSnapshotCategory: String, CaseIterable {
    case toasterVariants = "Toaster Variants"
}

final class ToasterViewSnapshotViewController: UIViewController {

    private let category: ToasterViewSnapshotCategory

    init(category: ToasterViewSnapshotCategory) {
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
        titleLabel.text = "ToasterView - \(category.rawValue)"
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
        case .toasterVariants:
            addToasterVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addToasterVariants(to stackView: UIStackView) {
        // Default (Success)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Success)",
            view: createToasterView(viewModel: MockToasterViewModel())
        ))

        // Error toaster
        let errorData = ToasterData(
            title: "Bet placement failed",
            icon: "xmark.circle.fill",
            backgroundColor: StyleProvider.Color.alertError.withAlphaComponent(0.1),
            titleColor: StyleProvider.Color.alertError,
            iconColor: StyleProvider.Color.alertError,
            cornerRadius: 14
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Error",
            view: createToasterView(viewModel: MockToasterViewModel(data: errorData))
        ))

        // Warning toaster
        let warningData = ToasterData(
            title: "Session expiring soon",
            icon: "exclamationmark.triangle.fill",
            backgroundColor: StyleProvider.Color.alertWarning.withAlphaComponent(0.1),
            titleColor: StyleProvider.Color.alertWarning,
            iconColor: StyleProvider.Color.alertWarning,
            cornerRadius: 14
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Warning",
            view: createToasterView(viewModel: MockToasterViewModel(data: warningData))
        ))

        // Info toaster
        let infoData = ToasterData(
            title: "New promotions available",
            icon: "info.circle.fill",
            backgroundColor: StyleProvider.Color.highlightPrimary.withAlphaComponent(0.1),
            titleColor: StyleProvider.Color.highlightPrimary,
            iconColor: StyleProvider.Color.highlightPrimary,
            cornerRadius: 14
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Info",
            view: createToasterView(viewModel: MockToasterViewModel(data: infoData))
        ))

        // No icon
        let noIconData = ToasterData(
            title: "Simple notification message",
            icon: nil,
            backgroundColor: .white,
            titleColor: StyleProvider.Color.textPrimary,
            iconColor: .clear,
            cornerRadius: 14
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Icon",
            view: createToasterView(viewModel: MockToasterViewModel(data: noIconData))
        ))
    }

    // MARK: - Helper Methods

    private func createToasterView(viewModel: MockToasterViewModel) -> ToasterView {
        let toaster = ToasterView(viewModel: viewModel)
        toaster.translatesAutoresizingMaskIntoConstraints = false
        return toaster
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
#Preview("Toaster Variants") {
    ToasterViewSnapshotViewController(category: .toasterVariants)
}
#endif
