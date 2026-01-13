import UIKit
import SwiftUI
import SharedModels

// MARK: - Snapshot Category
enum SortFilterSnapshotCategory: String, CaseIterable {
    case expandedState = "Expanded State"
    case collapsedState = "Collapsed State"
    case selectionStates = "Selection States"
    case contentVariants = "Content Variants"
}

final class SortFilterViewSnapshotViewController: UIViewController {

    private let category: SortFilterSnapshotCategory

    init(category: SortFilterSnapshotCategory) {
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
        titleLabel.text = "SortFilterView - \(category.rawValue)"
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
        case .expandedState:
            addExpandedStateVariants(to: stackView)
        case .collapsedState:
            addCollapsedStateVariants(to: stackView)
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addExpandedStateVariants(to stackView: UIStackView) {
        // Default expanded with multiple options
        let sortOptions: [SortOption] = [
            SortOption(id: "popular", icon: "flame.fill", title: "Popular", count: 25),
            SortOption(id: "upcoming", icon: "clock.fill", title: "Upcoming", count: 15),
            SortOption(id: "favourites", icon: "heart.fill", title: "Favourites", count: 8)
        ]
        let viewModel = MockSortFilterViewModel(
            title: "Sort By",
            sortOptions: sortOptions,
            selectedFilter: .all
        )
        viewModel.isCollapsed.send(false)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Expanded (3 options)",
            view: createSortFilterView(viewModel: viewModel)
        ))

        // Expanded with more options
        let moreOptions: [SortOption] = [
            SortOption(id: "all", icon: "list.bullet", title: "All Matches", count: 120),
            SortOption(id: "live", icon: "play.circle.fill", title: "Live Now", count: 45),
            SortOption(id: "starting", icon: "timer", title: "Starting Soon", count: 30),
            SortOption(id: "featured", icon: "star.fill", title: "Featured", count: 12)
        ]
        let moreViewModel = MockSortFilterViewModel(
            title: "Filter By",
            sortOptions: moreOptions,
            selectedFilter: .all
        )
        moreViewModel.isCollapsed.send(false)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Expanded (4 options)",
            view: createSortFilterView(viewModel: moreViewModel)
        ))
    }

    private func addCollapsedStateVariants(to stackView: UIStackView) {
        let sortOptions: [SortOption] = [
            SortOption(id: "popular", icon: "flame.fill", title: "Popular", count: 25),
            SortOption(id: "upcoming", icon: "clock.fill", title: "Upcoming", count: 15),
            SortOption(id: "favourites", icon: "heart.fill", title: "Favourites", count: 8)
        ]

        // Collapsed state
        let collapsedViewModel = MockSortFilterViewModel(
            title: "Sort By",
            sortOptions: sortOptions,
            selectedFilter: .all
        )
        collapsedViewModel.isCollapsed.send(true)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Collapsed",
            view: createSortFilterView(viewModel: collapsedViewModel)
        ))

        // Different title when collapsed
        let filterViewModel = MockSortFilterViewModel(
            title: "Filter Options",
            sortOptions: sortOptions,
            selectedFilter: .all
        )
        filterViewModel.isCollapsed.send(true)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Collapsed (Custom Title)",
            view: createSortFilterView(viewModel: filterViewModel)
        ))
    }

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        let sortOptions: [SortOption] = [
            SortOption(id: "popular", icon: "flame.fill", title: "Popular", count: 25),
            SortOption(id: "upcoming", icon: "clock.fill", title: "Upcoming", count: 15),
            SortOption(id: "favourites", icon: "heart.fill", title: "Favourites", count: 8)
        ]

        // First option selected
        let firstSelectedVM = MockSortFilterViewModel(
            title: "Sort By",
            sortOptions: sortOptions,
            selectedFilter: LeagueFilterIdentifier(stringValue: "popular")
        )
        firstSelectedVM.isCollapsed.send(false)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "First Option Selected",
            view: createSortFilterView(viewModel: firstSelectedVM)
        ))

        // Middle option selected
        let middleSelectedVM = MockSortFilterViewModel(
            title: "Sort By",
            sortOptions: sortOptions,
            selectedFilter: LeagueFilterIdentifier(stringValue: "upcoming")
        )
        middleSelectedVM.isCollapsed.send(false)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Middle Option Selected",
            view: createSortFilterView(viewModel: middleSelectedVM)
        ))

        // Last option selected
        let lastSelectedVM = MockSortFilterViewModel(
            title: "Sort By",
            sortOptions: sortOptions,
            selectedFilter: LeagueFilterIdentifier(stringValue: "favourites")
        )
        lastSelectedVM.isCollapsed.send(false)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Last Option Selected",
            view: createSortFilterView(viewModel: lastSelectedVM)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Options with zero count
        let zeroCountOptions: [SortOption] = [
            SortOption(id: "popular", icon: "flame.fill", title: "Popular", count: 25),
            SortOption(id: "favourites", icon: "heart.fill", title: "Favourites", count: 0)
        ]
        let zeroCountVM = MockSortFilterViewModel(
            title: "Sort By",
            sortOptions: zeroCountOptions,
            selectedFilter: .all
        )
        zeroCountVM.isCollapsed.send(false)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Zero Count ('No Events')",
            view: createSortFilterView(viewModel: zeroCountVM)
        ))

        // Options with negative count (hidden count)
        let hiddenCountOptions: [SortOption] = [
            SortOption(id: "all", icon: "list.bullet", title: "All Matches", count: -1),
            SortOption(id: "live", icon: "play.circle.fill", title: "Live", count: -1)
        ]
        let hiddenCountVM = MockSortFilterViewModel(
            title: "Filter",
            sortOptions: hiddenCountOptions,
            selectedFilter: .all
        )
        hiddenCountVM.isCollapsed.send(false)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Hidden Count (negative)",
            view: createSortFilterView(viewModel: hiddenCountVM)
        ))

        // Long title options
        let longTitleOptions: [SortOption] = [
            SortOption(id: "1", icon: "star.fill", title: "Very Long Sort Option Title", count: 100),
            SortOption(id: "2", icon: "clock.fill", title: "Another Extended Title", count: 50)
        ]
        let longTitleVM = MockSortFilterViewModel(
            title: "Long Title Sort Options",
            sortOptions: longTitleOptions,
            selectedFilter: .all
        )
        longTitleVM.isCollapsed.send(false)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Titles",
            view: createSortFilterView(viewModel: longTitleVM)
        ))

        // No icon tint change option
        let noTintOptions: [SortOption] = [
            SortOption(id: "1", icon: "flame.fill", title: "With Tint", count: 10, iconTintChange: true),
            SortOption(id: "2", icon: "star.fill", title: "No Tint Change", count: 5, iconTintChange: false)
        ]
        let noTintVM = MockSortFilterViewModel(
            title: "Icon Variants",
            sortOptions: noTintOptions,
            selectedFilter: LeagueFilterIdentifier(stringValue: "2")
        )
        noTintVM.isCollapsed.send(false)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Icon Tint Variants",
            view: createSortFilterView(viewModel: noTintVM)
        ))
    }

    // MARK: - Helper Methods

    private func createSortFilterView(viewModel: MockSortFilterViewModel) -> SortFilterView {
        let sortFilterView = SortFilterView(viewModel: viewModel)
        sortFilterView.translatesAutoresizingMaskIntoConstraints = false
        return sortFilterView
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
#Preview("Expanded State") {
    SortFilterViewSnapshotViewController(category: .expandedState)
}

#Preview("Collapsed State") {
    SortFilterViewSnapshotViewController(category: .collapsedState)
}

#Preview("Selection States") {
    SortFilterViewSnapshotViewController(category: .selectionStates)
}

#Preview("Content Variants") {
    SortFilterViewSnapshotViewController(category: .contentVariants)
}
#endif
