import UIKit

// MARK: - Snapshot Category
enum MarketInfoLineViewSnapshotCategory: String, CaseIterable {
    case infoVariants = "Info Variants"
}

final class MarketInfoLineViewSnapshotViewController: UIViewController {

    private let category: MarketInfoLineViewSnapshotCategory

    init(category: MarketInfoLineViewSnapshotCategory) {
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
        titleLabel.text = "MarketInfoLineView - \(category.rawValue)"
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
        case .infoVariants:
            addInfoVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addInfoVariants(to stackView: UIStackView) {
        // Default
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (with icons)",
            view: createMarketInfoLineView(viewModel: MockMarketInfoLineViewModel.defaultMock)
        ))

        // Many Icons
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Many Icons",
            view: createMarketInfoLineView(viewModel: MockMarketInfoLineViewModel.manyIconsMock)
        ))

        // No Icons
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Icons",
            view: createMarketInfoLineView(viewModel: MockMarketInfoLineViewModel.noIconsMock)
        ))

        // No Count
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Count",
            view: createMarketInfoLineView(viewModel: MockMarketInfoLineViewModel.noCountMock)
        ))

        // Long Market Name
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Market Name",
            view: createMarketInfoLineView(viewModel: MockMarketInfoLineViewModel.longMarketNameMock)
        ))
    }

    // MARK: - Helper Methods

    private func createMarketInfoLineView(viewModel: MockMarketInfoLineViewModel) -> MarketInfoLineView {
        let infoView = MarketInfoLineView(viewModel: viewModel)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        return infoView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])

        let stack = UIStackView(arrangedSubviews: [labelView, containerView])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Info Variants") {
    MarketInfoLineViewSnapshotViewController(category: .infoVariants)
}
#endif
