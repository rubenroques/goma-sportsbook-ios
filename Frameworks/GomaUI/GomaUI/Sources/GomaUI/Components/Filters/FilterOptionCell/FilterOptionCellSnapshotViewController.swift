import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum FilterOptionCellSnapshotCategory: String, CaseIterable {
    case filterTypes = "Filter Types"
    case contentVariants = "Content Variants"
}

final class FilterOptionCellSnapshotViewController: UIViewController {

    private let category: FilterOptionCellSnapshotCategory

    init(category: FilterOptionCellSnapshotCategory) {
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
        titleLabel.text = "FilterOptionCell - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
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
        case .filterTypes:
            addFilterTypesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addFilterTypesVariants(to stackView: UIStackView) {
        // Sport type
        let sportItem = FilterOptionItem(type: .sport, title: "Football", icon: "sport_football")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sport Type (Football)",
            view: createFilterOptionCell(viewModel: FilterOptionCellViewModel(filterOptionItem: sportItem))
        ))

        // Sort By type
        let sortByItem = FilterOptionItem(type: .sortBy, title: "Popular", icon: "sort_popular")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sort By Type",
            view: createFilterOptionCell(viewModel: FilterOptionCellViewModel(filterOptionItem: sortByItem))
        ))

        // League type
        let leagueItem = FilterOptionItem(type: .league, title: "Premier League", icon: "league_premier")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "League Type",
            view: createFilterOptionCell(viewModel: FilterOptionCellViewModel(filterOptionItem: leagueItem))
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short title
        let shortItem = FilterOptionItem(type: .sport, title: "NBA", icon: "sport_basketball")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Title",
            view: createFilterOptionCell(viewModel: FilterOptionCellViewModel(filterOptionItem: shortItem))
        ))

        // Medium title
        let mediumItem = FilterOptionItem(type: .sport, title: "Tennis", icon: "sport_tennis")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Medium Title",
            view: createFilterOptionCell(viewModel: FilterOptionCellViewModel(filterOptionItem: mediumItem))
        ))

        // Long title
        let longItem = FilterOptionItem(type: .league, title: "UEFA Champions League", icon: "league_champions")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title",
            view: createFilterOptionCell(viewModel: FilterOptionCellViewModel(filterOptionItem: longItem))
        ))
    }

    // MARK: - Helper Methods

    private func createFilterOptionCell(
        viewModel: FilterOptionCellViewModel,
        width: CGFloat = 150,
        height: CGFloat = 42
    ) -> UIView {
        let cell = FilterOptionCell(frame: CGRect(x: 0, y: 0, width: width, height: height))
        cell.configure(with: viewModel)
        cell.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cell.widthAnchor.constraint(equalToConstant: width),
            cell.heightAnchor.constraint(equalToConstant: height)
        ])

        return cell
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Filter Types") {
    FilterOptionCellSnapshotViewController(category: .filterTypes)
}

#Preview("Content Variants") {
    FilterOptionCellSnapshotViewController(category: .contentVariants)
}
#endif
