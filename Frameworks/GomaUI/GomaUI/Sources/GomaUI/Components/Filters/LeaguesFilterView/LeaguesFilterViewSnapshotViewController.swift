import UIKit
import SwiftUI
import Combine
import SharedModels

// MARK: - Snapshot Category
enum LeaguesFilterSnapshotCategory: String, CaseIterable {
    case expanded = "Expanded State"
    case collapsed = "Collapsed State"
    case selectionStates = "Selection States"
    case contentVariants = "Content Variants"
}

final class LeaguesFilterViewSnapshotViewController: UIViewController {

    private let category: LeaguesFilterSnapshotCategory

    init(category: LeaguesFilterSnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "LeaguesFilterView - \(category.rawValue)"
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
        case .expanded:
            addExpandedVariants(to: stackView)
        case .collapsed:
            addCollapsedVariants(to: stackView)
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addExpandedVariants(to stackView: UIStackView) {
        let options = createStandardLeagueOptions()
        let viewModel = MockLeaguesFilterViewModel(leagueOptions: options, selectedFilter: .all)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Expanded (Default)",
            view: createLeaguesFilterView(viewModel: viewModel)
        ))
    }

    private func addCollapsedVariants(to stackView: UIStackView) {
        let options = createStandardLeagueOptions()
        let viewModel = MockLeaguesFilterViewModel(leagueOptions: options, selectedFilter: .all)
        viewModel.isCollapsed.send(true)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Collapsed",
            view: createLeaguesFilterView(viewModel: viewModel)
        ))
    }

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        let options = createStandardLeagueOptions()

        // First option selected
        let viewModel1 = MockLeaguesFilterViewModel(leagueOptions: options, selectedFilter: LeagueFilterIdentifier(stringValue: "1"))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "First Option Selected",
            view: createLeaguesFilterView(viewModel: viewModel1)
        ))

        // Middle option selected
        let viewModel2 = MockLeaguesFilterViewModel(leagueOptions: options, selectedFilter: LeagueFilterIdentifier(stringValue: "3"))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Middle Option Selected",
            view: createLeaguesFilterView(viewModel: viewModel2)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Few options
        let fewOptions = [
            LeagueOption(id: "1", icon: nil, title: "Premier League", count: 32),
            LeagueOption(id: "2", icon: nil, title: "La Liga", count: 28)
        ]
        let viewModel1 = MockLeaguesFilterViewModel(leagueOptions: fewOptions, selectedFilter: .all)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Few Options (2)",
            view: createLeaguesFilterView(viewModel: viewModel1)
        ))

        // Option with zero count
        let optionsWithZero = [
            LeagueOption(id: "1", icon: nil, title: "Premier League", count: 32),
            LeagueOption(id: "2", icon: nil, title: "Ligue 1", count: 0),
            LeagueOption(id: "3", icon: nil, title: "Serie A", count: 27)
        ]
        let viewModel2 = MockLeaguesFilterViewModel(leagueOptions: optionsWithZero, selectedFilter: .all)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Zero Count Option",
            view: createLeaguesFilterView(viewModel: viewModel2)
        ))

        // Long title
        let optionsLongTitle = [
            LeagueOption(id: "1", icon: nil, title: "UEFA Champions League Group Stage", count: 16),
            LeagueOption(id: "2", icon: nil, title: "Short", count: 10)
        ]
        let viewModel3 = MockLeaguesFilterViewModel(leagueOptions: optionsLongTitle, selectedFilter: .all)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title",
            view: createLeaguesFilterView(viewModel: viewModel3)
        ))
    }

    // MARK: - Helper Methods

    private func createStandardLeagueOptions() -> [LeagueOption] {
        return [
            LeagueOption(id: "1", icon: nil, title: "Premier League", count: 32),
            LeagueOption(id: "2", icon: nil, title: "La Liga", count: 28),
            LeagueOption(id: "3", icon: nil, title: "Bundesliga", count: 25),
            LeagueOption(id: "4", icon: nil, title: "Serie A", count: 27)
        ]
    }

    private func createLeaguesFilterView(viewModel: MockLeaguesFilterViewModel) -> LeaguesFilterView {
        let filterView = LeaguesFilterView(viewModel: viewModel)
        filterView.translatesAutoresizingMaskIntoConstraints = false
        return filterView
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
    LeaguesFilterViewSnapshotViewController(category: .expanded)
}

#Preview("Collapsed State") {
    LeaguesFilterViewSnapshotViewController(category: .collapsed)
}

#Preview("Selection States") {
    LeaguesFilterViewSnapshotViewController(category: .selectionStates)
}

#Preview("Content Variants") {
    LeaguesFilterViewSnapshotViewController(category: .contentVariants)
}
#endif
