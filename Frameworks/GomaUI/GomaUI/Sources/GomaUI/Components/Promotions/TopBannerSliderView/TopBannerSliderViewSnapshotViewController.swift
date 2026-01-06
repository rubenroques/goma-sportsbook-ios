import UIKit

// MARK: - Snapshot Category
enum TopBannerSliderViewSnapshotCategory: String, CaseIterable {
    case bannerVariants = "Banner Variants"
}

final class TopBannerSliderViewSnapshotViewController: UIViewController {

    private let category: TopBannerSliderViewSnapshotCategory

    init(category: TopBannerSliderViewSnapshotCategory) {
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
        titleLabel.text = "TopBannerSliderView - \(category.rawValue)"
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
        // Single banner
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Banner",
            view: createTopBannerSliderView(viewModel: MockTopBannerSliderViewModel.singleBannerMock)
        ))

        // Multiple banners (default)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Banners",
            view: createTopBannerSliderView(viewModel: MockTopBannerSliderViewModel.defaultMock)
        ))

        // No indicators
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Indicators",
            view: createTopBannerSliderView(viewModel: MockTopBannerSliderViewModel.noIndicatorsMock)
        ))
    }

    // MARK: - Helper Methods

    private func createTopBannerSliderView(viewModel: MockTopBannerSliderViewModel) -> TopBannerSliderView {
        let slider = TopBannerSliderView(viewModel: viewModel)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
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
    TopBannerSliderViewSnapshotViewController(category: .bannerVariants)
}
#endif
