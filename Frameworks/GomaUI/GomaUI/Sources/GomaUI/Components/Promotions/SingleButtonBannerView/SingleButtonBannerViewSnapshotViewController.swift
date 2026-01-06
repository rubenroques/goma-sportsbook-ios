import UIKit

// MARK: - Snapshot Category
enum SingleButtonBannerViewSnapshotCategory: String, CaseIterable {
    case bannerVariants = "Banner Variants"
}

final class SingleButtonBannerViewSnapshotViewController: UIViewController {

    private let category: SingleButtonBannerViewSnapshotCategory

    init(category: SingleButtonBannerViewSnapshotCategory) {
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
        titleLabel.text = "SingleButtonBannerView - \(category.rawValue)"
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
        case .bannerVariants:
            addBannerVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBannerVariants(to stackView: UIStackView) {
        // Default with button
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (With Button)",
            view: createSingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.defaultMock)
        ))

        // No button
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Button",
            view: createSingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.noButtonMock)
        ))

        // Custom styled
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Styled",
            view: createSingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.customStyledMock)
        ))

        // Disabled
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createSingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.disabledMock)
        ))
    }

    // MARK: - Helper Methods

    private func createSingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel) -> SingleButtonBannerView {
        let bannerView = SingleButtonBannerView(viewModel: viewModel)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        return bannerView
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
#Preview("Banner Variants") {
    SingleButtonBannerViewSnapshotViewController(category: .bannerVariants)
}
#endif
