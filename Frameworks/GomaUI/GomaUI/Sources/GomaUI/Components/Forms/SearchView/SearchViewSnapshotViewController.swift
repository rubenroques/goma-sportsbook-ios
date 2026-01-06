import UIKit

// MARK: - Snapshot Category
enum SearchViewSnapshotCategory: String, CaseIterable {
    case searchVariants = "Search Variants"
}

final class SearchViewSnapshotViewController: UIViewController {

    private let category: SearchViewSnapshotCategory

    init(category: SearchViewSnapshotCategory) {
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
        titleLabel.text = "SearchView - \(category.rawValue)"
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
        case .searchVariants:
            addSearchVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSearchVariants(to stackView: UIStackView) {
        // Default
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: createSearchView(viewModel: MockSearchViewModel.default)
        ))

        // Custom placeholder
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Placeholder",
            view: createSearchView(viewModel: MockSearchViewModel.withPlaceholder("Search for games..."))
        ))

        // With text entered
        let textEnteredVM = MockSearchViewModel()
        textEnteredVM.updateText("Football")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Text (clear button visible)",
            view: createSearchView(viewModel: textEnteredVM)
        ))

        // Long placeholder
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Placeholder",
            view: createSearchView(viewModel: MockSearchViewModel.withPlaceholder("Search in Casino and Sportsbook"))
        ))
    }

    // MARK: - Helper Methods

    private func createSearchView(viewModel: MockSearchViewModel) -> SearchView {
        let searchView = SearchView(viewModel: viewModel)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        return searchView
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
#Preview("Search Variants") {
    SearchViewSnapshotViewController(category: .searchVariants)
}
#endif
