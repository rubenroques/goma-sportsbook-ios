import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum SimpleSquaredFilterBarSnapshotCategory: String, CaseIterable {
    case filterTypes = "Filter Types"
    case selectionStates = "Selection States"
    case itemCountVariants = "Item Count Variants"
}

final class SimpleSquaredFilterBarViewSnapshotViewController: UIViewController {

    private let category: SimpleSquaredFilterBarSnapshotCategory

    init(category: SimpleSquaredFilterBarSnapshotCategory) {
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
        titleLabel.text = "SimpleSquaredFilterBarView - \(category.rawValue)"
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
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .filterTypes:
            addFilterTypesVariants(to: stackView)
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .itemCountVariants:
            addItemCountVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addFilterTypesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Time Filters",
            view: createFilterBar(data: MockSimpleSquaredFilterBarViewModel.timeFilters)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Status Filters",
            view: createFilterBar(data: MockSimpleSquaredFilterBarViewModel.statusFilters)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Priority Filters",
            view: createFilterBar(data: MockSimpleSquaredFilterBarViewModel.priorityFilters)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Category Filters",
            view: createFilterBar(data: MockSimpleSquaredFilterBarViewModel.categoryFilters)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Game Type Filters",
            view: createFilterBar(data: MockSimpleSquaredFilterBarViewModel.gameTypeFilters)
        ))
    }

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        // First item selected
        let firstSelected = SimpleSquaredFilterBarData(
            items: [("1d", "1D"), ("1w", "1W"), ("1m", "1M"), ("3m", "3M"), ("1y", "1Y")],
            selectedId: "1d"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "First Item Selected",
            view: createFilterBar(data: firstSelected)
        ))

        // Middle item selected
        let middleSelected = SimpleSquaredFilterBarData(
            items: [("1d", "1D"), ("1w", "1W"), ("1m", "1M"), ("3m", "3M"), ("1y", "1Y")],
            selectedId: "1m"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Middle Item Selected",
            view: createFilterBar(data: middleSelected)
        ))

        // Last item selected
        let lastSelected = SimpleSquaredFilterBarData(
            items: [("1d", "1D"), ("1w", "1W"), ("1m", "1M"), ("3m", "3M"), ("1y", "1Y")],
            selectedId: "1y"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Last Item Selected",
            view: createFilterBar(data: lastSelected)
        ))
    }

    private func addItemCountVariants(to stackView: UIStackView) {
        // Two items
        let twoItems = SimpleSquaredFilterBarData(
            items: [("on", "On"), ("off", "Off")],
            selectedId: "on"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Two Items",
            view: createFilterBar(data: twoItems)
        ))

        // Three items
        let threeItems = SimpleSquaredFilterBarData(
            items: [("low", "Low"), ("med", "Med"), ("high", "High")],
            selectedId: "med"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Three Items",
            view: createFilterBar(data: threeItems)
        ))

        // Five items (standard)
        let fiveItems = SimpleSquaredFilterBarData(
            items: [("all", "All"), ("1d", "1D"), ("1w", "1W"), ("1m", "1M"), ("3m", "3M")],
            selectedId: "all"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Five Items",
            view: createFilterBar(data: fiveItems)
        ))

        // Six items
        let sixItems = SimpleSquaredFilterBarData(
            items: [
                ("all", "All"),
                ("1h", "1H"),
                ("1d", "1D"),
                ("1w", "1W"),
                ("1m", "1M"),
                ("1y", "1Y")
            ],
            selectedId: "1w"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Six Items",
            view: createFilterBar(data: sixItems)
        ))
    }

    // MARK: - Helper Methods

    private func createFilterBar(data: SimpleSquaredFilterBarData) -> SimpleSquaredFilterBarView {
        let view = SimpleSquaredFilterBarView(data: data)
        view.translatesAutoresizingMaskIntoConstraints = false
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
            labelView.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            labelView.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor),
            labelView.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 16),
            labelView.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -16)
        ])

        let stack = UIStackView(arrangedSubviews: [labelContainer, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Filter Types") {
    SimpleSquaredFilterBarViewSnapshotViewController(category: .filterTypes)
}

#Preview("Selection States") {
    SimpleSquaredFilterBarViewSnapshotViewController(category: .selectionStates)
}

#Preview("Item Count Variants") {
    SimpleSquaredFilterBarViewSnapshotViewController(category: .itemCountVariants)
}
#endif
