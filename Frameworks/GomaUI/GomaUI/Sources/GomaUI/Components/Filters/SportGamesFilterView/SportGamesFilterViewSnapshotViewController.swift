import UIKit
import SwiftUI
import SharedModels

// MARK: - Snapshot Category
enum SportGamesFilterSnapshotCategory: String, CaseIterable {
    case expandedState = "Expanded State"
    case collapsedState = "Collapsed State"
    case selectionStates = "Selection States"
}

final class SportGamesFilterViewSnapshotViewController: UIViewController {

    private let category: SportGamesFilterSnapshotCategory

    init(category: SportGamesFilterSnapshotCategory) {
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
        titleLabel.text = "SportGamesFilterView - \(category.rawValue)"
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
        case .expandedState:
            addExpandedStateVariants(to: stackView)
        case .collapsedState:
            addCollapsedStateVariants(to: stackView)
        case .selectionStates:
            addSelectionStateVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addExpandedStateVariants(to stackView: UIStackView) {
        // 2 sports
        let twoSportsFilters = [
            SportFilter(id: "1", title: "Football", icon: "sport_type_icon_default"),
            SportFilter(id: "2", title: "Basketball", icon: "sport_type_icon_default")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Two Sports",
            view: createFilterView(
                title: "Games",
                sportFilters: twoSportsFilters,
                selectedSport: .singleSport(id: "1"),
                state: .expanded
            )
        ))

        // 4 sports (standard grid)
        let fourSportsFilters = [
            SportFilter(id: "1", title: "Football", icon: "sport_type_icon_default"),
            SportFilter(id: "2", title: "Basketball", icon: "sport_type_icon_default"),
            SportFilter(id: "3", title: "Tennis", icon: "sport_type_icon_default"),
            SportFilter(id: "4", title: "Cricket", icon: "sport_type_icon_default")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Four Sports (Grid)",
            view: createFilterView(
                title: "Games",
                sportFilters: fourSportsFilters,
                selectedSport: .singleSport(id: "1"),
                state: .expanded
            )
        ))

        // 3 sports (odd number)
        let threeSportsFilters = [
            SportFilter(id: "1", title: "Football", icon: "sport_type_icon_default"),
            SportFilter(id: "2", title: "Basketball", icon: "sport_type_icon_default"),
            SportFilter(id: "3", title: "Tennis", icon: "sport_type_icon_default")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Three Sports (Odd)",
            view: createFilterView(
                title: "Games",
                sportFilters: threeSportsFilters,
                selectedSport: .singleSport(id: "1"),
                state: .expanded
            )
        ))
    }

    private func addCollapsedStateVariants(to stackView: UIStackView) {
        // Collapsed with 4 sports
        let fourSportsFilters = [
            SportFilter(id: "1", title: "Football", icon: "sport_type_icon_default"),
            SportFilter(id: "2", title: "Basketball", icon: "sport_type_icon_default"),
            SportFilter(id: "3", title: "Tennis", icon: "sport_type_icon_default"),
            SportFilter(id: "4", title: "Cricket", icon: "sport_type_icon_default")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Collapsed (4 Sports)",
            view: createFilterView(
                title: "Games",
                sportFilters: fourSportsFilters,
                selectedSport: .singleSport(id: "1"),
                state: .collapsed
            )
        ))

        // Collapsed with 2 sports
        let twoSportsFilters = [
            SportFilter(id: "1", title: "Football", icon: "sport_type_icon_default"),
            SportFilter(id: "2", title: "Basketball", icon: "sport_type_icon_default")
        ]
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Collapsed (2 Sports)",
            view: createFilterView(
                title: "Top Sports",
                sportFilters: twoSportsFilters,
                selectedSport: .singleSport(id: "2"),
                state: .collapsed
            )
        ))
    }

    private func addSelectionStateVariants(to stackView: UIStackView) {
        let fourSportsFilters = [
            SportFilter(id: "1", title: "Football", icon: "sport_type_icon_default"),
            SportFilter(id: "2", title: "Basketball", icon: "sport_type_icon_default"),
            SportFilter(id: "3", title: "Tennis", icon: "sport_type_icon_default"),
            SportFilter(id: "4", title: "Cricket", icon: "sport_type_icon_default")
        ]

        // First sport selected
        stackView.addArrangedSubview(createLabeledVariant(
            label: "First Selected",
            view: createFilterView(
                title: "Games",
                sportFilters: fourSportsFilters,
                selectedSport: .singleSport(id: "1"),
                state: .expanded
            )
        ))

        // Second sport selected
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Second Selected",
            view: createFilterView(
                title: "Games",
                sportFilters: fourSportsFilters,
                selectedSport: .singleSport(id: "2"),
                state: .expanded
            )
        ))

        // Last sport selected
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Last Selected",
            view: createFilterView(
                title: "Games",
                sportFilters: fourSportsFilters,
                selectedSport: .singleSport(id: "4"),
                state: .expanded
            )
        ))
    }

    // MARK: - Helper Methods

    private func createFilterView(
        title: String,
        sportFilters: [SportFilter],
        selectedSport: FilterIdentifier,
        state: SportGamesFilterStateType
    ) -> SportGamesFilterView {
        let viewModel = MockSportGamesFilterViewModel(
            title: title,
            sportFilters: sportFilters,
            selectedSport: selectedSport,
            sportFilterState: state
        )
        let view = SportGamesFilterView(viewModel: viewModel)
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
#Preview("Expanded State") {
    SportGamesFilterViewSnapshotViewController(category: .expandedState)
}

#Preview("Collapsed State") {
    SportGamesFilterViewSnapshotViewController(category: .collapsedState)
}

#Preview("Selection States") {
    SportGamesFilterViewSnapshotViewController(category: .selectionStates)
}
#endif
