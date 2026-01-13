import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum SearchHeaderInfoSnapshotCategory: String, CaseIterable {
    case searchStates = "Search States"
    case contentVariants = "Content Variants"
}

final class SearchHeaderInfoViewSnapshotViewController: UIViewController {

    private let category: SearchHeaderInfoSnapshotCategory

    init(category: SearchHeaderInfoSnapshotCategory) {
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
        titleLabel.text = "SearchHeaderInfoView - \(category.rawValue)"
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
        case .searchStates:
            addSearchStatesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSearchStatesVariants(to stackView: UIStackView) {
        // Loading state
        let loadingViewModel = MockSearchHeaderInfoViewModel(
            searchTerm: "Liverpool",
            categoryString: "Sports",
            showResultsString: "Showing results for",
            noResultsString: "No results for",
            searchingString: "Searching",
            state: .loading,
            count: nil
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Loading State",
            view: createSearchHeaderView(viewModel: loadingViewModel)
        ))

        // Results state with count
        let resultsWithCountViewModel = MockSearchHeaderInfoViewModel(
            searchTerm: "Liverpool",
            categoryString: "Sports",
            showResultsString: "Showing results for",
            noResultsString: "No results for",
            searchingString: "Searching",
            state: .results,
            count: 15
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Results with Count (15)",
            view: createSearchHeaderView(viewModel: resultsWithCountViewModel)
        ))

        // Results state without count
        let resultsNoCountViewModel = MockSearchHeaderInfoViewModel(
            searchTerm: "Liverpool",
            categoryString: "Sports",
            showResultsString: "Showing results for",
            noResultsString: "No results for",
            searchingString: "Searching",
            state: .results,
            count: nil
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Results without Count",
            view: createSearchHeaderView(viewModel: resultsNoCountViewModel)
        ))

        // No results state
        let noResultsViewModel = MockSearchHeaderInfoViewModel(
            searchTerm: "Liverpool",
            categoryString: "Sports",
            showResultsString: "Showing results for",
            noResultsString: "No results for",
            searchingString: "Searching",
            state: .noResults,
            count: nil
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Results State",
            view: createSearchHeaderView(viewModel: noResultsViewModel)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short search term
        let shortTermViewModel = MockSearchHeaderInfoViewModel(
            searchTerm: "FC",
            categoryString: "Teams",
            showResultsString: "Showing results for",
            noResultsString: "No results for",
            searchingString: "Searching",
            state: .results,
            count: 3
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Search Term",
            view: createSearchHeaderView(viewModel: shortTermViewModel)
        ))

        // Long search term
        let longTermViewModel = MockSearchHeaderInfoViewModel(
            searchTerm: "Manchester United Football Club",
            categoryString: "Teams",
            showResultsString: "Showing results for",
            noResultsString: "No results for",
            searchingString: "Searching",
            state: .results,
            count: 5
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Search Term",
            view: createSearchHeaderView(viewModel: longTermViewModel)
        ))

        // Different category
        let casinoViewModel = MockSearchHeaderInfoViewModel(
            searchTerm: "Jackpot",
            categoryString: "Casino Games",
            showResultsString: "Showing results for",
            noResultsString: "No results for",
            searchingString: "Searching",
            state: .results,
            count: 42
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Different Category (Casino)",
            view: createSearchHeaderView(viewModel: casinoViewModel)
        ))

        // Large result count
        let largeCountViewModel = MockSearchHeaderInfoViewModel(
            searchTerm: "Football",
            categoryString: "All",
            showResultsString: "Showing results for",
            noResultsString: "No results for",
            searchingString: "Searching",
            state: .results,
            count: 1250
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Large Result Count (1250)",
            view: createSearchHeaderView(viewModel: largeCountViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createSearchHeaderView(viewModel: MockSearchHeaderInfoViewModel) -> SearchHeaderInfoView {
        let view = SearchHeaderInfoView(viewModel: viewModel)
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
#Preview("Search States") {
    SearchHeaderInfoViewSnapshotViewController(category: .searchStates)
}

#Preview("Content Variants") {
    SearchHeaderInfoViewSnapshotViewController(category: .contentVariants)
}
#endif
