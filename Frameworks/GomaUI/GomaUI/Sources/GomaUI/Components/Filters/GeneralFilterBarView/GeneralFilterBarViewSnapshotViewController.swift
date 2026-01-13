import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum GeneralFilterBarSnapshotCategory: String, CaseIterable {
    case defaultConfiguration = "Default Configuration"
    case filterTypeCombinations = "Filter Type Combinations"
    case itemCountVariants = "Item Count Variants"
    case mainFilterStates = "Main Filter States"
}

final class GeneralFilterBarViewSnapshotViewController: UIViewController {

    private let category: GeneralFilterBarSnapshotCategory

    init(category: GeneralFilterBarSnapshotCategory) {
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
        titleLabel.text = "GeneralFilterBarView - \(category.rawValue)"
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
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .defaultConfiguration:
            addDefaultConfigurationVariants(to: stackView)
        case .filterTypeCombinations:
            addFilterTypeCombinationsVariants(to: stackView)
        case .itemCountVariants:
            addItemCountVariants(to: stackView)
        case .mainFilterStates:
            addMainFilterStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addDefaultConfigurationVariants(to stackView: UIStackView) {
        // Standard configuration with all filter types
        let defaultItems = [
            FilterOptionItem(type: .sport, title: "Football", icon: "soccerball"),
            FilterOptionItem(type: .sortBy, title: "Popular", icon: "star.fill"),
            FilterOptionItem(type: .league, title: "All Leagues", icon: "list.bullet")
        ]
        let defaultMainFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "line.3.horizontal.decrease", actionIcon: "chevron.down")

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Standard (Sport + SortBy + League)",
            view: createFilterBarView(items: defaultItems, mainFilterItem: defaultMainFilter)
        ))

        // With different sport
        let basketballItems = [
            FilterOptionItem(type: .sport, title: "Basketball", icon: "basketball.fill"),
            FilterOptionItem(type: .sortBy, title: "Recent", icon: "clock.fill"),
            FilterOptionItem(type: .league, title: "NBA", icon: "list.bullet")
        ]

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Basketball + Recent + NBA",
            view: createFilterBarView(items: basketballItems, mainFilterItem: defaultMainFilter)
        ))
    }

    private func addFilterTypeCombinationsVariants(to stackView: UIStackView) {
        let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "line.3.horizontal.decrease", actionIcon: "chevron.down")

        // Only sport filter
        let sportOnlyItems = [
            FilterOptionItem(type: .sport, title: "Tennis", icon: "sportscourt.fill")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sport Only",
            view: createFilterBarView(items: sportOnlyItems, mainFilterItem: mainFilter)
        ))

        // SortBy and League only (no sport)
        let noSportItems = [
            FilterOptionItem(type: .sortBy, title: "A-Z", icon: "textformat.abc"),
            FilterOptionItem(type: .league, title: "Champions League", icon: "trophy.fill")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "SortBy + League (No Sport)",
            view: createFilterBarView(items: noSportItems, mainFilterItem: mainFilter)
        ))

        // Multiple leagues
        let multipleLeaguesItems = [
            FilterOptionItem(type: .league, title: "Premier League", icon: "flag.fill"),
            FilterOptionItem(type: .league, title: "La Liga", icon: "flag.fill"),
            FilterOptionItem(type: .league, title: "Serie A", icon: "flag.fill")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Leagues",
            view: createFilterBarView(items: multipleLeaguesItems, mainFilterItem: mainFilter)
        ))
    }

    private func addItemCountVariants(to stackView: UIStackView) {
        let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "line.3.horizontal.decrease", actionIcon: "chevron.down")

        // Single item
        let singleItem = [
            FilterOptionItem(type: .sortBy, title: "Popular", icon: "star.fill")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Item",
            view: createFilterBarView(items: singleItem, mainFilterItem: mainFilter)
        ))

        // Many items (scrollable)
        let manyItems = [
            FilterOptionItem(type: .sport, title: "Football", icon: "soccerball"),
            FilterOptionItem(type: .sport, title: "Basketball", icon: "basketball.fill"),
            FilterOptionItem(type: .sport, title: "Tennis", icon: "sportscourt.fill"),
            FilterOptionItem(type: .sortBy, title: "Popular", icon: "star.fill"),
            FilterOptionItem(type: .league, title: "Top Leagues", icon: "trophy.fill")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Many Items (Scrollable)",
            view: createFilterBarView(items: manyItems, mainFilterItem: mainFilter)
        ))

        // Empty items
        let emptyItems: [FilterOptionItem] = []
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Items",
            view: createFilterBarView(items: emptyItems, mainFilterItem: mainFilter)
        ))
    }

    private func addMainFilterStatesVariants(to stackView: UIStackView) {
        let defaultItems = [
            FilterOptionItem(type: .sport, title: "Football", icon: "soccerball"),
            FilterOptionItem(type: .sortBy, title: "Popular", icon: "star.fill")
        ]

        // Main filter with title only
        let titleOnlyFilter = MainFilterItem(type: .mainFilter, title: "Filter")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Main Filter: Title Only",
            view: createFilterBarView(items: defaultItems, mainFilterItem: titleOnlyFilter)
        ))

        // Main filter with icon
        let withIconFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "line.3.horizontal.decrease")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Main Filter: With Icon",
            view: createFilterBarView(items: defaultItems, mainFilterItem: withIconFilter)
        ))

        // Main filter with icon and action icon
        let fullFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "line.3.horizontal.decrease", actionIcon: "chevron.down")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Main Filter: Icon + Action Icon",
            view: createFilterBarView(items: defaultItems, mainFilterItem: fullFilter)
        ))

        // Main filter with long title
        let longTitleFilter = MainFilterItem(type: .mainFilter, title: "Advanced Filters", icon: "line.3.horizontal.decrease", actionIcon: "chevron.down")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Main Filter: Long Title",
            view: createFilterBarView(items: defaultItems, mainFilterItem: longTitleFilter)
        ))
    }

    // MARK: - Helper Methods

    private func createFilterBarView(items: [FilterOptionItem], mainFilterItem: MainFilterItem) -> GeneralFilterBarView {
        let viewModel = MockGeneralFilterBarViewModel(items: items, mainFilterItem: mainFilterItem)
        let view = GeneralFilterBarView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return view
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let labelContainer = UIView()
        labelContainer.addSubview(labelView)
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 16),
            labelView.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -16),
            labelView.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            labelView.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [labelContainer, view])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Default Configuration") {
    GeneralFilterBarViewSnapshotViewController(category: .defaultConfiguration)
}

#Preview("Filter Type Combinations") {
    GeneralFilterBarViewSnapshotViewController(category: .filterTypeCombinations)
}

#Preview("Item Count Variants") {
    GeneralFilterBarViewSnapshotViewController(category: .itemCountVariants)
}

#Preview("Main Filter States") {
    GeneralFilterBarViewSnapshotViewController(category: .mainFilterStates)
}
#endif
