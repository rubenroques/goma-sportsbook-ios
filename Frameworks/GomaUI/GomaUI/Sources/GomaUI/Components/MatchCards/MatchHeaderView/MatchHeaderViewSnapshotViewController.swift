import UIKit

// MARK: - Snapshot Category
enum MatchHeaderViewSnapshotCategory: String, CaseIterable {
    case headerVariants = "Header Variants"
    case visibilityVariants = "Visibility Variants"
}

final class MatchHeaderViewSnapshotViewController: UIViewController {

    private let category: MatchHeaderViewSnapshotCategory

    init(category: MatchHeaderViewSnapshotCategory) {
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
        titleLabel.text = "MatchHeaderView - \(category.rawValue)"
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
        case .visibilityVariants:
            addVisibilityVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addHeaderVariants(to stackView: UIStackView) {
        // Default
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: createMatchHeaderView(viewModel: MockMatchHeaderViewModel.defaultMock)
        ))

        // Premier League
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Premier League",
            view: createMatchHeaderView(viewModel: MockMatchHeaderViewModel.premierLeagueHeader)
        ))

        // La Liga Favorite (Live)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "La Liga Favorite (Live)",
            view: createMatchHeaderView(viewModel: MockMatchHeaderViewModel.laLigaFavoriteHeader)
        ))

        // Long Name
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Name",
            view: createMatchHeaderView(viewModel: MockMatchHeaderViewModel.longNameHeader)
        ))

        // Basic (No Images)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Basic (No Images)",
            view: createMatchHeaderView(viewModel: MockMatchHeaderViewModel.basicHeader)
        ))
    }

    private func addVisibilityVariants(to stackView: UIStackView) {
        // No Country Flag
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Country Flag",
            view: createMatchHeaderView(viewModel: MockMatchHeaderViewModel.noCountryFlagHeader)
        ))

        // No Sport Icon
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Sport Icon",
            view: createMatchHeaderView(viewModel: MockMatchHeaderViewModel.noSportIconHeader)
        ))

        // No Favorite Button
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Favorite Button",
            view: createMatchHeaderView(viewModel: MockMatchHeaderViewModel.noFavoriteButtonHeader)
        ))

        // Minimal (Text Only)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Minimal (Text Only)",
            view: createMatchHeaderView(viewModel: MockMatchHeaderViewModel.minimalVisibilityHeader)
        ))
    }

    // MARK: - Helper Methods

    private func createMatchHeaderView(viewModel: MockMatchHeaderViewModel) -> MatchHeaderView {
        let headerView = MatchHeaderView(viewModel: viewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
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
#Preview("Header Variants") {
    MatchHeaderViewSnapshotViewController(category: .headerVariants)
}

@available(iOS 17.0, *)
#Preview("Visibility Variants") {
    MatchHeaderViewSnapshotViewController(category: .visibilityVariants)
}
#endif
