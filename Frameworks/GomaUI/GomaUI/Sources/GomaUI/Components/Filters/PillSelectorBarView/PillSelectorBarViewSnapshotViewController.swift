import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum PillSelectorBarSnapshotCategory: String, CaseIterable {
    case contentTypes = "Content Types"
    case selectionStates = "Selection States"
    case scrollConfiguration = "Scroll Configuration"
    case itemCountVariants = "Item Count Variants"
}

final class PillSelectorBarViewSnapshotViewController: UIViewController {

    private let category: PillSelectorBarSnapshotCategory

    init(category: PillSelectorBarSnapshotCategory) {
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
        titleLabel.text = "PillSelectorBarView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
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
        case .contentTypes:
            addContentTypesVariants(to: stackView)
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        case .scrollConfiguration:
            addScrollConfigurationVariants(to: stackView)
        case .itemCountVariants:
            addItemCountVariants(to: stackView)
        }
    }

    // MARK: - Content Types

    private func addContentTypesVariants(to stackView: UIStackView) {
        // Sports categories with icons
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sports Categories (Icons + Expand)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.sportsCategories)
        ))

        // Market filters (mixed icons)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Market Filters (Mixed Icons)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.marketFilters)
        ))

        // Text-only pills
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Text Only (No Icons)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.textOnlyPills)
        ))

        // Time periods (calendar icon + text)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Time Periods",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.timePeriods)
        ))
    }

    // MARK: - Selection States

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        // Standard selection (first item selected)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "First Item Selected",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.sportsCategories)
        ))

        // Middle item selected
        let midSelectedVM = MockPillSelectorBarViewModel.timePeriods
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Middle Item Selected (Tomorrow)",
            view: createPillSelectorBarView(viewModel: midSelectedVM)
        ))

        // Read-only mode (multiple visual selections)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Read-Only (Multiple Visual States)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.readOnlyMarketFilters)
        ))

        // Football popular leagues (read-only with specific selection)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Football Popular Leagues (Read-Only)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.footballPopularLeagues)
        ))
    }

    // MARK: - Scroll Configuration

    private func addScrollConfigurationVariants(to stackView: UIStackView) {
        // Scrollable (many pills)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Scrollable (Many Pills)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.sportsCategories)
        ))

        // Non-scrollable (limited pills)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Non-Scrollable (Limited Pills)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.limitedPills)
        ))
    }

    // MARK: - Item Count Variants

    private func addItemCountVariants(to stackView: UIStackView) {
        // Many pills (6 items)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Many Pills (6 Items)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.sportsCategories)
        ))

        // Few pills (4 items)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Few Pills (4 Items)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.textOnlyPills)
        ))

        // Minimal pills (2 items)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Minimal Pills (2 Items)",
            view: createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel.limitedPills)
        ))

        // Single pill
        let singlePillVM = createSinglePillViewModel()
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Pill",
            view: createPillSelectorBarView(viewModel: singlePillVM)
        ))
    }

    // MARK: - Helper Methods

    private func createPillSelectorBarView(viewModel: MockPillSelectorBarViewModel) -> PillSelectorBarView {
        let view = PillSelectorBarView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])
        return view
    }

    private func createSinglePillViewModel() -> MockPillSelectorBarViewModel {
        let pills = [
            PillData(
                id: "live",
                title: LocalizationProvider.string("live"),
                leftIconName: "dot.radiowaves.left.and.right",
                type: .informative,
                isSelected: true
            )
        ]

        let barData = PillSelectorBarData(
            id: "single_pill",
            pills: pills,
            selectedPillId: "live",
            isScrollEnabled: false,
            allowsVisualStateChanges: true
        )

        return MockPillSelectorBarViewModel(barData: barData)
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
#Preview("Content Types") {
    PillSelectorBarViewSnapshotViewController(category: .contentTypes)
}

#Preview("Selection States") {
    PillSelectorBarViewSnapshotViewController(category: .selectionStates)
}

#Preview("Scroll Configuration") {
    PillSelectorBarViewSnapshotViewController(category: .scrollConfiguration)
}

#Preview("Item Count Variants") {
    PillSelectorBarViewSnapshotViewController(category: .itemCountVariants)
}
#endif
