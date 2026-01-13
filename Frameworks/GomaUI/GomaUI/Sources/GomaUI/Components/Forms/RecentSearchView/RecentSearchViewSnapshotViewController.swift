import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum RecentSearchSnapshotCategory: String, CaseIterable {
    case contentVariants = "Content Variants"
    case multipleItems = "Multiple Items"
}

final class RecentSearchViewSnapshotViewController: UIViewController {

    private let category: RecentSearchSnapshotCategory

    init(category: RecentSearchSnapshotCategory) {
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
        titleLabel.text = "RecentSearchView - \(category.rawValue)"
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
        case .contentVariants:
            addContentVariants(to: stackView)
        case .multipleItems:
            addMultipleItemsVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addContentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Text",
            view: createRecentSearchView(searchText: "PSG")
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Medium Text",
            view: createRecentSearchView(searchText: "Liverpool FC")
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Text",
            view: createRecentSearchView(searchText: "Manchester United vs Real Madrid")
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Very Long Text (Truncation)",
            view: createRecentSearchView(searchText: "UEFA Champions League Final 2024 Barcelona vs Manchester City")
        ))
    }

    private func addMultipleItemsVariants(to stackView: UIStackView) {
        let listStack = UIStackView()
        listStack.axis = .vertical
        listStack.spacing = 0
        listStack.alignment = .fill

        listStack.addArrangedSubview(createRecentSearchView(searchText: "Liverpool"))
        listStack.addArrangedSubview(createRecentSearchView(searchText: "Manchester United"))
        listStack.addArrangedSubview(createRecentSearchView(searchText: "Premier League"))
        listStack.addArrangedSubview(createRecentSearchView(searchText: "Champions League"))
        listStack.addArrangedSubview(createRecentSearchView(searchText: "Arsenal"))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Search History List (5 Items)",
            view: listStack
        ))
    }

    // MARK: - Helper Methods

    private func createRecentSearchView(searchText: String) -> RecentSearchView {
        let viewModel = MockRecentSearchViewModel(searchText: searchText)
        let view = RecentSearchView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
#Preview("Content Variants") {
    RecentSearchViewSnapshotViewController(category: .contentVariants)
}

#Preview("Multiple Items") {
    RecentSearchViewSnapshotViewController(category: .multipleItems)
}
#endif
